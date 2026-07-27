abstract final class DatabaseSchema {
  static const version = 1;

  static const createUsers = '''
    CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT NOT NULL UNIQUE,
      password_hash TEXT NOT NULL,
      password_salt TEXT NOT NULL,
      preferred_language TEXT NOT NULL DEFAULT 'en',
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
  ''';

  static const createDiagnoses = '''
    CREATE TABLE diagnoses (
      id TEXT PRIMARY KEY,
      user_id INTEGER NOT NULL,
      plant_name TEXT,
      condition_code TEXT NOT NULL,
      condition_name TEXT NOT NULL,
      category TEXT NOT NULL,
      confidence_band TEXT NOT NULL,
      image_path TEXT,
      result_json TEXT NOT NULL,
      model TEXT,
      prompt_version TEXT,
      created_at TEXT NOT NULL,
      FOREIGN KEY (user_id) REFERENCES users (id)
    )
  ''';

  static const createHardwareCommands = '''
    CREATE TABLE hardware_commands (
      id TEXT PRIMARY KEY,
      diagnosis_id TEXT,
      device_id TEXT NOT NULL,
      command_type TEXT NOT NULL,
      request_id TEXT NOT NULL UNIQUE,
      status TEXT NOT NULL,
      acknowledgement TEXT,
      error TEXT,
      created_at TEXT NOT NULL,
      FOREIGN KEY (diagnosis_id) REFERENCES diagnoses (id)
    )
  ''';
}
