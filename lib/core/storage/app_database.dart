import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import 'database_schema.dart';

class AppDatabase {
  factory AppDatabase() => _shared;

  AppDatabase._();

  static final AppDatabase _shared = AppDatabase._();

  Database? _database;

  Future<Database> get instance async {
    if (_database != null) return _database!;
    final root = await getDatabasesPath();
    _database = await openDatabase(
      path.join(root, 'agriguard.db'),
      version: DatabaseSchema.version,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (database, version) async {
        await database.execute(DatabaseSchema.createUsers);
        await database.execute(DatabaseSchema.createDiagnoses);
        await database.execute(DatabaseSchema.createHardwareCommands);
      },
    );
    return _database!;
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
