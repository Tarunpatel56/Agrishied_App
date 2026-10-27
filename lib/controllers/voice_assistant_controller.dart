import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'language_controller.dart';

/// Voice Assistant State Controller
/// Handles multilingual Speech-to-Text (STT), AI Q&A processing,
/// and language-aware Text-to-Speech (TTS).
class VoiceAssistantController extends GetxController {
  // Speech & TTS Services
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();

  // Reactive State Variables
  final RxBool isListening = false.obs;
  final RxBool isProcessing = false.obs;
  final RxBool isSpeaking = false.obs;
  final RxBool speechAvailable = false.obs;
  final RxDouble soundLevel = 0.0.obs;

  // Language management: 'auto', 'hi', 'en'
  final RxString selectedLanguageMode = 'auto'.obs;
  final RxString detectedLanguage = 'hi'.obs;

  // Interaction Content
  final RxString userTranscript = ''.obs;
  final RxString aiResponse = ''.obs;
  final RxString errorMessage = ''.obs;

  // Conversation history for context (last 6 exchanges)
  final List<Map<String, String>> _history = [];

  // Speech timeout timer
  Timer? _speechTimeoutTimer;

  @override
  void onInit() {
    super.onInit();
    _initTts();
    _initSpeech();
    // Default detected language aligns with user's current app language
    detectedLanguage.value = LanguageController.isAppHindi ? 'hi' : 'en';
  }

  @override
  void onClose() {
    _speechTimeoutTimer?.cancel();
    _speech.stop();
    _flutterTts.stop();
    super.onClose();
  }

  /// Initialize Text-To-Speech engine with audio handlers
  Future<void> _initTts() async {
    try {
      await _flutterTts.setSpeechRate(0.48);
      await _flutterTts.setPitch(1.0);
      await _flutterTts.setVolume(1.0);

      _flutterTts.setStartHandler(() {
        isSpeaking.value = true;
      });

      _flutterTts.setCompletionHandler(() {
        isSpeaking.value = false;
      });

      _flutterTts.setCancelHandler(() {
        isSpeaking.value = false;
      });

      _flutterTts.setErrorHandler((msg) {
        debugPrint('[VoiceAssistant] TTS Error: $msg');
        isSpeaking.value = false;
      });
    } catch (e) {
      debugPrint('[VoiceAssistant] Failed to configure FlutterTts: $e');
    }
  }

  /// Initialize Speech Recognition service
  Future<bool> _initSpeech() async {
    try {
      final hasSpeech = await _speech.initialize(
        onStatus: (status) {
          debugPrint('[VoiceAssistant] Speech Status: $status');
          if (status == 'done' || status == 'notListening') {
            isListening.value = false;
            soundLevel.value = 0.0;
          }
        },
        onError: (SpeechRecognitionError error) {
          debugPrint('[VoiceAssistant] Speech Error: ${error.errorMsg} (${error.permanent})');
          isListening.value = false;
          soundLevel.value = 0.0;
          if (error.errorMsg != 'error_no_match') {
            errorMessage.value = LanguageController.isAppHindi
                ? 'आवाज़ पहचान में त्रुटि: ${error.errorMsg}'
                : 'Speech recognition error: ${error.errorMsg}';
          }
        },
      );

      speechAvailable.value = hasSpeech;
      return hasSpeech;
    } catch (e) {
      debugPrint('[VoiceAssistant] Speech initialization error: $e');
      speechAvailable.value = false;
      return false;
    }
  }

  /// Toggle Speech Listening Session
  Future<void> toggleListening() async {
    if (isListening.value) {
      await stopListening();
    } else {
      await startListening();
    }
  }

