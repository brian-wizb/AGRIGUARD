import 'package:flutter/material.dart';

import '../../app/app_controller.dart';
import '../../app/app_localizations.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    required this.onScan,
    required this.onHistory,
    required this.onDevices,
    required this.onCropGuide,
    required this.onHelp,
    super.key,
  });

  final VoidCallback onScan;
  final VoidCallback onHistory;
  final VoidCallback onDevices;
  final VoidCallback onCropGuide;
  final VoidCallback onHelp;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final username = AppControllerScope.of(context).currentUser!.username;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [theme.colorScheme.primary, theme.colorScheme.tertiary],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.eco, color: theme.colorScheme.onPrimary, size: 38),
              const SizedBox(height: 18),
              Text(
                '${context.tr('welcome')}, $username!',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.tr('homeIntro'),
                style: TextStyle(color: theme.colorScheme.onPrimary),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                key: const Key('homeScanButton'),
                onPressed: onScan,
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.surface,
                  foregroundColor: theme.colorScheme.primary,
                ),
                icon: const Icon(Icons.document_scanner_outlined),
                label: Text(context.tr('scanTitle')),
              ),
              const SizedBox(height: 10),
              Text(
                context.tr('noCropSelection'),
                style: TextStyle(color: theme.colorScheme.onPrimary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          context.tr('quickActions'),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.25,
          children: [
            _ActionCard(Icons.document_scanner_outlined, 'scan', onScan),
            _ActionCard(Icons.history, 'history', onHistory),
            _ActionCard(Icons.crop_free, 'cropGuide', onCropGuide),
            _ActionCard(Icons.help_outline, 'help', onHelp),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            onTap: onDevices,
            leading: const CircleAvatar(child: Icon(Icons.cable)),
            title: Text(context.tr('trapTitle')),
            subtitle: Text(context.tr('trapDescription')),
            trailing: const Icon(Icons.chevron_right),
          ),
        ),
        Card(
          color: theme.colorScheme.primaryContainer.withValues(alpha: .45),
          child: ListTile(
            leading: const Icon(Icons.lightbulb_outline),
            title: Text(context.tr('photoTipTitle')),
            subtitle: Text(context.tr('photoTip')),
            onTap: onCropGuide,
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard(this.icon, this.labelKey, this.onTap);
  final IconData icon;
  final String labelKey;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 34,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 10),
              Text(context.tr(labelKey), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
