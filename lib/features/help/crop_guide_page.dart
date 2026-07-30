import 'package:flutter/material.dart';

import '../../app/app_localizations.dart';

class CropGuidePage extends StatelessWidget {
  const CropGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('cropGuide'))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  const Icon(Icons.crop_free, size: 58),
                  const SizedBox(height: 12),
                  Text(
                    context.tr('cropGuideIntro'),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const _GuideStep(
            Icons.wb_sunny_outlined,
            'guideLightTitle',
            'guideLight',
          ),
          const _GuideStep(
            Icons.center_focus_strong,
            'guideFrameTitle',
            'guideFrame',
          ),
          const _GuideStep(
            Icons.cleaning_services_outlined,
            'guideCleanTitle',
            'guideClean',
          ),
          const _GuideStep(
            Icons.flip_camera_android,
            'guideSidesTitle',
            'guideSides',
          ),
          const _GuideStep(Icons.block, 'guideAvoidTitle', 'guideAvoid'),
        ],
      ),
    );
  }
}

class _GuideStep extends StatelessWidget {
  const _GuideStep(this.icon, this.titleKey, this.bodyKey);
  final IconData icon;
  final String titleKey;
  final String bodyKey;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(context.tr(titleKey)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(context.tr(bodyKey)),
        ),
      ),
    );
  }
}
