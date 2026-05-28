class RemoteConfig {
  RemoteConfig._();

  // Replace these placeholder URLs with real hosted files when ready.
  // version.json format:
  // {
  //   "version": "1.0.1",
  //   "lessons_ru_url": "https://...",
  //   "lessons_he_url": "https://...",
  //   "lessons_en_url": "https://..."
  // }
  static const String versionUrl =
      'https://placeholder.example.com/ai-kids-academy/version.json';
  static const String lessonsRuUrl =
      'https://placeholder.example.com/ai-kids-academy/lessons_ru.json';
  static const String lessonsHeUrl =
      'https://placeholder.example.com/ai-kids-academy/lessons_he.json';
  static const String lessonsEnUrl =
      'https://placeholder.example.com/ai-kids-academy/lessons_en.json';

  /// The built-in content version bundled with this APK.
  static const String localContentVersion = '1.0.0';

  /// Network timeout for all remote requests.
  static const Duration requestTimeout = Duration(seconds: 8);
}
