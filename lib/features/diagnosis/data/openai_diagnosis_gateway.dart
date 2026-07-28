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

  static const promptVersion = 'leaf-diagnosis-v1';
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
      'reasoning': {'effort': 'low'},
      'max_output_tokens': 1200,
      'instructions':
          'You are an agricultural leaf-screening assistant for smallholder '
          'farmers in Tanzania. Analyze only visible evidence. Do not invent a '
          'crop, disease, pest, treatment, or certainty. Return all farmer-facing '
          'text in $language. If the image is not a leaf, is unusable, or evidence '
          'is insufficient, use category unknown, confidence low, and safe next '
          'steps. Do not prescribe restricted chemicals or dosages. '
          'trap_action_applicable is true only for a clearly visible pest problem '
          'that a generic physical trap could plausibly address.',
      'input': [
        {
          'role': 'user',
          'content': [
            {
              'type': 'input_text',
              'text':
                  'Inspect this image. Decide whether it contains a leaf, identify '
                  'the likely plant when possible, assess image quality, and screen '
                  'for visible disease or pest signs. Produce the required schema.',
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
        'verbosity': 'low',
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
      final output = body['output'] as List<dynamic>;
      final message = output.cast<Map<String, dynamic>>().firstWhere(
        (item) => item['type'] == 'message',
      );
      final content = message['content'] as List<dynamic>;
      final textPart = content.cast<Map<String, dynamic>>().firstWhere(
        (item) => item['type'] == 'output_text',
      );
      final result = jsonDecode(textPart['text'] as String);
      return Diagnosis.fromJson(
        result as Map<String, dynamic>,
        id: body['id'] as String,
        model: body['model'] as String? ?? _model,
        promptVersion: promptVersion,
      );
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
      'summary',
      'symptoms',
      'recommended_actions',
      'precautions',
      'trap_action_applicable',
    ],
  };
}

class DiagnosisFailure implements Exception {
  const DiagnosisFailure(this.code);

  final String code;
}
