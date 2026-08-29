enum TrapCommandType { status, activate, stop }

class TrapCommand {
  const TrapCommand({
    required this.type,
    required this.requestId,
    this.durationSeconds,
  });

  final TrapCommandType type;
  final String requestId;
  final int? durationSeconds;
}

class TrapAcknowledgement {
  const TrapAcknowledgement({
    required this.requestId,
    required this.success,
    required this.message,
  });

  final String requestId;
  final bool success;
  final String message;
}

abstract final class TrapProtocol {
  static const version = '1';
  static const maxActivationSeconds = 30;

  static String encode(TrapCommand command) {
    if (command.type == TrapCommandType.activate) {
      final duration = command.durationSeconds;
      if (duration == null || duration < 0 || duration > maxActivationSeconds) {
        throw const FormatException('Unsafe activation duration');
      }
    }
    final action = command.type.name.toUpperCase();
    final duration = command.type == TrapCommandType.activate
        ? command.durationSeconds.toString()
        : '0';
    final payload = 'AGRI|$version|CMD|$action|$duration|${command.requestId}';
    return '$payload|${checksum(payload)}';
  }

  static TrapAcknowledgement? decodeAcknowledgement(String line) {
    final fields = line.trim().split('|');
    if (fields.length != 7 ||
        fields[0] != 'AGRI' ||
        fields[1] != version ||
        fields[2] != 'ACK') {
      return null;
    }
    final payload = fields.take(6).join('|');
    if (checksum(payload) != fields[6].toUpperCase()) return null;
    return TrapAcknowledgement(
      requestId: fields[3],
      success: fields[4] == 'OK',
      message: fields[5],
    );
  }

  static String checksum(String input) {
    var value = 0;
    for (final byte in input.codeUnits) {
      value ^= byte;
    }
    return value.toRadixString(16).padLeft(2, '0').toUpperCase();
  }
}
