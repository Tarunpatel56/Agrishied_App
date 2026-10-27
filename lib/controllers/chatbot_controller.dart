import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../config/app_config.dart';
import 'language_controller.dart';

class ChatMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.content,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toApiFormat() => {
        'role': isUser ? 'user' : 'assistant',
        'content': content,
      };
}

class ChatbotController extends GetxController {
  var messages = <ChatMessage>[].obs;
  var isTyping = false.obs;
  var language = 'hi'.obs; // hi = Hindi, en = English
  var isListening = false.obs;
  var speechAvailable = false.obs;
  var soundLevel = 0.0.obs;

  final textController = TextEditingController();
  final scrollController = ScrollController();
  final stt.SpeechToText _speech = stt.SpeechToText();

  String get baseUrl => AppConfig.baseUrl;

  @override
  void onInit() {
    super.onInit();
    // Sync language preference
    if (Get.isRegistered<LanguageController>()) {
      language.value = Get.find<LanguageController>().currentLanguage.value;
    } else {
      language.value = Get.locale?.languageCode ?? 'hi';
    }

    // Welcome message
    messages.add(ChatMessage(
      content: language.value == 'hi'
          ? '🌾 नमस्ते! मैं AgriBot हूं — आपका कृषि सहायक।\n\nमुझसे फसल, बीमारी, कीटनाशक, मंडी भाव, मौसम, या खेती से जुड़ा कोई भी सवाल पूछें!'
          : '🌾 Hello! I\'m AgriBot — your agriculture assistant.\n\nAsk me anything about crops, diseases, pesticides, market prices, weather, or farming!',
      isUser: false,
    ));

    // Initialize speech recognition early
    _initSpeech();
  }

  @override
  void onClose() {
    if (_speech.isListening) {
      _speech.stop();
    }
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  /// Initialize speech recognition engine
  Future<void> _initSpeech() async {
    try {
      speechAvailable.value = await _speech.initialize(
        onStatus: (status) {
          if (status == 'notListening' || status == 'done') {
            isListening.value = false;
          }
        },
        onError: (errorNotification) {
          isListening.value = false;
          print("[AgriBot] Speech error: ${errorNotification.errorMsg}");
        },
      );
    } catch (e) {
      speechAvailable.value = false;
      print("[AgriBot] Speech initialization exception: $e");
    }
  }

  /// Toggle language
  void toggleLanguage() {
    language.value = language.value == 'hi' ? 'en' : 'hi';
    if (_speech.isListening) {
      _speech.stop();
      isListening.value = false;
    }
    messages.add(ChatMessage(
      content: language.value == 'hi'
          ? '🔄 भाषा बदली गई: हिंदी'
          : '🔄 Language changed: English',
      isUser: false,
    ));
    _scrollToBottom();
  }

  /// Start or stop microphone speech recognition
  Future<void> toggleListening() async {
    if (isListening.value) {
      await stopListening();
      return;
    }

    if (!speechAvailable.value) {
      await _initSpeech();
      if (!speechAvailable.value) {
        Get.snackbar(
          language.value == 'hi' ? 'माइक्रोफ़ोन अनुपलब्ध' : 'Microphone Unavailable',
          language.value == 'hi'
              ? 'कृपया ऐप सेटिंग्स में माइक्रोफ़ोन की अनुमति दें।'
              : 'Please grant microphone permissions in app settings.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.shade800,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return;
      }
    }

    final isHi = language.value == 'hi';
    final targetLocaleId = isHi ? 'hi_IN' : 'en_IN';

    // Verify if preferred locale is available
    String selectedLocale = targetLocaleId;
    try {
      final locales = await _speech.locales();
      final hasLocale = locales.any((l) => l.localeId.toLowerCase().startsWith(isHi ? 'hi' : 'en'));
      if (hasLocale) {
        final match = locales.firstWhere((l) => l.localeId.toLowerCase().startsWith(isHi ? 'hi' : 'en'));
        selectedLocale = match.localeId;
      }
    } catch (_) {}

    isListening.value = true;

    try {
      await _speech.listen(
        onResult: (result) {
          textController.text = result.recognizedWords;
          textController.selection = TextSelection.fromPosition(
            TextPosition(offset: textController.text.length),
          );
          if (result.finalResult) {
            isListening.value = false;
          }
        },
        localeId: selectedLocale,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        onSoundLevelChange: (level) {
          soundLevel.value = level;
        },
        cancelOnError: true,
        partialResults: true,
      );
    } catch (e) {
      isListening.value = false;
      print("[AgriBot] Listen exception: $e");
    }
  }

  Future<void> stopListening() async {
    try {
      if (_speech.isListening) {
        await _speech.stop();
      }
    } catch (_) {}
    isListening.value = false;
  }

  /// Send message to AgriBot
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    if (isListening.value) {
      await stopListening();
    }

    final userQuery = text.trim();
    // Add user message
    messages.add(ChatMessage(content: userQuery, isUser: true));
    textController.clear();
    _scrollToBottom();

    // Show typing
    isTyping(true);

    try {
      // Build history from recent messages
      final history = messages
          .where((m) => !m.content.startsWith('🔄'))
          .take(20)
          .map((m) => m.toApiFormat())
          .toList();

      final response = await http
          .post(
            Uri.parse('$baseUrl/agri-chat'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'message': userQuery,
              'language': language.value,
              'history': history,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'Success') {
          final reply = data['data']['reply']?.toString() ?? 'Sorry, I could not process that.';
          messages.add(ChatMessage(content: reply, isUser: false));
        } else {
          messages.add(ChatMessage(
            content: language.value == 'hi'
                ? '❌ माफ कीजिए, कोई समस्या हुई। कृपया दोबारा प्रयास करें।'
                : '❌ Sorry, something went wrong. Please try again.',
            isUser: false,
          ));
        }
      } else {
        messages.add(ChatMessage(
          content: language.value == 'hi'
              ? '❌ सर्वर से कनेक्ट नहीं हो पाया। इंटरनेट चेक करें।'
              : '❌ Could not connect to server. Check your internet.',
          isUser: false,
        ));
      }
    } catch (e) {
      messages.add(ChatMessage(
        content: language.value == 'hi'
            ? '❌ कनेक्शन में समस्या आई। कृपया दोबारा प्रयास करें।'
            : '❌ Connection error. Please try again.',
        isUser: false,
      ));
    } finally {
      isTyping(false);
      _scrollToBottom();
    }
  }

  /// Handle mic result
  void onSpeechResult(String text) {
    if (text.trim().isNotEmpty) {
      textController.text = text;
      textController.selection = TextSelection.fromPosition(
        TextPosition(offset: textController.text.length),
      );
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}