  /// Start Listening to user's speech
  Future<void> startListening() async {
    if (isSpeaking.value) {
      await stopSpeaking();
    }

    if (isProcessing.value) {
      return;
    }

    errorMessage.value = '';

    if (!speechAvailable.value) {
      final initialized = await _initSpeech();
      if (!initialized) {
        Get.snackbar(
          LanguageController.isAppHindi ? 'माइक्रोफ़ोन अनुमति आवश्यक' : 'Microphone Permission Needed',
          LanguageController.isAppHindi
              ? 'कृपया सेटिंग्स में माइक्रोफ़ोन की अनुमति दें।'
              : 'Please enable microphone access in settings.',
          backgroundColor: Colors.orange.shade800,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
        );
        return;
      }
    }

    // Determine recognition locale based on settings & context
    String targetLocale = 'hi_IN';
    if (selectedLanguageMode.value == 'en') {
      targetLocale = 'en_IN';
    } else if (selectedLanguageMode.value == 'hi') {
      targetLocale = 'hi_IN';
    } else {
      // Auto: prefer Hindi if app is in Hindi, otherwise English
      targetLocale = LanguageController.isAppHindi ? 'hi_IN' : 'en_IN';
    }

    // Verify locale availability
    try {
      final availableLocales = await _speech.locales();
      final hasPrefix = availableLocales.any(
        (l) => l.localeId.toLowerCase().startsWith(targetLocale.substring(0, 2)),
      );
      if (hasPrefix) {
        final match = availableLocales.firstWhere(
          (l) => l.localeId.toLowerCase().startsWith(targetLocale.substring(0, 2)),
        );
        targetLocale = match.localeId;
      }
    } catch (_) {}

    userTranscript.value = '';
    isListening.value = true;

    try {
      await _speech.listen(
        onResult: (SpeechRecognitionResult result) {
          userTranscript.value = result.recognizedWords;
          if (result.finalResult && userTranscript.value.trim().isNotEmpty) {
            stopListening();
            processQuery(userTranscript.value);
          }
        },
        onSoundLevelChange: (level) {
          soundLevel.value = level.clamp(0.0, 1.0);
        },
        localeId: targetLocale,
        listenFor: const Duration(seconds: 25),
        pauseFor: const Duration(seconds: 3),
        cancelOnError: false,
        partialResults: true,
      );

      // Timeout safeguard
      _speechTimeoutTimer?.cancel();
      _speechTimeoutTimer = Timer(const Duration(seconds: 26), () {
        if (isListening.value) {
          stopListening();
          if (userTranscript.value.trim().isNotEmpty) {
            processQuery(userTranscript.value);
          }
        }
      });
    } catch (e) {
      isListening.value = false;
      errorMessage.value = 'Failed to start listening: $e';
    }
  }

  /// Stop active listening
  Future<void> stopListening() async {
    _speechTimeoutTimer?.cancel();
    isListening.value = false;
    soundLevel.value = 0.0;
    try {
      await _speech.stop();
    } catch (_) {}
  }

  /// Automatically detect language of user's query
  String detectLanguage(String query) {
    if (selectedLanguageMode.value != 'auto') {
      return selectedLanguageMode.value;
    }

    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return LanguageController.isAppHindi ? 'hi' : 'en';
    }

    // 1. Devanagari script detection (Hindi, Marathi, etc.)
    if (RegExp(r'[\u0900-\u097F]').hasMatch(trimmed)) {
      return 'hi';
    }

    // 2. Hinglish / Indian agricultural keywords written in Latin script
    final hinglishKeywords = {
      'kheti', 'fasal', 'kisan', 'kisaan', 'patte', 'paani', 'pani', 'peele', 'pila',
      'rog', 'bimari', 'keeda', 'keede', 'kit', 'khad', 'khaad', 'dawa', 'davai',
      'tamatar', 'gehu', 'chana', 'soya', 'soyabean', 'dhan', 'chawal', 'sarson',
      'mandi', 'bhav', 'rate', 'dam', 'daam', 'barish', 'mausam', 'sukha', 'urea',
      'dap', 'npk', 'sinchai', 'katai', 'beej', 'kya', 'kaise', 'kab', 'kyu', 'kyun',
      'batao', 'bataiye', 'madad', 'sahayata', 'karo', 'kare', 'karein', 'nahi',
      'ho', 'raha', 'rahi', 'hai', 'hain', 'mujhe', 'meri', 'mera', 'apne', 'khet'
    };

    final words = trimmed.toLowerCase().split(RegExp(r'\s+'));
    for (final w in words) {
      final clean = w.replaceAll(RegExp(r'[^\w]'), '');
      if (hinglishKeywords.contains(clean)) {
        return 'hi';
      }
    }

