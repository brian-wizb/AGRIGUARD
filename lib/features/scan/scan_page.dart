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
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final _picker = ImagePicker();
  final _gateway = OpenAiDiagnosisGateway();
  final _repository = DiagnosisRepository(AppDatabase());
  bool _busy = false;

  Future<void> _pickAndAnalyze(ImageSource source) async {
    if (_busy) return;
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 82,
      maxWidth: 1600,
      maxHeight: 1600,
      requestFullMetadata: false,
    );
    if (picked == null || !mounted) return;
    final languageCode = Localizations.localeOf(context).languageCode;
    final userId = AppControllerScope.of(context).currentUser!.id;

    setState(() => _busy = true);
    try {
      final bytes = await picked.readAsBytes();
      final mimeType = _mimeTypeFor(picked.path);
      if (mimeType == null) {
        throw const DiagnosisFailure('invalidImage');
      }
      var diagnosis = await _gateway.analyzeLeaf(
        imageBytes: bytes,
        mimeType: mimeType,
        languageCode: languageCode,
      );
      final imagePath = await _saveImage(picked);
      diagnosis = diagnosis.copyWith(imagePath: imagePath);
      await _repository.save(userId: userId, diagnosis: diagnosis);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => DiagnosisResultPage(diagnosis: diagnosis),
        ),
      );
    } on DiagnosisFailure catch (error) {
      if (mounted) _showError(context.tr(error.code));
    } on Exception {
      if (mounted) _showError(context.tr('unexpectedError'));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
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

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
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
                        onPressed: _busy
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
                        onPressed: _busy
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
