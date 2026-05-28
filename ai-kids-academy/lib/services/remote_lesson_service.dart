import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/remote_config.dart';
import '../constants/app_strings.dart';

enum RemoteUpdateResult { upToDate, updated, noInternet, failed }

class RemoteLessonService {
  RemoteLessonService._();

  static const _kCachedVersion = 'remote_lessons_version';
  static const _kCachedEn = 'remote_lessons_en';
  static const _kCachedRu = 'remote_lessons_ru';
  static const _kCachedHe = 'remote_lessons_he';

  /// Returns the cached remote lessons JSON string for [language], or null if
  /// not cached. A null return means local assets should be used instead.
  static Future<String?> getCachedJson(AppLanguage language) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_prefKey(language));
    } catch (_) {
      return null;
    }
  }

  /// Returns the cached content version string.
  /// Falls back to [RemoteConfig.localContentVersion] if nothing is cached.
  static Future<String> getCachedVersion() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_kCachedVersion) ??
          RemoteConfig.localContentVersion;
    } catch (_) {
      return RemoteConfig.localContentVersion;
    }
  }

  /// Checks the remote version.json and downloads all three lesson files if a
  /// newer version is available. All files must pass validation before anything
  /// is persisted — if any file is invalid the existing cache is left intact.
  static Future<RemoteUpdateResult> checkAndUpdate() async {
    try {
      // ── 1. Fetch version manifest ────────────────────────────────────────
      final versionResp = await http
          .get(Uri.parse(RemoteConfig.versionUrl))
          .timeout(RemoteConfig.requestTimeout);

      if (versionResp.statusCode != 200) return RemoteUpdateResult.failed;

      final versionJson =
          json.decode(versionResp.body) as Map<String, dynamic>;
      final remoteVersion = (versionJson['version'] as String?) ?? '';
      if (remoteVersion.isEmpty) return RemoteUpdateResult.failed;

      // ── 2. Compare versions ──────────────────────────────────────────────
      final cachedVersion = await getCachedVersion();
      if (_versionOrder(remoteVersion) <= _versionOrder(cachedVersion) &&
          cachedVersion != RemoteConfig.localContentVersion) {
        return RemoteUpdateResult.upToDate;
      }

      // ── 3. Resolve lesson URLs (version.json may override defaults) ──────
      final ruUrl = (versionJson['lessons_ru_url'] as String?)?.isNotEmpty ==
              true
          ? versionJson['lessons_ru_url'] as String
          : RemoteConfig.lessonsRuUrl;
      final heUrl = (versionJson['lessons_he_url'] as String?)?.isNotEmpty ==
              true
          ? versionJson['lessons_he_url'] as String
          : RemoteConfig.lessonsHeUrl;
      final enUrl = (versionJson['lessons_en_url'] as String?)?.isNotEmpty ==
              true
          ? versionJson['lessons_en_url'] as String
          : RemoteConfig.lessonsEnUrl;

      // ── 4. Download and validate all three in parallel ───────────────────
      final results = await Future.wait([
        _fetchAndValidate(ruUrl),
        _fetchAndValidate(heUrl),
        _fetchAndValidate(enUrl),
      ]);

      final ruJson = results[0];
      final heJson = results[1];
      final enJson = results[2];

      // All must be valid — reject the whole update if any file fails.
      if (ruJson == null || heJson == null || enJson == null) {
        return RemoteUpdateResult.failed;
      }

      // ── 5. Persist to SharedPreferences ─────────────────────────────────
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kCachedRu, ruJson);
      await prefs.setString(_kCachedHe, heJson);
      await prefs.setString(_kCachedEn, enJson);
      await prefs.setString(_kCachedVersion, remoteVersion);

      return RemoteUpdateResult.updated;
    } on SocketException {
      return RemoteUpdateResult.noInternet;
    } on HttpException {
      return RemoteUpdateResult.noInternet;
    } on Exception {
      return RemoteUpdateResult.failed;
    }
  }

  /// Clears all cached remote lessons (reverts to bundled assets on next load).
  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kCachedVersion);
      await prefs.remove(_kCachedEn);
      await prefs.remove(_kCachedRu);
      await prefs.remove(_kCachedHe);
    } catch (_) {}
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  static Future<String?> _fetchAndValidate(String url) async {
    try {
      final resp = await http
          .get(Uri.parse(url))
          .timeout(RemoteConfig.requestTimeout);
      if (resp.statusCode != 200) return null;
      final body = resp.body;
      final decoded = json.decode(body);
      return _validate(decoded) ? body : null;
    } catch (_) {
      return null;
    }
  }

  /// Validates the decoded JSON structure matches the expected lesson format.
  static bool _validate(dynamic data) {
    if (data is! Map<String, dynamic>) return false;
    final lessons = data['lessons'];
    if (lessons is! List || lessons.isEmpty) return false;
    for (final item in lessons) {
      if (item is! Map<String, dynamic>) return false;
      if ((item['id'] as String?)?.isEmpty ?? true) return false;
      if ((item['title'] as String?)?.isEmpty ?? true) return false;
      final content = item['content'];
      if (content is! List || content.isEmpty) return false;
      final quiz = item['quiz'];
      if (quiz is! List || quiz.isEmpty) return false;
      for (final q in quiz as List) {
        if (q is! Map<String, dynamic>) return false;
        if (q['question'] is! String) return false;
        final opts = q['options'];
        if (opts is! List || (opts as List).length < 2) return false;
      }
    }
    return true;
  }

  static String _prefKey(AppLanguage language) {
    switch (language) {
      case AppLanguage.ru:
        return _kCachedRu;
      case AppLanguage.he:
        return _kCachedHe;
      case AppLanguage.en:
        return _kCachedEn;
    }
  }

  /// Converts a semver string like "1.2.3" to an integer for comparison.
  static int _versionOrder(String v) {
    try {
      return v
          .split('.')
          .map(int.parse)
          .fold(0, (acc, n) => acc * 1000 + n);
    } catch (_) {
      return 0;
    }
  }
}
