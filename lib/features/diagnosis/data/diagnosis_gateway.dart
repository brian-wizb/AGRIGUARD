import '../domain/diagnosis.dart';

abstract interface class DiagnosisGateway {
  Future<Diagnosis> analyzeLeaf({
    required List<int> imageBytes,
    required String languageCode,
  });
}

/// Phase 1 boundary for direct OpenAI integration.
///
/// The implementation added in Phase 3 will read the demonstration key from
/// build configuration, send the leaf image, and validate structured output.
abstract final class OpenAiBuildConfig {
  static const apiKey = String.fromEnvironment('OPENAI_API_KEY');

  static bool get hasApiKey => apiKey.trim().isNotEmpty;
}
