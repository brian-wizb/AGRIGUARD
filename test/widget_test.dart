import 'package:agriguard/app/app_controller.dart';
import 'package:agriguard/core/preferences/app_preferences.dart';
import 'package:agriguard/features/auth/data/auth_repository.dart';
import 'package:agriguard/features/auth/domain/app_user.dart';
import 'package:agriguard/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('user can register, logout, and login locally', (tester) async {
    final dependencies = _TestDependencies();
    await tester.pumpWidget(
      AgriGuardBootstrap(controller: dependencies.controller),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('createAccountButton')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('registerUsernameField')),
      'student',
    );
    await tester.enterText(
      find.byKey(const Key('registerPasswordField')),
      'password1',
    );
    await tester.enterText(
      find.byKey(const Key('confirmPasswordField')),
      'password1',
    );
    await tester.tap(find.byKey(const Key('registerButton')));
    await tester.pumpAndSettle();

    expect(find.text('Scan any leaf'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('logoutButton')));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('usernameField')), 'student');
    await tester.enterText(find.byKey(const Key('passwordField')), 'password1');
    await tester.tap(find.byKey(const Key('loginButton')));
    await tester.pumpAndSettle();

    expect(find.text('Scan any leaf'), findsOneWidget);
    expect(find.text('No crop selection is required.'), findsOneWidget);
  });

  testWidgets('language choice persists across controller restart', (
    tester,
  ) async {
    final repository = _MemoryAuthRepository();
    final preferences = _MemoryPreferences();
    var controller = AppController(repository, preferences);
    await tester.pumpWidget(
      AgriGuardBootstrap(key: const ValueKey('first'), controller: controller),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('languageToggle')));
    await tester.pumpAndSettle();
    expect(find.text('Karibu tena'), findsOneWidget);

    controller = AppController(repository, preferences);
    await tester.pumpWidget(
      AgriGuardBootstrap(key: const ValueKey('second'), controller: controller),
    );
    await tester.pumpAndSettle();

    expect(find.text('Karibu tena'), findsOneWidget);
    expect(find.text('Jina la mtumiaji'), findsOneWidget);
  });

  testWidgets('invalid login displays a localized error', (tester) async {
    final dependencies = _TestDependencies();
    await tester.pumpWidget(
      AgriGuardBootstrap(controller: dependencies.controller),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('usernameField')), 'missing');
    await tester.enterText(find.byKey(const Key('passwordField')), 'wrong');
    await tester.tap(find.byKey(const Key('loginButton')));
    await tester.pumpAndSettle();

    expect(find.text('Incorrect username or password'), findsOneWidget);
  });
}

class _TestDependencies {
  _TestDependencies()
    : controller = AppController(_MemoryAuthRepository(), _MemoryPreferences());

  final AppController controller;
}

class _MemoryPreferences implements AppPreferences {
  String? languageCode;
  int? activeUserId;

  @override
  Future<void> clearActiveUser() async => activeUserId = null;

  @override
  Future<int?> readActiveUserId() async => activeUserId;

  @override
  Future<String?> readLanguageCode() async => languageCode;

  @override
  Future<void> saveActiveUserId(int userId) async => activeUserId = userId;

  @override
  Future<void> saveLanguageCode(String value) async => languageCode = value;
}

class _MemoryAuthRepository implements AuthRepository {
  final Map<int, ({AppUser user, String password})> _accounts = {};
  var _nextId = 1;

  @override
  Future<AppUser?> authenticate({
    required String username,
    required String password,
  }) async {
    for (final account in _accounts.values) {
      if (account.user.username == username.trim().toLowerCase() &&
          account.password == password) {
        return account.user;
      }
    }
    return null;
  }

  @override
  Future<AppUser> create({
    required String username,
    required String password,
    required String preferredLanguage,
  }) async {
    final normalized = username.trim().toLowerCase();
    if (_accounts.values.any(
      (account) => account.user.username == normalized,
    )) {
      throw UsernameAlreadyExistsException();
    }
    final user = AppUser(
      id: _nextId++,
      username: normalized,
      preferredLanguage: preferredLanguage,
      createdAt: DateTime(2026),
    );
    _accounts[user.id] = (user: user, password: password);
    return user;
  }

  @override
  Future<AppUser?> findById(int id) async => _accounts[id]?.user;

  @override
  Future<void> updateLanguage(int id, String languageCode) async {
    final account = _accounts[id];
    if (account == null) return;
    _accounts[id] = (
      user: account.user.copyWith(preferredLanguage: languageCode),
      password: account.password,
    );
  }
}
