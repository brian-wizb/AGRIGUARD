import 'dart:io';

import 'package:flutter/material.dart';

import '../../../app/app_localizations.dart';
import '../../devices/application/hardware_controller.dart';
import '../domain/diagnosis.dart';

class DiagnosisResultPage extends StatelessWidget {
  const DiagnosisResultPage({required this.diagnosis, super.key});

  final Diagnosis diagnosis;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('diagnosisResult'))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (diagnosis.imagePath != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.file(
                File(diagnosis.imagePath!),
                height: 220,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          diagnosis.isLeaf
                              ? diagnosis.plantName
                              : context.tr('notLeaf'),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      Chip(
                        label: Text(
                          context.tr('confidence_${diagnosis.confidence.name}'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    diagnosis.conditionName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(diagnosis.summary),
                ],
              ),
            ),
          ),
          _ResultSection(
            title: context.tr('visibleSigns'),
            items: diagnosis.symptoms,
          ),
          _ResultSection(
            title: context.tr('recommendedActions'),
            items: diagnosis.recommendedActions,
          ),
          _ResultSection(
            title: context.tr('precautions'),
            items: diagnosis.precautions,
          ),
          if (diagnosis.trapActionApplicable)
            _TrapActionCard(diagnosisId: diagnosis.id),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(context.tr('aiDisclaimer')),
              subtitle: Text('${diagnosis.model} • ${diagnosis.promptVersion}'),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrapActionCard extends StatefulWidget {
  const _TrapActionCard({required this.diagnosisId});

  final String diagnosisId;

  @override
  State<_TrapActionCard> createState() => _TrapActionCardState();
}

class _TrapActionCardState extends State<_TrapActionCard> {
  bool _sending = false;

  Future<void> _confirmAndActivate() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('confirmTrapActivation')),
        content: Text(context.tr('trapActivationWarning')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.tr('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.tr('activateForTenSeconds')),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _sending = true);
    try {
      await HardwareController.instance.activate(
        diagnosisId: widget.diagnosisId,
        durationSeconds: 10,
      );
      if (mounted) _message(context.tr('commandAcknowledged'));
    } on HardwareCommandFailure catch (error) {
      if (mounted) _message(context.tr(error.code));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _message(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.pest_control, size: 40),
            const SizedBox(height: 8),
            Text(
              context.tr('trapActionAvailable'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              context.tr('trapActionDescription'),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              key: const Key('activateTrapButton'),
              onPressed: _sending ? null : _confirmAndActivate,
              icon: _sending
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.play_arrow),
              label: Text(context.tr('activateTrap')),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultSection extends StatelessWidget {
  const _ResultSection({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final item in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('•  '),
                    Expanded(child: Text(item)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
