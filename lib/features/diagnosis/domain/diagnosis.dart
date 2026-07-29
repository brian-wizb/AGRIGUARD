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
    required this.confidenceScore,
    required this.imageQuality,
    required this.summary,
    required this.symptoms,
    required this.recommendedActions,
    required this.preventionActions,
    required this.pestRisk,
    required this.likelyPests,
    required this.alternativeDiagnoses,
    required this.precautions,
    required this.trapActionApplicable,
    required this.isLeaf,
    required this.createdAt,
    required this.model,
    required this.promptVersion,
    this.imagePath,
  });

  final String id;
  final String plantName;
  final String conditionCode;
  final String conditionName;
  final DiagnosisCategory category;
  final ConfidenceBand confidence;
  final int confidenceScore;
  final String imageQuality;
  final String summary;
  final List<String> symptoms;
  final List<String> recommendedActions;
  final List<String> preventionActions;
  final String pestRisk;
  final List<String> likelyPests;
  final List<String> alternativeDiagnoses;
  final List<String> precautions;
  final bool trapActionApplicable;
  final bool isLeaf;
  final DateTime createdAt;
  final String model;
  final String promptVersion;
  final String? imagePath;

  bool get canPresentDiagnosis => isLeaf && imageQuality != 'unusable';

  Diagnosis copyWith({String? imagePath}) => Diagnosis(
    id: id,
    plantName: plantName,
    conditionCode: conditionCode,
    conditionName: conditionName,
    category: category,
    confidence: confidence,
    confidenceScore: confidenceScore,
    imageQuality: imageQuality,
    summary: summary,
    symptoms: symptoms,
    recommendedActions: recommendedActions,
    preventionActions: preventionActions,
    pestRisk: pestRisk,
    likelyPests: likelyPests,
    alternativeDiagnoses: alternativeDiagnoses,
    precautions: precautions,
    trapActionApplicable: trapActionApplicable,
    isLeaf: isLeaf,
    createdAt: createdAt,
    model: model,
    promptVersion: promptVersion,
    imagePath: imagePath ?? this.imagePath,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'plant_name': plantName,
    'condition_code': conditionCode,
    'condition_name': conditionName,
    'category': category.name,
    'confidence_band': confidence.name,
    'confidence_score': confidenceScore,
    'image_quality': imageQuality,
    'summary': summary,
    'symptoms': symptoms,
    'recommended_actions': recommendedActions,
    'prevention_actions': preventionActions,
    'pest_risk': pestRisk,
    'likely_pests': likelyPests,
    'alternative_diagnoses': alternativeDiagnoses,
    'precautions': precautions,
    'trap_action_applicable': trapActionApplicable,
    'is_leaf': isLeaf,
    'created_at': createdAt.toIso8601String(),
    'model': model,
    'prompt_version': promptVersion,
    'image_path': imagePath,
  };

  factory Diagnosis.fromJson(
    Map<String, dynamic> json, {
    required String id,
    required String model,
    required String promptVersion,
    String? imagePath,
    DateTime? createdAt,
  }) {
    final score =
        (json['confidence_score'] as num?)?.round().clamp(0, 99).toInt() ??
        _scoreForBand(json['confidence_band'] as String);
    final confidence = score >= 80
        ? ConfidenceBand.high
        : score >= 55
        ? ConfidenceBand.medium
        : ConfidenceBand.low;
    return Diagnosis(
      id: id,
      plantName: json['plant_name'] as String,
      conditionCode: json['condition_code'] as String,
      conditionName: json['condition_name'] as String,
      category: DiagnosisCategory.values.byName(json['category'] as String),
      confidence: confidence,
      confidenceScore: score,
      imageQuality: json['image_quality'] as String,
      summary: json['summary'] as String,
      symptoms: List<String>.from(json['symptoms'] as List),
      recommendedActions: List<String>.from(
        json['recommended_actions'] as List,
      ),
      preventionActions: List<String>.from(
        json['prevention_actions'] as List? ?? const <String>[],
      ),
      pestRisk: json['pest_risk'] as String? ?? 'unknown',
      likelyPests: List<String>.from(
        json['likely_pests'] as List? ?? const <String>[],
      ),
      alternativeDiagnoses: List<String>.from(
        json['alternative_diagnoses'] as List? ?? const <String>[],
      ),
      precautions: List<String>.from(json['precautions'] as List),
      trapActionApplicable: json['trap_action_applicable'] as bool,
      isLeaf: json['is_leaf'] as bool,
      createdAt: createdAt ?? DateTime.now().toUtc(),
      model: model,
      promptVersion: promptVersion,
      imagePath: imagePath,
    );
  }

  static int _scoreForBand(String band) => switch (band) {
    'high' => 85,
    'medium' => 65,
    _ => 40,
  };
}
