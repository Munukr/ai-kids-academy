import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/lesson.dart';
import '../constants/app_strings.dart';
import 'remote_lesson_service.dart';

class LessonService {
  static final Map<AppLanguage, List<Lesson>> _cache = {};

  static Future<List<Lesson>> loadLessons(AppLanguage language) async {
    if (_cache.containsKey(language)) {
      return _cache[language]!;
    }

    // Try remote-cached lessons first (downloaded by RemoteLessonService).
    final remoteJson = await RemoteLessonService.getCachedJson(language);
    if (remoteJson != null) {
      try {
        final jsonData = json.decode(remoteJson) as Map<String, dynamic>;
        final lessonList = (jsonData['lessons'] as List)
            .map((e) => Lesson.fromJson(e as Map<String, dynamic>))
            .toList();
        _cache[language] = lessonList;
        return lessonList;
      } catch (_) {
        // Corrupted cache — fall through to bundled assets.
      }
    }

    // Fall back to bundled asset files (always present).
    final path = _assetPath(language);
    final jsonString = await rootBundle.loadString(path);
    final jsonData = json.decode(jsonString) as Map<String, dynamic>;
    final lessonList = (jsonData['lessons'] as List)
        .map((e) => Lesson.fromJson(e as Map<String, dynamic>))
        .toList();

    _cache[language] = lessonList;
    return lessonList;
  }

  static String _assetPath(AppLanguage language) {
    switch (language) {
      case AppLanguage.ru:
        return 'assets/data/lessons_ru.json';
      case AppLanguage.he:
        return 'assets/data/lessons_he.json';
      case AppLanguage.en:
        return 'assets/data/lessons_en.json';
    }
  }

  static void clearCache() {
    _cache.clear();
  }
}
