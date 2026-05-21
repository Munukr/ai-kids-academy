import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_strings.dart';

const _kEnabledKey = 'narration_enabled';
const _kAutoReadKey = 'narration_auto_read';

class NarrationService {
  NarrationService._();
  static final NarrationService instance = NarrationService._();

  FlutterTts? _tts;
  bool _enabled = true;
  bool _autoRead = true;
  bool _ready = false;

  bool get enabled => _enabled;
  bool get autoRead => _autoRead;

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _enabled = prefs.getBool(_kEnabledKey) ?? true;
      _autoRead = prefs.getBool(_kAutoReadKey) ?? true;

      _tts = FlutterTts();
      await _tts!.setSpeechRate(0.45);
      await _tts!.setVolume(1.0);
      await _tts!.setPitch(1.1);
      _ready = true;
    } catch (_) {
      _ready = false;
    }
  }

  Future<void> speak(String text, AppLanguage lang) async {
    if (!_enabled || !_ready || _tts == null) return;
    try {
      await _tts!.stop();
      await _tts!.setLanguage(_code(lang));
      await _tts!.speak(text);
    } catch (_) {}
  }

  Future<void> speakAuto(String text, AppLanguage lang) async {
    if (!_autoRead) return;
    await speak(text, lang);
  }

  Future<void> stop() async {
    if (!_ready || _tts == null) return;
    try {
      await _tts!.stop();
    } catch (_) {}
  }

  Future<void> setEnabled(bool val) async {
    _enabled = val;
    if (!val) await stop();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kEnabledKey, val);
    } catch (_) {}
  }

  Future<void> setAutoRead(bool val) async {
    _autoRead = val;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kAutoReadKey, val);
    } catch (_) {}
  }

  String _code(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return 'ru-RU';
      case AppLanguage.he:
        return 'he-IL';
      case AppLanguage.en:
        return 'en-US';
    }
  }
}
