import 'package:flutter/material.dart';

import '../../app/app_localizations.dart';
import 'crop_guide_page.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('help'))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: ListTile(
              contentPadding: const EdgeInsets.all(18),
              leading: const Icon(Icons.crop_free, size: 40),
              title: Text(context.tr('cropGuide')),
              subtitle: Text(context.tr('cropGuideIntro')),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const CropGuidePage()),
              ),
            ),
          ),
          const _HelpTile('helpScanTitle', 'helpScanBody'),
          const _HelpTile('helpResultsTitle', 'helpResultsBody'),
          const _HelpTile('helpPrivacyTitle', 'helpPrivacyBody'),
          const _HelpTile('helpSafetyTitle', 'helpSafetyBody'),
        ],
      ),
    );
  }
}

class _HelpTile extends StatelessWidget {
  const _HelpTile(this.titleKey, this.bodyKey);
  final String titleKey;
  final String bodyKey;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        title: Text(context.tr(titleKey)),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(context.tr(bodyKey)),
          ),
        ],
      ),
    );
  }
}
