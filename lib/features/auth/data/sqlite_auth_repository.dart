// ignore_for_file: prefer_initializing_formals

import 'package:sqflite/sqflite.dart';

import '../../../core/security/password_hasher.dart';
import '../../../core/storage/app_database.dart';
import '../domain/app_user.dart';
import 'auth_repository.dart';

class SqliteAuthRepository implements AuthRepository {
  // Named dependencies make application composition explicit and prevent
  // accidental argument-order mistakes.
  SqliteAuthRepository({
    required AppDatabase database,
    required PasswordHasher passwordHasher,
  }) : _database = database,
       _passwordHasher = passwordHasher;

  final AppDatabase _database;
  final PasswordHasher _passwordHasher;

  @override
  Future<AppUser> create({
    required String username,
    required String password,
    required String preferredLanguage,
  }) async {
    final normalized = _normalize(username);
    final existing = await _findAccount(normalized);
    if (existing != null) throw UsernameAlreadyExistsException();

    final digest = _passwordHasher.hash(password);
    final now = DateTime.now().toUtc();
    final database = await _database.instance;
    try {
      final id = await database.insert('users', {
        'username': normalized,
        'password_hash': digest.hash,
        'password_salt': digest.salt,
        'preferred_language': preferredLanguage,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      });
      return AppUser(
        id: id,
        username: normalized,
        preferredLanguage: preferredLanguage,
        createdAt: now,
      );
    } on DatabaseException catch (error) {
      if (error.isUniqueConstraintError()) {
        throw UsernameAlreadyExistsException();
      }
      rethrow;
    }
  }

  @override
  Future<AppUser?> authenticate({
    required String username,
    required String password,
  }) async {
    final account = await _findAccount(_normalize(username));
    if (account == null) return null;
    final valid = _passwordHasher.verify(
      password: password,
      expectedHash: account['password_hash']! as String,
      salt: account['password_salt']! as String,
    );
    return valid ? _toUser(account) : null;
  }

  @override
  Future<AppUser?> findById(int id) async {
    final database = await _database.instance;
    final rows = await database.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : _toUser(rows.first);
  }

  @override
  Future<void> updateLanguage(int id, String languageCode) async {
    final database = await _database.instance;
    await database.update(
      'users',
      {
        'preferred_language': languageCode,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Map<String, Object?>?> _findAccount(String username) async {
    final database = await _database.instance;
    final rows = await database.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  AppUser _toUser(Map<String, Object?> row) {
    return AppUser(
      id: row['id']! as int,
      username: row['username']! as String,
      preferredLanguage: row['preferred_language']! as String,
      createdAt: DateTime.parse(row['created_at']! as String),
    );
  }

  String _normalize(String username) => username.trim().toLowerCase();
}
