import 'package:shared_preferences/shared_preferences.dart';

abstract interface class AppPreferences {
  Future<String?> readLanguageCode();
  Future<void> saveLanguageCode(String languageCode);
  Future<int?> readActiveUserId();
  Future<void> saveActiveUserId(int userId);
  Future<void> clearActiveUser();
}

class SharedAppPreferences implements AppPreferences {
  static const _languageKey = 'preferred_language';
  static const _activeUserKey = 'active_user_id';

  Future<SharedPreferences> get _instance => SharedPreferences.getInstance();

  @override
  Future<String?> readLanguageCode() async =>
      (await _instance).getString(_languageKey);

  @override
  Future<void> saveLanguageCode(String languageCode) async {
    await (await _instance).setString(_languageKey, languageCode);
  }

  @override
  Future<int?> readActiveUserId() async =>
      (await _instance).getInt(_activeUserKey);

  @override
  Future<void> saveActiveUserId(int userId) async {
    await (await _instance).setInt(_activeUserKey, userId);
  }

  @override
  Future<void> clearActiveUser() async {
    await (await _instance).remove(_activeUserKey);
  }
}
