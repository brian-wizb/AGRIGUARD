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
    required this.imageQuality,
    required this.summary,
    required this.symptoms,
    required this.recommendedActions,
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
  final String imageQuality;
  final String summary;
  final List<String> symptoms;
  final List<String> recommendedActions;
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
    imageQuality: imageQuality,
    summary: summary,
    symptoms: symptoms,
    recommendedActions: recommendedActions,
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
    'image_quality': imageQuality,
    'summary': summary,
    'symptoms': symptoms,
    'recommended_actions': recommendedActions,
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
    return Diagnosis(
      id: id,
      plantName: json['plant_name'] as String,
      conditionCode: json['condition_code'] as String,
      conditionName: json['condition_name'] as String,
      category: DiagnosisCategory.values.byName(json['category'] as String),
      confidence: ConfidenceBand.values.byName(
        json['confidence_band'] as String,
      ),
      imageQuality: json['image_quality'] as String,
      summary: json['summary'] as String,
      symptoms: List<String>.from(json['symptoms'] as List),
      recommendedActions: List<String>.from(
        json['recommended_actions'] as List,
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
}
