import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:usb_serial/usb_serial.dart';

import '../domain/hardware_transport.dart';

class UsbSerialTransport implements HardwareTransport {
  final _lines = StreamController<String>.broadcast();
  final Map<String, UsbDevice> _devices = {};
  UsbPort? _port;
  StreamSubscription<Uint8List>? _subscription;
  String _buffer = '';

  @override
  Stream<String> get lines => _lines.stream;

  @override
  bool get isConnected => _port != null;

  @override
  Future<List<HardwareDeviceInfo>> discover() async {
    final devices = await UsbSerial.listDevices();
    _devices
      ..clear()
      ..addEntries(devices.map((device) => MapEntry(_idFor(device), device)));
    return devices
        .map(
          (device) => HardwareDeviceInfo(
            id: _idFor(device),
            name: device.productName ?? 'USB serial device',
            description:
                '${device.manufacturerName ?? 'Unknown manufacturer'} • '
                'VID ${device.vid?.toRadixString(16) ?? '-'} / '
                'PID ${device.pid?.toRadixString(16) ?? '-'}',
          ),
        )
        .toList();
  }

  @override
  Future<void> connect(String deviceId) async {
    await disconnect();
    final device = _devices[deviceId];
    if (device == null) throw StateError('USB device is no longer available');
    final port = await device.create();
    if (port == null || !await port.open()) {
      throw StateError('USB port could not be opened');
    }
    await port.setDTR(true);
    await port.setRTS(true);
    await port.setPortParameters(
      115200,
      UsbPort.DATABITS_8,
      UsbPort.STOPBITS_1,
      UsbPort.PARITY_NONE,
    );
    _port = port;
    _subscription = port.inputStream?.listen(
      _onBytes,
      onError: (_) => disconnect(),
      onDone: disconnect,
    );
  }

  void _onBytes(Uint8List bytes) {
    _buffer += utf8.decode(bytes, allowMalformed: true);
    while (_buffer.contains('\n')) {
      final index = _buffer.indexOf('\n');
      final line = _buffer.substring(0, index).replaceAll('\r', '');
      _buffer = _buffer.substring(index + 1);
      if (line.isNotEmpty) _lines.add(line);
    }
  }

  @override
  Future<void> writeLine(String line) async {
    final port = _port;
    if (port == null) throw StateError('No USB device connected');
    await port.write(Uint8List.fromList(utf8.encode('$line\n')));
  }

  @override
  Future<void> disconnect() async {
    await _subscription?.cancel();
    _subscription = null;
    final port = _port;
    _port = null;
    _buffer = '';
    await port?.close();
  }

  String _idFor(UsbDevice device) =>
      '${device.deviceId}:${device.vid}:${device.pid}';
}
