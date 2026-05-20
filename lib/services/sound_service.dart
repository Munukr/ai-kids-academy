import 'dart:math' as math;
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kMuteKey = 'sound_muted';

// ── PCM WAV generator ─────────────────────────────────────────────────────────

class _Note {
  final double freq;
  final int ms;
  const _Note(this.freq, this.ms);
}

Uint8List _makeWav(List<_Note> notes, {int sr = 22050}) {
  final allSamples = <int>[];
  for (final n in notes) {
    final count = (n.ms * sr / 1000).round();
    for (int i = 0; i < count; i++) {
      final t = i / sr;
      // Attack (5%) / sustain / decay (20%) envelope
      final env = i < count * 0.05
          ? i / (count * 0.05)
          : i > count * 0.8
              ? (count - i) / (count * 0.2).clamp(1, count.toDouble())
              : 1.0;
      final sample = (math.sin(2 * math.pi * n.freq * t) * 28000 * env)
          .round()
          .clamp(-32767, 32767);
      allSamples.add(sample);
    }
  }

  final pcm = Int16List.fromList(allSamples);
  final pcmBytes = pcm.buffer.asUint8List();
  final dataLen = pcmBytes.length;
  final byteRate = sr * 2; // mono 16-bit

  final header = ByteData(44);
  void str4(int off, String s) {
    for (int i = 0; i < 4; i++) {
      header.setUint8(off + i, s.codeUnitAt(i));
    }
  }

  str4(0, 'RIFF');
  header.setUint32(4, 36 + dataLen, Endian.little);
  str4(8, 'WAVE');
  str4(12, 'fmt ');
  header.setUint32(16, 16, Endian.little);
  header.setUint16(20, 1, Endian.little); // PCM
  header.setUint16(22, 1, Endian.little); // mono
  header.setUint32(24, sr, Endian.little);
  header.setUint32(28, byteRate, Endian.little);
  header.setUint16(32, 2, Endian.little); // block align
  header.setUint16(34, 16, Endian.little); // 16-bit
  str4(36, 'data');
  header.setUint32(40, dataLen, Endian.little);

  final out = Uint8List(44 + dataLen);
  out.setRange(0, 44, header.buffer.asUint8List());
  out.setRange(44, out.length, pcmBytes);
  return out;
}

// ── Pre-built tones (lazy, computed once) ─────────────────────────────────────

final _kTapWav = _makeWav([const _Note(880, 55)]);
final _kSuccessWav = _makeWav([
  const _Note(523, 80),
  const _Note(659, 80),
  const _Note(784, 110),
]);
final _kWrongWav = _makeWav([
  const _Note(330, 100),
  const _Note(220, 130),
]);
final _kCompleteWav = _makeWav([
  const _Note(523, 75),
  const _Note(659, 75),
  const _Note(784, 75),
  const _Note(1047, 220),
]);
final _kSandboxWav = _makeWav([
  const _Note(800, 55),
  const _Note(1000, 55),
  const _Note(1200, 55),
  const _Note(1600, 130),
]);
final _kStarWav = _makeWav([
  const _Note(784, 65),
  const _Note(880, 65),
  const _Note(988, 65),
  const _Note(1047, 160),
]);

// ── Service ───────────────────────────────────────────────────────────────────

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

  Future<void> _play(Uint8List wav) async {
    if (_muted) return;
    try {
      final player = AudioPlayer()..setReleaseMode(ReleaseMode.release);
      await player.play(BytesSource(wav));
    } catch (_) {
      // Silently ignore on platforms where audio is unavailable
    }
  }

  Future<void> tap() async {
    if (_muted) return;
    await HapticFeedback.lightImpact();
    _play(_kTapWav);
  }

  Future<void> success() async {
    if (_muted) return;
    await HapticFeedback.mediumImpact();
    _play(_kSuccessWav);
  }

  Future<void> wrong() async {
    if (_muted) return;
    await HapticFeedback.heavyImpact();
    _play(_kWrongWav);
  }

  Future<void> complete() async {
    if (_muted) return;
    await HapticFeedback.vibrate();
    _play(_kCompleteWav);
  }

  Future<void> sandbox() async => _play(_kSandboxWav);

  Future<void> star() async => _play(_kStarWav);
}
