import '../domain/app_user.dart';

abstract interface class AuthRepository {
  Future<AppUser> create({
    required String username,
    required String password,
    required String preferredLanguage,
  });

  Future<AppUser?> authenticate({
    required String username,
    required String password,
  });

  Future<AppUser?> findById(int id);

  Future<void> updateLanguage(int id, String languageCode);
}

class UsernameAlreadyExistsException implements Exception {}
