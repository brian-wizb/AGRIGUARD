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
          if (diagnosis.isLeaf) _DiagnosisHeader(diagnosis: diagnosis),
          Card(
            child: ListTile(
              leading: const Icon(Icons.eco_outlined),
              title: Text(
                diagnosis.isLeaf ? diagnosis.plantName : context.tr('notLeaf'),
              ),
              subtitle: Text(diagnosis.summary),
            ),
          ),
          if (diagnosis.isLeaf)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('primaryAssessment'),
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      diagnosis.conditionName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (diagnosis.isLeaf)
            _ResultSection(
              title: context.tr('visibleSigns'),
              items: diagnosis.symptoms,
            ),
          if (diagnosis.isLeaf)
            _ResultSection(
              title: context.tr('recommendedTreatment'),
              items: diagnosis.recommendedActions,
              icon: Icons.health_and_safety_outlined,
            ),
          if (diagnosis.isLeaf)
            _ResultSection(
              title: context.tr('preventionAdvice'),
              items: diagnosis.preventionActions,
              icon: Icons.shield_outlined,
            ),
          if (diagnosis.isLeaf) _PestRiskCard(diagnosis: diagnosis),
          if (diagnosis.isLeaf)
            _ResultSection(
              title: context.tr('alternativeDiagnoses'),
              items: diagnosis.alternativeDiagnoses,
              icon: Icons.compare_arrows,
            ),
          if (diagnosis.isLeaf)
            _ResultSection(
              title: context.tr('precautions'),
              items: diagnosis.precautions,
              icon: Icons.warning_amber_outlined,
            ),
          if (diagnosis.isLeaf && diagnosis.trapActionApplicable)
            _TrapActionCard(diagnosisId: diagnosis.id),
          if (diagnosis.isLeaf)
            Card(
              child: ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(context.tr('aiDisclaimer')),
                subtitle: Text(
                  '${diagnosis.model} • ${diagnosis.promptVersion}',
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DiagnosisHeader extends StatelessWidget {
  const _DiagnosisHeader({required this.diagnosis});

  final Diagnosis diagnosis;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final score = diagnosis.confidenceScore;
    final color = switch (diagnosis.category) {
      DiagnosisCategory.healthy => Colors.green,
      DiagnosisCategory.disease => Colors.orange.shade800,
      DiagnosisCategory.pest => Colors.red.shade700,
      DiagnosisCategory.unknown => Colors.blueGrey,
    };
    return Card(
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.55),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('agriGuardInsights'),
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              context.tr('result_${diagnosis.category.name}'),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(context.tr('guidanceConfidence')),
            const SizedBox(height: 18),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: score / 100,
                minHeight: 12,
                color: color,
                backgroundColor: color.withValues(alpha: 0.15),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${context.tr('confidence')}: $score% '
              '(${context.tr('confidence_${diagnosis.confidence.name}')})',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PestRiskCard extends StatelessWidget {
  const _PestRiskCard({required this.diagnosis});

  final Diagnosis diagnosis;

  @override
  Widget build(BuildContext context) {
    if (diagnosis.pestRisk == 'none' && diagnosis.likelyPests.isEmpty) {
      return const SizedBox.shrink();
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bug_report_outlined),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${context.tr('pestRisk')}: '
                    '${context.tr('risk_${diagnosis.pestRisk}')}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            if (diagnosis.likelyPests.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                context.tr('likelyPests'),
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              for (final pest in diagnosis.likelyPests)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text('•  $pest'),
                ),
            ],
          ],
        ),
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
  const _ResultSection({
    required this.title,
    required this.items,
    this.icon = Icons.check_circle_outline,
  });

  final String title;
  final List<String> items;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
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
