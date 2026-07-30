import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/diagnosis.dart';
import 'diagnosis_gateway.dart';

class OpenAiDiagnosisGateway implements DiagnosisGateway {
  OpenAiDiagnosisGateway({http.Client? client, String? apiKey, String? model})
    : _client = client ?? http.Client(),
      _apiKey = apiKey ?? OpenAiBuildConfig.apiKey,
      _model = model ?? OpenAiBuildConfig.model;

  static const promptVersion = 'leaf-diagnosis-v3';
  static final _endpoint = Uri.parse('https://api.openai.com/v1/responses');

  final http.Client _client;
  final String _apiKey;
  final String _model;

  @override
  Future<Diagnosis> analyzeLeaf({
    required List<int> imageBytes,
    required String mimeType,
    required String languageCode,
  }) async {
    if (_apiKey.trim().isEmpty) {
      throw const DiagnosisFailure('missingApiKey');
    }
    if (imageBytes.isEmpty || imageBytes.length > 8 * 1024 * 1024) {
      throw const DiagnosisFailure('invalidImage');
    }

    final language = languageCode == 'sw' ? 'Swahili' : 'English';
    final payload = {
      'model': _model,
      'store': false,
      'reasoning': {'effort': 'medium'},
      'max_output_tokens': 1600,
      'instructions':
          'Role: You are a practical plant-pathology and crop-pest screening '
          'assistant for smallholder farmers in Tanzania. '
          'Goal: Give the most useful evidence-based assessment possible from '
          'the submitted image. Use visible lesion shape, color, distribution, '
          'leaf deformation, chlorosis, necrosis, holes, mines, webbing, eggs, '
          'insects, frass, and crop appearance. Consider common East African '
          'diseases, pests, nutrient deficiencies, water stress, sun or chemical '
          'injury, and physical damage. Reliability rules: distinguish symptoms '
          'actually visible in the image from diagnostic inference; do not report '
          'a symptom unless it is visible; check whether the symptom distribution '
          'fits the proposed diagnosis; compare at least three plausible causes '
          'internally before selecting the best-supported primary result; reduce '
          'confidence when the crop identity, image quality, or discriminating '
          'features are uncertain. Do not default to unknown merely because '
          'evidence is imperfect. When one diagnosis is most plausible, return it '
          'with a calibrated confidence_score from 0 to 100 and a matching band: '
          'high is 80-100, medium is 55-79, and low is 1-54. Never use 100. '
          'List up to three close alternative diagnoses with the observation '
          'needed to distinguish each one. Use unknown '
          'only when the image is not a usable plant leaf or no explanation is '
          'meaningfully better supported than the alternatives. Never claim that '
          'an image-only screening is laboratory confirmation. '
          'Return all farmer-facing text in $language. Give practical, locally '
          'appropriate treatment and prevention steps. Prefer integrated pest '
          'management: inspection, isolation, sanitation, pruning, resistant '
          'varieties, irrigation or nutrient correction, biological or physical '
          'controls, monitoring, and an agricultural extension officer. Name a '
          'chemical class only when justified, and tell the farmer to follow a '
          'locally registered product label and professional guidance. Never '
          'invent a pesticide, restricted chemical, exact product, concentration, '
          'or dosage. Set pest_risk to none, low, medium, or high based on evidence '
          'of pest involvement, and list likely pests only when relevant. '
          'trap_action_applicable is true when the likely pest can reasonably be '
          'managed or monitored with a generic physical trap, even if the pest '
          'itself is not visible but its characteristic damage is visible.',
      'input': [
        {
          'role': 'user',
          'content': [
            {
              'type': 'input_text',
              'text':
                  'Inspect the entire image carefully. Identify the likely crop or '
                  'plant when possible, assess image quality, characterize the '
                  'visible symptom pattern, compare disease, pest, environmental, '
                  'nutritional, and physical causes, and return the most likely '
                  'primary assessment in the required schema. Make the result '
                  'specific and useful when the evidence supports it; express '
                  'remaining uncertainty through confidence and close alternatives.',
            },
            {
              'type': 'input_image',
              'image_url': 'data:$mimeType;base64,${base64Encode(imageBytes)}',
              'detail': 'high',
            },
          ],
        },
      ],
      'text': {
        'verbosity': 'medium',
        'format': {
          'type': 'json_schema',
          'name': 'leaf_diagnosis',
          'strict': true,
          'schema': _schema,
        },
      },
    };

    http.Response response;
    try {
      response = await _client
          .post(
            _endpoint,
            headers: {
              'Authorization': 'Bearer $_apiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 75));
    } on TimeoutException {
      throw const DiagnosisFailure('requestTimeout');
    } on Exception {
      throw const DiagnosisFailure('networkError');
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw const DiagnosisFailure('invalidApiKey');
    }
    if (response.statusCode == 429) {
      throw const DiagnosisFailure('rateLimited');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const DiagnosisFailure('analysisFailed');
    }

    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['status'] == 'incomplete') {
        throw const DiagnosisFailure('analysisFailed');
      }
      final output = body['output'] as List<dynamic>? ?? const [];
      final textParts = output
          .whereType<Map<String, dynamic>>()
          .expand(
            (item) => (item['content'] as List<dynamic>? ?? const [])
                .whereType<Map<String, dynamic>>(),
          )
          .where((item) => item['type'] == 'output_text')
          .map((item) => item['text'])
          .whereType<String>();
      final outputText =
          body['output_text'] as String? ??
          (textParts.isEmpty ? null : textParts.join());
      if (outputText == null || outputText.trim().isEmpty) {
        throw const DiagnosisFailure('invalidResponse');
      }
      final result = jsonDecode(outputText);
      return Diagnosis.fromJson(
        result as Map<String, dynamic>,
        id: body['id'] as String,
        model: body['model'] as String? ?? _model,
        promptVersion: promptVersion,
      );
    } on DiagnosisFailure {
      rethrow;
    } on Exception {
      throw const DiagnosisFailure('invalidResponse');
    }
  }

