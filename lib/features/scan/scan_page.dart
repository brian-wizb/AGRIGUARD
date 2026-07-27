import 'package:flutter/material.dart';

import '../../app/app_localizations.dart';

class ScanPage extends StatelessWidget {
  const ScanPage({super.key});

  void _showPlaceholder(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.center_focus_strong,
                    size: 56,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  context.tr('scanTitle'),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  context.tr('scanDescription'),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  context.tr('noCropSelection'),
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    key: const Key('cameraButton'),
                    onPressed: () => _showPlaceholder(
                      context,
                      context.tr('cameraComing'),
                    ),
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: Text(context.tr('camera')),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showPlaceholder(
                      context,
                      context.tr('galleryComing'),
                    ),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: Text(context.tr('gallery')),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.task_alt),
            title: Text(context.tr('phaseOne')),
            subtitle: Text(context.tr('phaseOneDescription')),
          ),
        ),
      ],
    );
  }
}
