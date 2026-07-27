import 'package:flutter/material.dart';

import '../../app/app_localizations.dart';

class DevicePage extends StatelessWidget {
  const DevicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Icon(Icons.cable, size: 64),
                const SizedBox(height: 16),
                Text(
                  context.tr('trapTitle'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  context.tr('trapDescription'),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Chip(
                  avatar: const Icon(Icons.circle, size: 12),
                  label: Text(context.tr('notConnected')),
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(context.tr('hardwareComing'))),
                  ),
                  icon: const Icon(Icons.bluetooth_searching),
                  label: Text(context.tr('connect')),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
