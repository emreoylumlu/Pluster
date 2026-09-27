import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundService {
  SoundService._();
  static final SoundService instance = SoundService._();

  static const String _keySoundEnabled = 'pluster_sound_enabled';
  bool _isSoundEnabled = true;
  bool get isSoundEnabled => _isSoundEnabled;

  AudioPlayer? _player;
  AudioPlayer get _audioPlayer {
    _player ??= AudioPlayer();
    return _player!;
  }

  // Pre-cached synthesized WAV bytes
  final Map<String, Uint8List> _soundCache = {};

  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isSoundEnabled = prefs.getBool(_keySoundEnabled) ?? true;
      _precacheSounds();
    } catch (e) {
      debugPrint('SoundService init error: ');
    }
  }

  Future<void> toggleSound() async {
    _isSoundEnabled = !_isSoundEnabled;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keySoundEnabled, _isSoundEnabled);
    } catch (_) {}
  }

  void _precacheSounds() {
    // 1. Pop / Normal pulse blast (440Hz -> 380Hz slight chirp, 140ms)
    _soundCache['pop'] = _generateChirpWav(startFreq: 440, endFreq: 360, durationMs: 140);

    // 2. Rising Combos: C5 (523Hz), E5 (659Hz), G5 (784Hz), C6 (1046Hz)
    _soundCache['combo1'] = _generateToneWav(frequency: 523.25, durationMs: 160);
    _soundCache['combo2'] = _generateToneWav(frequency: 659.25, durationMs: 180);
    _soundCache['combo3'] = _generateToneWav(frequency: 783.99, durationMs: 200);
    _soundCache['combo4'] = _generateToneWav(frequency: 1046.50, durationMs: 250);

    // 3. Bomb explosion: deep sub bass chirp (140Hz -> 45Hz, 260ms)
    _soundCache['bomb'] = _generateChirpWav(startFreq: 140, endFreq: 45, durationMs: 260, isLowBass: true);

    // 4. Subtle placement click (720Hz, 35ms)
    _soundCache['placement'] = _generateToneWav(frequency: 720, durationMs: 35, fastDecay: true);

    // 5. Game Over / Energy Depleted: descending synth sweep (380Hz -> 120Hz, 350ms)
    _soundCache['game_over'] = _generateChirpWav(startFreq: 380, endFreq: 120, durationMs: 350);
  }

  Future<void> playPop() async {
    await _playSound('pop');
  }

  Future<void> playCombo(int combo) async {
    if (combo <= 1) {
      await _playSound('combo1');
    } else if (combo == 2) {
      await _playSound('combo2');
    } else if (combo == 3) {
      await _playSound('combo3');
    } else {
      await _playSound('combo4');
    }
  }

  Future<void> playBomb() async {
    await _playSound('bomb');
  }

  Future<void> playPlacement() async {
    await _playSound('placement');
  }

  Future<void> playGameOver() async {
    await _playSound('game_over');
  }

  Future<void> _playSound(String key) async {
    if (!_isSoundEnabled) return;
    final bytes = _soundCache[key];
    if (bytes == null) return;

    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(BytesSource(bytes), volume: 0.85);
    } catch (e) {
      // In widget test environments or unsupported audio devices, catch gracefully
      debugPrint('Audio playback suppressed: ');
    }
  }

  /// Synthesizes a mono 16-bit PCM WAV byte array with a fixed frequency and smooth envelope.
  Uint8List _generateToneWav({
    required double frequency,
    required int durationMs,
    bool fastDecay = false,
  }) {
    const int sampleRate = 44100;
    final int numSamples = (sampleRate * durationMs / 1000).round();
    final int dataSize = numSamples * 2; // 16-bit = 2 bytes per sample
    final byteData = ByteData(44 + dataSize);

    _writeWavHeader(byteData, dataSize, sampleRate);

    int offset = 44;
    for (int i = 0; i < numSamples; i++) {
      final double t = i / sampleRate;
      final double progress = i / numSamples;
      // Exponential decay envelope to prevent audio clicking
      final double envelope = fastDecay ? pow(1.0 - progress, 2.5).toDouble() : (1.0 - progress) * sqrt(1.0 - progress);
      // Soft sine wave with a subtle 2nd harmonic for warm synth color
      final double sample = (sin(2 * pi * frequency * t) * 0.85 + sin(4 * pi * frequency * t) * 0.15) * envelope;
      final int intSample = (sample * 30000).clamp(-32767, 32767).toInt();
      byteData.setInt16(offset, intSample, Endian.little);
      offset += 2;
    }

    return byteData.buffer.asUint8List();
  }

  /// Synthesizes a frequency-swept chirp (descending/ascending) for punches and explosions.
  Uint8List _generateChirpWav({
    required double startFreq,
    required double endFreq,
    required int durationMs,
    bool isLowBass = false,
  }) {
    const int sampleRate = 44100;
    final int numSamples = (sampleRate * durationMs / 1000).round();
    final int dataSize = numSamples * 2;
    final byteData = ByteData(44 + dataSize);

    _writeWavHeader(byteData, dataSize, sampleRate);

    int offset = 44;
    double phase = 0.0;
    for (int i = 0; i < numSamples; i++) {
      final double progress = i / numSamples;
      final double currentFreq = startFreq + (endFreq - startFreq) * progress;
      phase += 2 * pi * currentFreq / sampleRate;

      final double envelope = (1.0 - progress) * (1.0 - progress);
      double sample = sin(phase) * envelope;
      if (isLowBass) {
        // Add subtle harmonic saturation for punching bass
        sample = (sample * 1.2).clamp(-1.0, 1.0);
      }
      final int intSample = (sample * 31000).clamp(-32767, 32767).toInt();
      byteData.setInt16(offset, intSample, Endian.little);
      offset += 2;
    }

    return byteData.buffer.asUint8List();
  }

  /// Writes standard 44-byte RIFF/WAVE header
  void _writeWavHeader(ByteData byteData, int dataSize, int sampleRate) {
    // RIFF chunk descriptor
    byteData.setUint8(0, 0x52); // 'R'
    byteData.setUint8(1, 0x49); // 'I'
    byteData.setUint8(2, 0x46); // 'F'
    byteData.setUint8(3, 0x46); // 'F'
    byteData.setUint32(4, 36 + dataSize, Endian.little);
    byteData.setUint8(8, 0x57);  // 'W'
    byteData.setUint8(9, 0x41);  // 'A'
    byteData.setUint8(10, 0x56); // 'V'
    byteData.setUint8(11, 0x45); // 'E'

    // "fmt " sub-chunk
    byteData.setUint8(12, 0x66); // 'f'
    byteData.setUint8(13, 0x6D); // 'm'
    byteData.setUint8(14, 0x74); // 't'
    byteData.setUint8(15, 0x20); // ' '
    byteData.setUint32(16, 16, Endian.little); // Subchunk1Size (16 for PCM)
    byteData.setUint16(20, 1, Endian.little);  // AudioFormat (1 = PCM)
    byteData.setUint16(22, 1, Endian.little);  // NumChannels (1 = Mono)
    byteData.setUint32(24, sampleRate, Endian.little); // SampleRate
    byteData.setUint32(28, sampleRate * 2, Endian.little); // ByteRate (SampleRate * NumChannels * 2)
    byteData.setUint16(32, 2, Endian.little);  // BlockAlign (NumChannels * 2)
    byteData.setUint16(34, 16, Endian.little); // BitsPerSample (16 bits)

    // "data" sub-chunk
    byteData.setUint8(36, 0x64); // 'd'
    byteData.setUint8(37, 0x61); // 'a'
    byteData.setUint8(38, 0x74); // 't'
    byteData.setUint8(39, 0x61); // 'a'
    byteData.setUint32(40, dataSize, Endian.little);
  }
}
