# AgriGuard

A bilingual Flutter prototype for AI-assisted leaf disease and pest screening
with local SQLite accounts and diagnosis history.

## Run on Android

The Phase 3 OpenAI client reads its demonstration key and optional model from
compile-time configuration:

```powershell
flutter run --dart-define=OPENAI_API_KEY=your_project_key
```

The default model is `gpt-5.6-sol`. Override it when evaluating another model:

```powershell
flutter run --dart-define=OPENAI_API_KEY=your_project_key --dart-define=OPENAI_MODEL=gpt-5.6-sol
```

The key is embedded in the resulting APK as explicitly accepted for this
academic prototype. Use a dedicated, budget-limited key and revoke it after the
demonstration. Do not commit the real key to this repository.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
