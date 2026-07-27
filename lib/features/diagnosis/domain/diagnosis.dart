enum DiagnosisCategory { healthy, disease, pest, unknown }

enum ConfidenceBand { high, medium, low }

class Diagnosis {
  const Diagnosis({
    required this.id,
    required this.plantName,
    required this.conditionCode,
    required this.conditionName,
    required this.category,
    required this.confidence,
    required this.symptoms,
    required this.recommendedActions,
    required this.precautions,
    required this.trapActionApplicable,
    required this.createdAt,
  });

  final String id;
  final String plantName;
  final String conditionCode;
  final String conditionName;
  final DiagnosisCategory category;
  final ConfidenceBand confidence;
  final List<String> symptoms;
  final List<String> recommendedActions;
  final List<String> precautions;
  final bool trapActionApplicable;
  final DateTime createdAt;
}
