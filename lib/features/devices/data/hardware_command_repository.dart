import '../../../core/storage/app_database.dart';
import '../domain/trap_protocol.dart';

class HardwareCommandRepository {
  HardwareCommandRepository(this._database);

  final AppDatabase _database;

  Future<void> record({
    required String id,
    required String? diagnosisId,
    required String deviceId,
    required TrapCommandType type,
    required String requestId,
    required String status,
    String? acknowledgement,
    String? error,
  }) async {
    final database = await _database.instance;
    await database.insert('hardware_commands', {
      'id': id,
      'diagnosis_id': diagnosisId,
      'device_id': deviceId,
      'command_type': type.name,
      'request_id': requestId,
      'status': status,
      'acknowledgement': acknowledgement,
      'error': error,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });
  }
}