  static const Map<String, Object> _schema = {
    'type': 'object',
    'additionalProperties': false,
    'properties': {
      'is_leaf': {'type': 'boolean'},
      'image_quality': {
        'type': 'string',
        'enum': ['good', 'limited', 'unusable'],
      },
      'plant_name': {'type': 'string'},
      'condition_code': {'type': 'string'},
      'condition_name': {'type': 'string'},
      'category': {
        'type': 'string',
        'enum': ['healthy', 'disease', 'pest', 'unknown'],
      },
      'confidence_band': {
        'type': 'string',
        'enum': ['high', 'medium', 'low'],
      },
      'summary': {'type': 'string'},
      'confidence_score': {'type': 'integer', 'minimum': 0, 'maximum': 99},
      'symptoms': {
        'type': 'array',
        'items': {'type': 'string'},
        'maxItems': 5,
      },
      'recommended_actions': {
        'type': 'array',
        'items': {'type': 'string'},
        'maxItems': 5,
      },
      'prevention_actions': {
        'type': 'array',
        'items': {'type': 'string'},
        'maxItems': 5,
      },
      'pest_risk': {
        'type': 'string',
        'enum': ['none', 'low', 'medium', 'high', 'unknown'],
      },
      'likely_pests': {
        'type': 'array',
        'items': {'type': 'string'},
        'maxItems': 4,
      },
      'alternative_diagnoses': {
        'type': 'array',
        'items': {'type': 'string'},
        'maxItems': 3,
      },
      'precautions': {
        'type': 'array',
        'items': {'type': 'string'},
        'maxItems': 4,
      },
      'trap_action_applicable': {'type': 'boolean'},
    },
    'required': [
      'is_leaf',
      'image_quality',
      'plant_name',
      'condition_code',
      'condition_name',
      'category',
      'confidence_band',
      'confidence_score',
      'summary',
      'symptoms',
      'recommended_actions',
      'prevention_actions',
      'pest_risk',
      'likely_pests',
      'alternative_diagnoses',
      'precautions',
      'trap_action_applicable',
    ],
  };
}

class DiagnosisFailure implements Exception {
  const DiagnosisFailure(this.code);

  final String code;
}
