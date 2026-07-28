import 'package:flutter/material.dart';

import '../../app/app_controller.dart';
import '../../app/app_localizations.dart';
import '../../core/storage/app_database.dart';
import '../diagnosis/data/diagnosis_repository.dart';
import '../diagnosis/domain/diagnosis.dart';
import '../diagnosis/presentation/diagnosis_result_page.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = AppControllerScope.of(context).currentUser!.id;
    return FutureBuilder<List<Diagnosis>>(
      future: DiagnosisRepository(AppDatabase()).listForUser(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text(context.tr('historyLoadFailed')));
        }
        final diagnoses = snapshot.data ?? const [];
        if (diagnoses.isEmpty) {
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
                  Text(context.tr('emptyHistory'), textAlign: TextAlign.center),
                ],
              ),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: diagnoses.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final diagnosis = diagnoses[index];
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  child: Icon(
                    diagnosis.category == DiagnosisCategory.healthy
                        ? Icons.check
                        : Icons.eco_outlined,
                  ),
                ),
                title: Text(diagnosis.conditionName),
                subtitle: Text(
                  '${diagnosis.plantName} • '
                  '${diagnosis.createdAt.toLocal().toString().split('.').first}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => DiagnosisResultPage(diagnosis: diagnosis),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
