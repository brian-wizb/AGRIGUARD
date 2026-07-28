import 'package:agriguard/features/devices/domain/trap_protocol.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('encodes a bounded activation command with checksum', () {
    const command = TrapCommand(
      type: TrapCommandType.activate,
      requestId: 'req-1',
      durationSeconds: 10,
    );

    final encoded = TrapProtocol.encode(command);

    expect(encoded, startsWith('AGRI|1|CMD|ACTIVATE|10|req-1|'));
    final fields = encoded.split('|');
    expect(fields.last, TrapProtocol.checksum(fields.take(6).join('|')));
  });

  test('rejects an unsafe activation duration', () {
    expect(
      () => TrapProtocol.encode(
        const TrapCommand(
          type: TrapCommandType.activate,
          requestId: 'req-2',
          durationSeconds: 31,
        ),
      ),
      throwsFormatException,
    );
  });

  test('validates an Arduino acknowledgement', () {
    const payload = 'AGRI|1|ACK|req-3|OK|ACTIVATED';
    final line = '$payload|${TrapProtocol.checksum(payload)}';

    final acknowledgement = TrapProtocol.decodeAcknowledgement(line);

    expect(acknowledgement, isNotNull);
    expect(acknowledgement!.requestId, 'req-3');
    expect(acknowledgement.success, isTrue);
    expect(acknowledgement.message, 'ACTIVATED');
  });

  test('ignores an acknowledgement with a corrupt checksum', () {
    expect(
      TrapProtocol.decodeAcknowledgement('AGRI|1|ACK|req-4|OK|ACTIVATED|00'),
      isNull,
    );
  });
}
