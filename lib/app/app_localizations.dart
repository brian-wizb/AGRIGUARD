import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [Locale('en'), Locale('sw')];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const Map<String, Map<String, String>> _values = {
    'en': {
      'appName': 'AgriGuard',
      'welcome': 'Welcome back',
      'loginSubtitle': 'Sign in to scan a leaf and protect your crops.',
      'username': 'Username',
      'password': 'Password',
      'requiredField': 'This field is required',
      'login': 'Sign in',
      'createAccount': 'Create a local account',
      'language': 'Language',
      'english': 'English',
      'swahili': 'Swahili',
      'home': 'Home',
      'scan': 'Scan',
      'history': 'History',
      'devices': 'Trap',
      'settings': 'Settings',
      'scanTitle': 'Scan any leaf',
      'scanDescription':
          'Point the camera at one clear leaf. AgriGuard will identify the plant and check for visible disease or pest signs.',
      'camera': 'Open camera',
      'gallery': 'Choose leaf image',
      'cameraComing': 'Camera integration will be added in Phase 3.',
      'galleryComing': 'Gallery integration will be added in Phase 3.',
      'noCropSelection': 'No crop selection is required.',
      'recentScans': 'Recent scans',
      'emptyHistory': 'Your completed leaf scans will appear here.',
      'trapTitle': 'Arduino trap',
      'trapDescription':
          'Connect and control the approved trap after a diagnosis.',
      'notConnected': 'Not connected',
      'connect': 'Connect device',
      'hardwareComing': 'Hardware connection will be added in Phase 4.',
      'appearanceLanguage': 'Language and display',
      'localPrototype': 'Academic prototype',
      'localPrototypeDescription':
          'Login data and scan history will remain on this device.',
      'phaseOne': 'Phase 1 foundation',
      'phaseOneDescription':
          'Navigation, localization, theme, and application contracts are ready.',
      'continueDemo': 'Continue to prototype',
    },
    'sw': {
      'appName': 'AgriGuard',
      'welcome': 'Karibu tena',
      'loginSubtitle': 'Ingia ili uchanganue jani na kulinda mazao yako.',
      'username': 'Jina la mtumiaji',
      'password': 'Nenosiri',
      'requiredField': 'Sehemu hii inahitajika',
      'login': 'Ingia',
      'createAccount': 'Fungua akaunti ya kwenye kifaa',
      'language': 'Lugha',
      'english': 'Kiingereza',
      'swahili': 'Kiswahili',
      'home': 'Nyumbani',
      'scan': 'Changanua',
      'history': 'Historia',
      'devices': 'Mtego',
      'settings': 'Mipangilio',
      'scanTitle': 'Changanua jani lolote',
      'scanDescription':
          'Elekeza kamera kwenye jani moja linaloonekana vizuri. AgriGuard itatambua mmea na kuchunguza dalili za ugonjwa au wadudu.',
      'camera': 'Fungua kamera',
      'gallery': 'Chagua picha ya jani',
      'cameraComing': 'Kamera itaunganishwa katika Awamu ya 3.',
      'galleryComing': 'Matunzio yataunganishwa katika Awamu ya 3.',
      'noCropSelection': 'Huhitaji kuchagua zao.',
      'recentScans': 'Uchanganuzi wa hivi karibuni',
      'emptyHistory': 'Uchanganuzi wa majani uliokamilika utaonekana hapa.',
      'trapTitle': 'Mtego wa Arduino',
      'trapDescription':
          'Unganisha na udhibiti mtego ulioidhinishwa baada ya uchunguzi.',
      'notConnected': 'Haujaunganishwa',
      'connect': 'Unganisha kifaa',
      'hardwareComing': 'Kifaa kitaunganishwa katika Awamu ya 4.',
      'appearanceLanguage': 'Lugha na mwonekano',
      'localPrototype': 'Mfano wa kitaaluma',
      'localPrototypeDescription':
          'Taarifa za kuingia na historia zitabaki kwenye kifaa hiki.',
      'phaseOne': 'Msingi wa Awamu ya 1',
      'phaseOneDescription':
          'Urambazaji, lugha, mandhari na mikataba ya programu iko tayari.',
      'continueDemo': 'Endelea kwenye mfano',
    },
  };

  String text(String key) => _values[locale.languageCode]?[key] ??
      _values['en']![key] ??
      key;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.supportedLocales
          .any((item) => item.languageCode == locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) =>
      SynchronousFuture(AppLocalizations(locale));

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension LocalizationContext on BuildContext {
  String tr(String key) => AppLocalizations.of(this).text(key);
}
