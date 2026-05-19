import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kProgressKey = 'lesson_progress';

class ProgressProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  Map<String, bool> _completedLessons;

  ProgressProvider(this._prefs)
      : _completedLessons = _load(_prefs);

  bool isCompleted(String lessonId) => _completedLessons[lessonId] ?? false;

  int get completedCount => _completedLessons.values.where((v) => v).length;

  int get starsEarned => completedCount;

  Set<String> get completedIds =>
      _completedLessons.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toSet();

  bool isUnlocked(int index, List<String> lessonIds) {
    if (index == 0) return true;
    final prevId = lessonIds[index - 1];
    return isCompleted(prevId);
  }

  Future<void> markCompleted(String lessonId) async {
    _completedLessons[lessonId] = true;
    await _save();
    notifyListeners();
  }

  Future<void> resetProgress() async {
    _completedLessons = {};
    await _prefs.remove(_kProgressKey);
    notifyListeners();
  }

  Future<void> _save() async {
    final json = jsonEncode(_completedLessons);
    await _prefs.setString(_kProgressKey, json);
  }

  static Map<String, bool> _load(SharedPreferences prefs) {
    final raw = prefs.getString(_kProgressKey);
    if (raw == null) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, v as bool));
    } catch (_) {
      return {};
    }
  }
}
