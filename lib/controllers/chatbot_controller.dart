import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

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
  final textController = TextEditingController();
  final scrollController = ScrollController();

  String get baseUrl => AppConfig.baseUrl;

  @override
  void onInit() {
    super.onInit();
    // Welcome message
    messages.add(ChatMessage(
      content: language.value == 'hi'
          ? '🌾 नमस्ते! मैं AgriBot हूं — आपका कृषि सहायक।\n\nमुझसे फसल, बीमारी, कीटनाशक, मंडी भाव, मौसम, या खेती से जुड़ा कोई भी सवाल पूछें!'
          : '🌾 Hello! I\'m AgriBot — your agriculture assistant.\n\nAsk me anything about crops, diseases, pesticides, market prices, weather, or farming!',
      isUser: false,
    ));
  }

  @override
  void onClose() {
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  /// Toggle language
  void toggleLanguage() {
    language.value = language.value == 'hi' ? 'en' : 'hi';
    messages.add(ChatMessage(
      content: language.value == 'hi'
          ? '🔄 भाषा बदली गई: हिंदी'
          : '🔄 Language changed: English',
      isUser: false,
    ));
    _scrollToBottom();
  }

  /// Send message to AgriBot
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message
    messages.add(ChatMessage(content: text.trim(), isUser: true));
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
              'message': text.trim(),
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
