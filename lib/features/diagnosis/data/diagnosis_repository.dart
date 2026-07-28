import 'dart:convert';

import '../../../core/storage/app_database.dart';
import '../domain/diagnosis.dart';

class DiagnosisRepository {
  DiagnosisRepository(this._database);

  final AppDatabase _database;

  Future<void> save({required int userId, required Diagnosis diagnosis}) async {
    final database = await _database.instance;
    await database.insert('diagnoses', {
      'id': diagnosis.id,
      'user_id': userId,
      'plant_name': diagnosis.plantName,
      'condition_code': diagnosis.conditionCode,
      'condition_name': diagnosis.conditionName,
      'category': diagnosis.category.name,
      'confidence_band': diagnosis.confidence.name,
      'image_path': diagnosis.imagePath,
      'result_json': jsonEncode(diagnosis.toJson()),
      'model': diagnosis.model,
      'prompt_version': diagnosis.promptVersion,
      'created_at': diagnosis.createdAt.toIso8601String(),
    });
  }

  Future<List<Diagnosis>> listForUser(int userId) async {
    final database = await _database.instance;
    final rows = await database.query(
      'diagnoses',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return rows.map((row) {
      final json = jsonDecode(row['result_json']! as String);
      return Diagnosis.fromJson(
        json as Map<String, dynamic>,
        id: row['id']! as String,
        model: row['model'] as String? ?? 'unknown',
        promptVersion: row['prompt_version'] as String? ?? 'unknown',
        imagePath: row['image_path'] as String?,
        createdAt: DateTime.parse(row['created_at']! as String),
      );
    }).toList();
  }
}
