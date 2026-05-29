import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class BadgeService {
  BadgeService._();

  static const _kKey = 'earned_badges';

  // ── Badge ID constants ─────────────────────────────────────────────────────
  static const kFirstLesson = 'first_lesson';
  static const kThreeLessons = 'three_lessons';
  static const kFiveLessons = 'five_lessons';
  static const kAllDone = 'all_done';
  static const kAiExplorer = 'ai_explorer';
  static const kPerfectQuiz = 'perfect_quiz';
  static const kCreativeThinker = 'creative_thinker';

  static const List<String> allBadgeIds = [
    kFirstLesson,
    kThreeLessons,
    kFiveLessons,
    kAllDone,
    kAiExplorer,
    kPerfectQuiz,
    kCreativeThinker,
  ];

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Returns the set of all earned badge IDs.
  static Future<Set<String>> getEarned() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kKey);
      if (raw == null) return {};
      return List<String>.from(jsonDecode(raw) as List).toSet();
    } catch (_) {
      return {};
    }
  }

  /// Awards a badge. Returns true if it was newly unlocked.
  static Future<bool> award(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kKey);
      final list =
          raw != null ? List<String>.from(jsonDecode(raw) as List) : <String>[];
      if (list.contains(id)) return false;
      list.add(id);
      await prefs.setString(_kKey, jsonEncode(list));
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Checks lesson completion milestones and awards applicable badges.
  /// Returns the list of newly unlocked badge IDs.
  static Future<List<String>> checkLessonMilestones({
    required int completedCount,
    required bool wasPerfectQuiz,
  }) async {
    final newly = <String>[];
    if (completedCount >= 1 && await award(kFirstLesson)) {
      newly.add(kFirstLesson);
    }
    if (completedCount >= 3 && await award(kThreeLessons)) {
      newly.add(kThreeLessons);
    }
    if (completedCount >= 5 && await award(kFiveLessons)) {
      newly.add(kFiveLessons);
    }
    if (completedCount >= 12 && await award(kAllDone)) {
      newly.add(kAllDone);
    }
    if (wasPerfectQuiz && await award(kPerfectQuiz)) {
      newly.add(kPerfectQuiz);
    }
    return newly;
  }

  /// Awards the AI Explorer badge (visit AI Lab).
  static Future<bool> awardAiExplorer() => award(kAiExplorer);

  /// Awards the Creative Thinker badge (5+ AI Lab stories).
  static Future<bool> awardCreativeThinker() => award(kCreativeThinker);
}
