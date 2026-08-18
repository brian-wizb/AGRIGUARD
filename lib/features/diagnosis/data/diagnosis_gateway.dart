import '../domain/diagnosis.dart';

abstract interface class DiagnosisGateway {
  Future<Diagnosis> analyzeLeaf({
    required List<int> imageBytes,
    required String mimeType,
    required String languageCode,
  });
}

/// Phase 1 boundary for direct OpenAI integration.
///
/// The implementation added in Phase 3 will read the demonstration key from
/// build configuration, send the leaf image, and validate structured output.
abstract final class OpenAiBuildConfig {
  static const apiKey = String.fromEnvironment(
    'OPENAI_API_KEY',
    defaultValue:
        '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',
  );
  static const model = String.fromEnvironment(
    'OPENAI_MODEL',
    defaultValue: 'gpt-5.6-sol',
  );

  static bool get hasApiKey => apiKey.trim().isNotEmpty;
}
