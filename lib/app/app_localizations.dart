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
      'registerTitle': 'Create account',
      'registerSubtitle':
          'Create a username and password for this device. Your account is stored locally.',
      'register': 'Create account',
      'confirmPassword': 'Confirm password',
      'usernameLength': 'Username must contain at least 3 characters',
      'passwordLength': 'Password must contain at least 8 characters',
      'passwordMismatch': 'Passwords do not match',
      'usernameTaken': 'That username already exists on this device',
      'invalidCredentials': 'Incorrect username or password',
      'unexpectedError': 'Something went wrong. Please try again.',
      'logout': 'Sign out',
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
      'analyzingLeaf': 'Analyzing the leaf…',
      'aiDisclaimer':
          'AI screening can be wrong. Confirm important treatment decisions with an agricultural expert.',
      'diagnosisResult': 'Leaf scan result',
      'agriGuardInsights': 'AgriGuard Insights',
      'result_healthy': 'Healthy Leaf',
      'result_disease': 'Disease Detected',
      'result_pest': 'Pest Detected',
      'result_unknown': 'Assessment Uncertain',
      'guidanceConfidence':
          'Confidence is calibrated for guidance-level decisions.',
      'confidence': 'Confidence',
      'primaryAssessment': 'Primary assessment',
      'notLeaf': 'No leaf detected',
      'visibleSigns': 'Visible signs',
      'recommendedActions': 'Recommended next steps',
      'recommendedTreatment': 'Recommended treatment',
      'preventionAdvice': 'Prevention advice',
      'pestRisk': 'Pest risk',
      'likelyPests': 'Likely pests',
      'alternativeDiagnoses': 'Other possible causes',
      'risk_none': 'None',
      'risk_low': 'Low',
      'risk_medium': 'Medium',
      'risk_high': 'High',
      'risk_unknown': 'Unknown',
      'precautions': 'Precautions',
      'confidence_high': 'High confidence',
      'confidence_medium': 'Medium confidence',
      'confidence_low': 'Low confidence',
      'missingApiKey':
          'OpenAI API key is missing. Build with --dart-define=OPENAI_API_KEY=your_key.',
      'invalidApiKey': 'The OpenAI API key was rejected.',
      'invalidImage': 'Choose a JPG, PNG, or WEBP image smaller than 8 MB.',
      'requestTimeout': 'The analysis took too long. Please try again.',
      'networkError': 'Connect to the internet and try again.',
      'rateLimited': 'The scan limit was reached. Please wait and try again.',
      'analysisFailed': 'The leaf could not be analyzed. Please try again.',
      'invalidResponse':
          'The diagnosis response was invalid. Please try again.',
      'historyLoadFailed': 'Scan history could not be loaded.',
      'noCropSelection': 'No crop selection is required.',
      'recentScans': 'Recent scans',
      'emptyHistory': 'Your completed leaf scans will appear here.',
      'trapTitle': 'Arduino trap',
      'trapDescription':
          'Connect and control the approved trap after a diagnosis.',
      'notConnected': 'Not connected',
      'connect': 'Connect device',
      'hardwareComing': 'Hardware connection will be added in Phase 4.',
      'findUsbDevices': 'Find USB devices',
      'availableUsbDevices': 'Available USB devices',
      'noUsbDevices': 'No USB serial device found',
      'usbConnectionHint':
          'Connect the Arduino with a USB OTG adapter, power it on, then refresh.',
      'usbDiscoveryFailed': 'USB devices could not be searched.',
      'usbConnectionFailed':
          'The USB device could not be opened. Allow USB access and try again.',
      'disconnect': 'Disconnect',
      'checkStatus': 'Check status',
      'emergencyStop': 'STOP',
      'hardwareSafetyTitle': 'Hardware safety',
      'hardwareSafetyDescription':
          'Commands are allow-listed, limited to 30 seconds, checked for corruption, and must be acknowledged by the Arduino.',
      'deviceNotConnected': 'Connect the Arduino trap from the Trap tab first.',
      'commandTimeout':
          'The Arduino did not acknowledge the command. Check the cable and trap.',
      'commandRejected': 'The Arduino rejected the command.',
      'commandFailed': 'The command could not be sent.',
      'commandAcknowledged': 'The Arduino acknowledged the command.',
      'trapActionAvailable': 'Physical trap action available',
      'trapActionDescription':
          'This diagnosis may benefit from the connected physical trap. Inspect the area before activation.',
      'activateTrap': 'Activate trap',
      'confirmTrapActivation': 'Activate the Arduino trap?',
      'trapActivationWarning':
          'Keep people and animals clear. The trap will run for 10 seconds and should stop automatically.',
      'activateForTenSeconds': 'Activate for 10 seconds',
      'cancel': 'Cancel',
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
      'registerTitle': 'Fungua akaunti',
      'registerSubtitle':
          'Tengeneza jina la mtumiaji na nenosiri kwa kifaa hiki. Akaunti itahifadhiwa kwenye kifaa.',
      'register': 'Fungua akaunti',
      'confirmPassword': 'Thibitisha nenosiri',
      'usernameLength': 'Jina la mtumiaji liwe na angalau herufi 3',
      'passwordLength': 'Nenosiri liwe na angalau herufi 8',
      'passwordMismatch': 'Manenosiri hayafanani',
      'usernameTaken': 'Jina hilo tayari linatumika kwenye kifaa hiki',
      'invalidCredentials': 'Jina la mtumiaji au nenosiri si sahihi',
      'unexpectedError': 'Hitilafu imetokea. Tafadhali jaribu tena.',
      'logout': 'Toka',
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
      'analyzingLeaf': 'Jani linachunguzwa…',
      'aiDisclaimer':
          'Uchunguzi wa AI unaweza kukosea. Thibitisha maamuzi muhimu ya matibabu na mtaalamu wa kilimo.',
      'diagnosisResult': 'Matokeo ya uchunguzi wa jani',
      'agriGuardInsights': 'Maarifa ya AgriGuard',
      'result_healthy': 'Jani Lina Afya',
      'result_disease': 'Ugonjwa Umegunduliwa',
      'result_pest': 'Mdudu Mharibifu Amegunduliwa',
      'result_unknown': 'Uchunguzi Hauna Uhakika',
      'guidanceConfidence':
          'Uhakika umekadiriwa kwa maamuzi ya mwongozo.',
      'confidence': 'Uhakika',
      'primaryAssessment': 'Uchunguzi mkuu',
      'notLeaf': 'Hakuna jani lililotambuliwa',
      'visibleSigns': 'Dalili zinazoonekana',
      'recommendedActions': 'Hatua zinazopendekezwa',
      'recommendedTreatment': 'Matibabu yanayopendekezwa',
      'preventionAdvice': 'Ushauri wa kuzuia',
      'pestRisk': 'Hatari ya wadudu',
      'likelyPests': 'Wadudu wanaowezekana',
      'alternativeDiagnoses': 'Sababu nyingine zinazowezekana',
      'risk_none': 'Hakuna',
      'risk_low': 'Ndogo',
      'risk_medium': 'Wastani',
      'risk_high': 'Kubwa',
      'risk_unknown': 'Haijulikani',
      'precautions': 'Tahadhari',
      'confidence_high': 'Uhakika mkubwa',
      'confidence_medium': 'Uhakika wa wastani',
      'confidence_low': 'Uhakika mdogo',
      'missingApiKey':
          'Ufunguo wa OpenAI API haupo. Tumia --dart-define=OPENAI_API_KEY=ufunguo_wako.',
      'invalidApiKey': 'Ufunguo wa OpenAI API umekataliwa.',
      'invalidImage': 'Chagua picha ya JPG, PNG au WEBP chini ya MB 8.',
      'requestTimeout': 'Uchunguzi umechukua muda mrefu. Jaribu tena.',
      'networkError': 'Unganisha intaneti kisha ujaribu tena.',
      'rateLimited': 'Kikomo cha uchunguzi kimefikiwa. Subiri ujaribu tena.',
      'analysisFailed': 'Jani halikuweza kuchunguzwa. Jaribu tena.',
      'invalidResponse': 'Jibu la uchunguzi si sahihi. Jaribu tena.',
      'historyLoadFailed': 'Historia ya uchunguzi haikuweza kufunguliwa.',
      'noCropSelection': 'Huhitaji kuchagua zao.',
      'recentScans': 'Uchanganuzi wa hivi karibuni',
      'emptyHistory': 'Uchanganuzi wa majani uliokamilika utaonekana hapa.',
      'trapTitle': 'Mtego wa Arduino',
      'trapDescription':
          'Unganisha na udhibiti mtego ulioidhinishwa baada ya uchunguzi.',
      'notConnected': 'Haujaunganishwa',
      'connect': 'Unganisha kifaa',
      'hardwareComing': 'Kifaa kitaunganishwa katika Awamu ya 4.',
      'findUsbDevices': 'Tafuta vifaa vya USB',
      'availableUsbDevices': 'Vifaa vya USB vinavyopatikana',
      'noUsbDevices': 'Hakuna kifaa cha USB serial kilichopatikana',
      'usbConnectionHint':
          'Unganisha Arduino kwa adapta ya USB OTG, washa, kisha tafuta tena.',
      'usbDiscoveryFailed': 'Vifaa vya USB havikuweza kutafutwa.',
      'usbConnectionFailed':
          'Kifaa cha USB hakikuweza kufunguliwa. Ruhusu matumizi ya USB kisha ujaribu tena.',
      'disconnect': 'Tenganisha',
      'checkStatus': 'Kagua hali',
      'emergencyStop': 'SIMAMISHA',
      'hardwareSafetyTitle': 'Usalama wa kifaa',
      'hardwareSafetyDescription':
          'Amri zimeidhinishwa, zimewekewa kikomo cha sekunde 30, hukaguliwa uharibifu na lazima zithibitishwe na Arduino.',
      'deviceNotConnected':
          'Unganisha mtego wa Arduino kwenye sehemu ya Mtego kwanza.',
      'commandTimeout': 'Arduino haikuthibitisha amri. Kagua waya na mtego.',
      'commandRejected': 'Arduino imekataa amri.',
      'commandFailed': 'Amri haikuweza kutumwa.',
      'commandAcknowledged': 'Arduino imethibitisha amri.',
      'trapActionAvailable': 'Hatua ya mtego inapatikana',
      'trapActionDescription':
          'Uchunguzi huu unaweza kusaidiwa na mtego uliounganishwa. Kagua eneo kabla ya kuwasha.',
      'activateTrap': 'Washa mtego',
      'confirmTrapActivation': 'Uwashe mtego wa Arduino?',
      'trapActivationWarning':
          'Weka watu na wanyama mbali. Mtego utafanya kazi kwa sekunde 10 na unapaswa kujizima.',
      'activateForTenSeconds': 'Washa kwa sekunde 10',
      'cancel': 'Ghairi',
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

  String text(String key) =>
      _values[locale.languageCode]?[key] ?? _values['en']![key] ?? key;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalizations.supportedLocales.any(
    (item) => item.languageCode == locale.languageCode,
  );

  @override
  Future<AppLocalizations> load(Locale locale) =>
      SynchronousFuture(AppLocalizations(locale));

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension LocalizationContext on BuildContext {
  String tr(String key) => AppLocalizations.of(this).text(key);
}
