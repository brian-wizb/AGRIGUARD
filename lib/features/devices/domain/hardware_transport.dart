abstract interface class HardwareTransport {
  Stream<String> get lines;
  bool get isConnected;

  Future<List<HardwareDeviceInfo>> discover();
  Future<void> connect(String deviceId);
  Future<void> disconnect();
  Future<void> writeLine(String line);
}

class HardwareDeviceInfo {
  const HardwareDeviceInfo({
    required this.id,
    required this.name,
    required this.description,
  });

  final String id;
  final String name;
  final String description;
}
