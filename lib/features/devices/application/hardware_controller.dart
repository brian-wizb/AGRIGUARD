import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../../core/storage/app_database.dart';
import '../data/hardware_command_repository.dart';
import '../data/usb_serial_transport.dart';
import '../domain/hardware_transport.dart';
import '../domain/trap_protocol.dart';

enum HardwareConnectionState {
  disconnected,
  discovering,
  connecting,
  connected,
}

class HardwareController extends ChangeNotifier {
  HardwareController(this._transport, this._repository) {
    _lineSubscription = _transport.lines.listen(_onLine);
  }

  static final HardwareController instance = HardwareController(
    UsbSerialTransport(),
    HardwareCommandRepository(AppDatabase()),
  );

  final HardwareTransport _transport;
  final HardwareCommandRepository _repository;
  final Map<String, Completer<TrapAcknowledgement>> _pending = {};
  late final StreamSubscription<String> _lineSubscription;
  Timer? _statusTimer;

  HardwareConnectionState state = HardwareConnectionState.disconnected;
  List<HardwareDeviceInfo> devices = const [];
  HardwareDeviceInfo? connectedDevice;
  String? errorCode;
  int? detectedCount;
  bool? isTrapOpen;
  String? lastCommandMessage;

  Future<void> discover() async {
    state = HardwareConnectionState.discovering;
    errorCode = null;
    notifyListeners();
    try {
      devices = await _transport.discover();
      state = HardwareConnectionState.disconnected;
    } on Exception {
      errorCode = 'usbDiscoveryFailed';
      state = HardwareConnectionState.disconnected;
    }
    notifyListeners();
  }

  Future<void> connect(HardwareDeviceInfo device) async {
    state = HardwareConnectionState.connecting;
    errorCode = null;
    notifyListeners();
    try {
      await _transport.connect(device.id);
      connectedDevice = device;
      state = HardwareConnectionState.connected;
      _statusTimer = Timer.periodic(const Duration(seconds: 2), (_) {
        if (state == HardwareConnectionState.connected) {
          requestStatus().catchError((_) {});
        }
      });
    } on Exception {
      errorCode = 'usbConnectionFailed';
      state = HardwareConnectionState.disconnected;
    }
    notifyListeners();
  }

  Future<void> disconnect() async {
    _statusTimer?.cancel();
    _statusTimer = null;
    await _transport.disconnect();
    connectedDevice = null;
    state = HardwareConnectionState.disconnected;
    for (final completer in _pending.values) {
      if (!completer.isCompleted) {
        completer.completeError(StateError('Disconnected'));
      }
    }
    _pending.clear();
    notifyListeners();
  }

  Future<TrapAcknowledgement> activate({
    required String? diagnosisId,
    int durationSeconds = 0,
  }) {
    return _send(
      type: TrapCommandType.activate,
      diagnosisId: diagnosisId,
      durationSeconds: durationSeconds,
    );
  }

  Future<TrapAcknowledgement> stop() =>
      _send(type: TrapCommandType.stop, diagnosisId: null);

  Future<TrapAcknowledgement> requestStatus() =>
      _send(type: TrapCommandType.status, diagnosisId: null);

  Future<TrapAcknowledgement> _send({
    required TrapCommandType type,
    required String? diagnosisId,
    int? durationSeconds,
  }) async {
    final device = connectedDevice;
    if (device == null || !_transport.isConnected) {
      throw const HardwareCommandFailure('deviceNotConnected');
    }
    final requestId = _newId();
    final command = TrapCommand(
      type: type,
      requestId: requestId,
      durationSeconds: durationSeconds,
    );
    final completer = Completer<TrapAcknowledgement>();
    _pending[requestId] = completer;
    try {
      await _transport.writeLine(TrapProtocol.encode(command));
      final acknowledgement = await completer.future.timeout(
        const Duration(seconds: 4),
      );
      _applyAcknowledgement(acknowledgement);
      await _repository.record(
        id: _newId(),
        diagnosisId: diagnosisId,
        deviceId: device.id,
        type: type,
        requestId: requestId,
        status: acknowledgement.success ? 'acknowledged' : 'rejected',
        acknowledgement: acknowledgement.message,
      );
      if (!acknowledgement.success) {
        throw const HardwareCommandFailure('commandRejected');
      }
      return acknowledgement;
    } on TimeoutException {
      await _repository.record(
        id: _newId(),
        diagnosisId: diagnosisId,
        deviceId: device.id,
        type: type,
        requestId: requestId,
        status: 'timeout',
        error: 'No acknowledgement within 4 seconds',
      );
      throw const HardwareCommandFailure('commandTimeout');
    } on HardwareCommandFailure {
      rethrow;
    } on Exception {
      await _repository.record(
        id: _newId(),
        diagnosisId: diagnosisId,
        deviceId: device.id,
        type: type,
        requestId: requestId,
        status: 'failed',
        error: 'Transport failure',
      );
      throw const HardwareCommandFailure('commandFailed');
    } finally {
      _pending.remove(requestId);
    }
  }

  void _onLine(String line) {
    final acknowledgement = TrapProtocol.decodeAcknowledgement(line);
    if (acknowledgement == null) return;
    final completer = _pending[acknowledgement.requestId];
    if (completer != null && !completer.isCompleted) {
      completer.complete(acknowledgement);
    }
  }

  void _applyAcknowledgement(TrapAcknowledgement acknowledgement) {
    lastCommandMessage = acknowledgement.message;
    final status = RegExp(
      r'^COUNT_(\d+)_SERVO_(OPEN|CLOSED)$',
    ).firstMatch(acknowledgement.message);
    if (status != null) {
      detectedCount = int.parse(status.group(1)!);
      isTrapOpen = status.group(2) == 'OPEN';
    } else if (acknowledgement.message == 'ACTIVATED') {
      isTrapOpen = true;
    } else if (acknowledgement.message == 'STOPPED') {
      isTrapOpen = false;
    }
    notifyListeners();
  }

  String _newId() {
    final random = Random.secure().nextInt(1 << 32).toRadixString(16);
    return '${DateTime.now().microsecondsSinceEpoch}-$random';
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _lineSubscription.cancel();
    _transport.disconnect();
    super.dispose();
  }
}

class HardwareCommandFailure implements Exception {
  const HardwareCommandFailure(this.code);

  final String code;
}
