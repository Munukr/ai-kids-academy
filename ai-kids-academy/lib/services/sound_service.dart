import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kMuteKey = 'sound_muted';

class SoundService {
  SoundService._();
  static final SoundService instance = SoundService._();

  bool _muted = false;
  bool get muted => _muted;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _muted = prefs.getBool(_kMuteKey) ?? false;
  }

  Future<void> toggleMute() async {
    _muted = !_muted;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kMuteKey, _muted);
  }

  Future<void> tap() async {
    if (_muted) return;
    await HapticFeedback.lightImpact();
  }

  Future<void> success() async {
    if (_muted) return;
    await HapticFeedback.mediumImpact();
  }

  Future<void> wrong() async {
    if (_muted) return;
    await HapticFeedback.heavyImpact();
  }

  Future<void> complete() async {
    if (_muted) return;
    await HapticFeedback.vibrate();
  }
}
