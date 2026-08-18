import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../../app/app_controller.dart';
import '../../app/app_localizations.dart';
import '../../core/storage/app_database.dart';
import '../diagnosis/data/diagnosis_repository.dart';
import '../diagnosis/data/openai_diagnosis_gateway.dart';
import '../diagnosis/presentation/diagnosis_result_page.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({this.onRecoveredCameraImage, super.key});

  final VoidCallback? onRecoveredCameraImage;

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final _picker = ImagePicker();
  final _gateway = OpenAiDiagnosisGateway();
  final _repository = DiagnosisRepository(AppDatabase());
  bool _busy = false;
  bool _pickingImage = false;
  XFile? _selectedImage;
  String? _errorCode;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _recoverLostCameraImage(),
      );
    }
  }

  Future<void> _pickAndAnalyze(ImageSource source) async {
    if (_busy || _pickingImage) return;
    setState(() {
      _errorCode = null;
      _pickingImage = true;
    });
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 82,
        maxWidth: 1600,
        maxHeight: 1600,
        requestFullMetadata: false,
      );
      if (picked == null || !mounted) return;
      setState(() {
        _pickingImage = false;
        _busy = true;
      });
      await _analyzeImage(picked);
    } on DiagnosisFailure catch (error) {
      if (mounted) _setError(error.code);
    } on Exception {
      if (mounted) _setError('unexpectedError');
    } finally {
      if (mounted) {
        setState(() {
          _pickingImage = false;
          _busy = false;
        });
      }
    }
  }

  Future<void> _retry() async {
    final picked = _selectedImage;
    if (picked == null || _busy) return;
    setState(() {
      _errorCode = null;
      _busy = true;
    });
    try {
      await _analyzeImage(picked);
    } on DiagnosisFailure catch (error) {
      if (mounted) _setError(error.code);
    } on Exception {
      if (mounted) _setError('unexpectedError');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _recoverLostCameraImage() async {
    try {
      final response = await _picker.retrieveLostData();
      if (!mounted || response.isEmpty) return;
      if (response.exception != null || response.file == null) {
        _setError('unexpectedError');
        return;
      }
      widget.onRecoveredCameraImage?.call();
      setState(() {
        _errorCode = null;
        _busy = true;
      });
      await _analyzeImage(response.file!);
    } on Exception {
      if (mounted) _setError('unexpectedError');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _analyzeImage(XFile picked) async {
    final imagePath = await _saveImage(picked);
    if (!mounted) return;
    setState(() => _selectedImage = XFile(imagePath));
    final mimeType = _mimeTypeFor(imagePath);
    if (mimeType == null) throw const DiagnosisFailure('invalidImage');
    final languageCode = Localizations.localeOf(context).languageCode;
    final userId = AppControllerScope.of(context).currentUser!.id;
    final bytes = await File(imagePath).readAsBytes();
    var diagnosis = await _gateway.analyzeLeaf(
      imageBytes: bytes,
      mimeType: mimeType,
      languageCode: languageCode,
    );
    diagnosis = diagnosis.copyWith(imagePath: imagePath);
    await _repository.save(userId: userId, diagnosis: diagnosis);
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DiagnosisResultPage(diagnosis: diagnosis),
      ),
    );
  }

  String? _mimeTypeFor(String filePath) {
    switch (path.extension(filePath).toLowerCase()) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.webp':
        return 'image/webp';
      default:
        return null;
    }
  }

  Future<String> _saveImage(XFile picked) async {
    final documents = await getApplicationDocumentsDirectory();
    final directory = Directory(path.join(documents.path, 'leaf_scans'));
    await directory.create(recursive: true);
    final extension = path.extension(picked.path).toLowerCase();
    final destination = path.join(
      directory.path,
      'leaf_${DateTime.now().microsecondsSinceEpoch}$extension',
    );
    await File(picked.path).copy(destination);
    return destination;
  }

  void _setError(String code) {
    setState(() => _errorCode = code);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(context.tr(code))));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      width: 112,
                      height: 112,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.center_focus_strong,
                        size: 56,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      context.tr('scanTitle'),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      context.tr('scanDescription'),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.tr('noCropSelection'),
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        key: const Key('cameraButton'),
                        onPressed: _busy || _pickingImage
                            ? null
                            : () => _pickAndAnalyze(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt_outlined),
                        label: Text(context.tr('camera')),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _busy || _pickingImage
                            ? null
                            : () => _pickAndAnalyze(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library_outlined),
                        label: Text(context.tr('gallery')),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_errorCode != null) ...[
              Card(
                color: theme.colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.error_outline),
                          const SizedBox(width: 12),
                          Expanded(child: Text(context.tr(_errorCode!))),
                        ],
                      ),
                      if (_selectedImage != null) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            key: const Key('retryScanButton'),
                            onPressed: _busy ? null : _retry,
                            icon: const Icon(Icons.refresh),
                            label: Text(context.tr('retryAnalysis')),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            Text(
              context.tr('aiDisclaimer'),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        if (_busy)
          ColoredBox(
            color: Colors.black38,
            child: Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(context.tr('analyzingLeaf')),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
