import 'package:flutter/material.dart';

import '../../app/app_localizations.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.history, size: 64),
            const SizedBox(height: 16),
            Text(
              context.tr('recentScans'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              context.tr('emptyHistory'),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
