import 'dart:convert';

import 'package:agriguard/features/diagnosis/data/openai_diagnosis_gateway.dart';
import 'package:agriguard/features/diagnosis/domain/diagnosis.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('parses a structured leaf diagnosis response', () async {
    final client = MockClient((request) async {
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      expect(body['model'], isNotEmpty);
      expect(body['input'], isA<List<dynamic>>());
      expect(
        ((body['text'] as Map<String, dynamic>)['format']
            as Map<String, dynamic>)['type'],
        'json_schema',
      );
      return http.Response(
        jsonEncode({
          'id': 'resp_test',
          'model': 'gpt-test',
          'output': [
            {
              'type': 'message',
              'content': [
                {
                  'type': 'output_text',
                  'text': jsonEncode({
                    'is_leaf': true,
                    'image_quality': 'good',
                    'plant_name': 'Spinach',
                    'condition_code': 'healthy',
                    'condition_name': 'Healthy leaf',
                    'category': 'healthy',
                    'confidence_band': 'high',
                    'summary': 'No visible disease signs.',
                    'symptoms': <String>[],
                    'recommended_actions': ['Continue monitoring.'],
                    'precautions': ['Inspect both sides of the leaf.'],
                    'trap_action_applicable': false,
                  }),
                },
              ],
            },
          ],
        }),
        200,
      );
    });
    final gateway = OpenAiDiagnosisGateway(
      client: client,
      apiKey: 'test-key',
      model: 'gpt-test',
    );
    final diagnosis = await gateway.analyzeLeaf(
      imageBytes: [1, 2, 3],
      mimeType: 'image/jpeg',
      languageCode: 'en',
    );

    expect(diagnosis.id, 'resp_test');
    expect(diagnosis.category, DiagnosisCategory.healthy);
    expect(diagnosis.plantName, 'Spinach');
  });

  test('diagnosis failure retains a localizable error code', () {
    const failure = DiagnosisFailure('networkError');
    expect(failure.code, 'networkError');
  });
}
