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

  Future<void> _runCommand(Future<dynamic> Function() command) async {
    try {
      final acknowledgement = await command();
      if (mounted) _message(acknowledgement.message);
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
                      if (connected) _TrapStatus(controller: _controller),
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
                            FilledButton.icon(
                              key: const Key('activateTrapFromDevicePage'),
                              onPressed: () => _runCommand(
                                () => _controller.activate(
                                  diagnosisId: null,
                                  durationSeconds: 0,
                                ),
                              ),
                              icon: const Icon(Icons.play_arrow),
                              label: Text(context.tr('activateTrap')),
                            ),
                            FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
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

class _TrapStatus extends StatelessWidget {
  const _TrapStatus({required this.controller});

  final HardwareController controller;

  @override
  Widget build(BuildContext context) {
    final servoState = controller.isTrapOpen == null
        ? 'Unknown Ã¢â‚¬â€ tap Check status'
        : controller.isTrapOpen!
        ? 'OPEN'
        : 'CLOSED';
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Column(
          children: [
            ListTile(
              leading: Icon(
                controller.isTrapOpen == true
                    ? Icons.lock_open_outlined
                    : Icons.lock_outline,
              ),
              title: Text('Servo: $servoState'),
              subtitle: Text(
                'IR detections: ${controller.detectedCount ?? 'Not checked'}',
              ),
            ),
            if (controller.lastCommandMessage != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Last Arduino response: ${controller.lastCommandMessage}',
                  ),
                ),
              ),
          ],
        ),
      ),
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