    // Default to English if Latin script and no Hinglish markers found
    return 'en';
  }

  /// Process User Query with AgriBot AI
  Future<void> processQuery(String queryText) async {
    final query = queryText.trim();
    if (query.isEmpty || isProcessing.value) return;

    if (isListening.value) {
      await stopListening();
    }
    if (isSpeaking.value) {
      await stopSpeaking();
    }

    isProcessing.value = true;
    errorMessage.value = '';

    // Language identification
    final lang = detectLanguage(query);
    detectedLanguage.value = lang;

    // Add to history
    _history.add({'role': 'user', 'content': query});

    try {
      final response = await http
          .post(
            Uri.parse('${AppConfig.baseUrl}/agri-chat'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'message': query,
              'language': lang,
              'history': _history.take(6).toList(),
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'Success') {
          final reply = data['data']['reply']?.toString() ?? '';
          aiResponse.value = reply;
          _history.add({'role': 'assistant', 'content': reply});

          // Speak the response aloud in the matched language
          await speakResponse(reply, language: lang);
        } else {
          final err = data['error']?.toString() ?? 'Failed to get answer';
          errorMessage.value = err;
        }
      } else {
        errorMessage.value = lang == 'hi'
            ? 'सर्वर से संपर्क नहीं हो पाया (कोड: ${response.statusCode})'
            : 'Server communication error (code: ${response.statusCode})';
      }
    } catch (e) {
      errorMessage.value = lang == 'hi'
          ? 'नेटवर्क समस्या या अनुरोध समय समाप्त हुआ: $e'
          : 'Network timeout or connection error: $e';
    } finally {
      isProcessing.value = false;
    }
  }

  /// Clean markdown and symbols for natural spoken speech
  String _cleanTextForSpeech(String input) {
    String text = input;
    // Remove markdown code blocks
    text = text.replaceAll(RegExp(r'```[\s\S]*?```'), '');
    text = text.replaceAll(RegExp(r'`[^`]*`'), '');
    // Replace markdown links [label](url) with label
    text = text.replaceAllMapped(RegExp(r'\[([^\]]+)\]\([^)]+\)'), (m) => m.group(1) ?? '');
    // Remove markdown headers
    text = text.replaceAll(RegExp(r'#{1,6}\s*'), '');
    // Remove markdown bold/italics
    text = text.replaceAll(RegExp(r'[*_]{1,3}'), '');
    // Remove list markers
    text = text.replaceAll(RegExp(r'^\s*[-*•]\s*', multiLine: true), '');
    text = text.replaceAll(RegExp(r'^\s*\d+\.\s*', multiLine: true), '');
    // Clean emojis if they cause speech stutter
    text = text.replaceAll(RegExp(r'[\u{1F300}-\u{1F6FF}\u{1F900}-\u{1F9FF}]', unicode: true), '');
    // Normalize spaces and linebreaks
    text = text.replaceAll(RegExp(r'\n+'), '. ').replaceAll(RegExp(r'\s+'), ' ').trim();
    return text;
  }

  /// Speak AI response aloud using FlutterTts
  Future<void> speakResponse(String rawText, {String? language}) async {
    final speechText = _cleanTextForSpeech(rawText);
    if (speechText.isEmpty) return;

    try {
      await _flutterTts.stop();

      final targetLang = language ?? detectedLanguage.value;
      final ttsLocale = (targetLang == 'hi') ? 'hi-IN' : 'en-IN';

      // Set target locale
      await _flutterTts.setLanguage(ttsLocale);
      await _flutterTts.setSpeechRate(targetLang == 'hi' ? 0.46 : 0.48);

      isSpeaking.value = true;
      await _flutterTts.speak(speechText);
    } catch (e) {
      debugPrint('[VoiceAssistant] Error in speakResponse: $e');
      isSpeaking.value = false;
    }
  }

  /// Stop active TTS playback
  Future<void> stopSpeaking() async {
    try {
      await _flutterTts.stop();
    } catch (_) {}
    isSpeaking.value = false;
  }

  /// Repeat the last response
  Future<void> repeatResponse() async {
    if (aiResponse.value.isNotEmpty) {
      await speakResponse(aiResponse.value, language: detectedLanguage.value);
    }
  }

  /// Set explicit language mode ('auto', 'hi', 'en')
  void setLanguageMode(String mode) {
    selectedLanguageMode.value = mode;
    if (mode != 'auto') {
      detectedLanguage.value = mode;
    }
  }

  /// Reset current conversation
  void clearSession() {
    stopListening();
    stopSpeaking();
    userTranscript.value = '';
    aiResponse.value = '';
    errorMessage.value = '';
    _history.clear();
  }
}
