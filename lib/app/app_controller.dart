import 'package:flutter/material.dart';

import '../core/preferences/app_preferences.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/domain/app_user.dart';

class AppController extends ChangeNotifier {
  AppController(this._authRepository, this._preferences);

  final AuthRepository _authRepository;
  final AppPreferences _preferences;

  Locale _locale = const Locale('en');
  AppUser? _currentUser;
  bool _initialized = false;
  bool _busy = false;
  String? _authErrorCode;

  Locale get locale => _locale;
  AppUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get initialized => _initialized;
  bool get busy => _busy;
  String? get authErrorCode => _authErrorCode;

  Future<void> initialize() async {
    final languageCode = await _preferences.readLanguageCode();
    _locale = Locale(languageCode ?? 'en');
    final userId = await _preferences.readActiveUserId();
    if (userId != null) {
      _currentUser = await _authRepository.findById(userId);
      if (_currentUser == null) {
        await _preferences.clearActiveUser();
      }
    }
    _initialized = true;
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
    await _preferences.saveLanguageCode(locale.languageCode);
    if (_currentUser != null) {
      await _authRepository.updateLanguage(
        _currentUser!.id,
        locale.languageCode,
      );
      _currentUser = _currentUser!.copyWith(
        preferredLanguage: locale.languageCode,
      );
    }
  }

  Future<void> toggleLocale() =>
      setLocale(Locale(_locale.languageCode == 'en' ? 'sw' : 'en'));

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    return _runAuthAction(() async {
      final user = await _authRepository.authenticate(
        username: username,
        password: password,
      );
      if (user == null) {
        _authErrorCode = 'invalidCredentials';
        return false;
      }
      _currentUser = user;
      await _preferences.saveActiveUserId(user.id);
      await setLocale(Locale(user.preferredLanguage));
      return true;
    });
  }

  Future<bool> register({
    required String username,
    required String password,
  }) async {
    return _runAuthAction(() async {
      try {
        final user = await _authRepository.create(
          username: username,
          password: password,
          preferredLanguage: _locale.languageCode,
        );
        _currentUser = user;
        await _preferences.saveActiveUserId(user.id);
        return true;
      } on UsernameAlreadyExistsException {
        _authErrorCode = 'usernameTaken';
        return false;
      }
    });
  }

  Future<void> logout() async {
    _busy = true;
    notifyListeners();
    await _preferences.clearActiveUser();
    _currentUser = null;
    _busy = false;
    notifyListeners();
  }

  void clearAuthError() {
    if (_authErrorCode == null) return;
    _authErrorCode = null;
    notifyListeners();
  }

  Future<bool> _runAuthAction(Future<bool> Function() action) async {
    _busy = true;
    _authErrorCode = null;
    notifyListeners();
    try {
      return await action();
    } catch (_) {
      _authErrorCode = 'unexpectedError';
      return false;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }
}

class AppControllerScope extends InheritedNotifier<AppController> {
  const AppControllerScope({
    required AppController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static AppController of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<AppControllerScope>();
    assert(
      scope != null,
      'AppControllerScope was not found in the widget tree.',
    );
    return scope!.notifier!;
  }
}
