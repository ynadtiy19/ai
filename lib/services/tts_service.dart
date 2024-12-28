import 'dart:io';
import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  static final TTSService _instance = TTSService._internal();
  factory TTSService() => _instance;
  TTSService._internal() {
    _initTTS();
  }

  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;
  bool _isInitialized = false;

  Future<void> _initTTS() async {
    try {
      if (Platform.isWindows) {
        await _flutterTts.awaitSpeakCompletion(true);
      }
      
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setPitch(1.0);
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      
      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
      });
      
      _isInitialized = true;
    } catch (e) {
      print('TTS Initialization Error: $e');
      _isInitialized = false;
    }
  }

  Future<void> speak(String text) async {
    if (!_isInitialized) {
      await _initTTS();
    }
    
    if (_isInitialized && !_isSpeaking) {
      try {
        _isSpeaking = true;
        await _flutterTts.speak(text);
      } catch (e) {
        print('TTS Speak Error: $e');
        _isSpeaking = false;
      }
    }
  }

  Future<void> stop() async {
    if (_isInitialized) {
      _isSpeaking = false;
      await _flutterTts.stop();
    }
  }

  bool get isSpeaking => _isSpeaking;
  bool get isInitialized => _isInitialized;
}
