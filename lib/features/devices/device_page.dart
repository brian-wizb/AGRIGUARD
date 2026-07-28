import 'package:flutter/material.dart';

import '../../app/app_localizations.dart';
import 'application/hardware_controller.dart';
import 'domain/hardware_transport.dart';

class DevicePage extends StatefulWidget {
  const DevicePage({super.key});

  @override
  State<DevicePage> createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  final _controller = HardwareController.instance;

  Future<void> _runCommand(Future<void> Function() command) async {
    try {
      await command();
      if (mounted) _message(context.tr('commandAcknowledged'));
    } on HardwareCommandFailure catch (error) {
      if (mounted) _message(context.tr(error.code));
    }
  }

  void _message(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final connected =
            _controller.state == HardwareConnectionState.connected;
        final working =
            _controller.state == HardwareConnectionState.discovering ||
            _controller.state == HardwareConnectionState.connecting;
        return RefreshIndicator(
          onRefresh: _controller.discover,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        connected ? Icons.usb : Icons.usb_off,
                        size: 64,
                        color: connected
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        context.tr('trapTitle'),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        connected
                            ? _controller.connectedDevice!.name
                            : context.tr('notConnected'),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      if (connected)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () => _runCommand(
                                () async => _controller.requestStatus(),
                              ),
                              icon: const Icon(Icons.monitor_heart_outlined),
                              label: Text(context.tr('checkStatus')),
                            ),
                            FilledButton.tonalIcon(
                              key: const Key('emergencyStopButton'),
                              onPressed: () =>
                                  _runCommand(() async => _controller.stop()),
                              icon: const Icon(Icons.stop_circle_outlined),
                              label: Text(context.tr('emergencyStop')),
                            ),
                            TextButton(
                              onPressed: _controller.disconnect,
                              child: Text(context.tr('disconnect')),
                            ),
                          ],
                        )
                      else
                        FilledButton.icon(
                          onPressed: working ? null : _controller.discover,
                          icon: const Icon(Icons.refresh),
                          label: Text(context.tr('findUsbDevices')),
                        ),
                      if (working) ...[
                        const SizedBox(height: 16),
                        const CircularProgressIndicator(),
                      ],
                    ],
                  ),
                ),
              ),
              if (_controller.errorCode != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    context.tr(_controller.errorCode!),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                context.tr('availableUsbDevices'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (!working && _controller.devices.isEmpty)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: Text(context.tr('noUsbDevices')),
                    subtitle: Text(context.tr('usbConnectionHint')),
                  ),
                ),
              for (final device in _controller.devices)
                _DeviceTile(
                  device: device,
                  connected: _controller.connectedDevice?.id == device.id,
                  onConnect: working ? null : () => _controller.connect(device),
                ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.shield_outlined),
                  title: Text(context.tr('hardwareSafetyTitle')),
                  subtitle: Text(context.tr('hardwareSafetyDescription')),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DeviceTile extends StatelessWidget {
  const _DeviceTile({
    required this.device,
    required this.connected,
    required this.onConnect,
  });

  final HardwareDeviceInfo device;
  final bool connected;
  final VoidCallback? onConnect;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.usb),
        title: Text(device.name),
        subtitle: Text(device.description),
        trailing: connected
            ? const Icon(Icons.check_circle)
            : FilledButton.tonal(
                onPressed: onConnect,
                child: Text(context.tr('connect')),
              ),
      ),
    );
  }
}
