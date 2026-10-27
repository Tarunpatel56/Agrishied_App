import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/voice_assistant_controller.dart';
import '../controllers/language_controller.dart';

/// Voice Assistant View
/// Dedicated Voice-First interaction screen for Indian farmers.
/// Allows spoken input in Hindi or English, analyzes via AgriBot AI,
/// and responds aloud in the user's spoken language.
class VoiceAssistantView extends StatefulWidget {
  const VoiceAssistantView({super.key});

  @override
  State<VoiceAssistantView> createState() => _VoiceAssistantViewState();
}

class _VoiceAssistantViewState extends State<VoiceAssistantView>
    with SingleTickerProviderStateMixin {
  late final VoiceAssistantController c;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  static const _primary = Color(0xFF1B5E20);
  static const _primaryLight = Color(0xFF2E7D32);
  static const _accent = Color(0xFF00E676);
  static const _listeningColor = Color(0xFFD32F2F);

  @override
  void initState() {
    super.initState();
    c = Get.put(VoiceAssistantController());

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF4F6F4),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildLanguageSelector(),
              const SizedBox(height: 16),
              _buildMainMicInterface(),
              const SizedBox(height: 16),
              _buildTranscriptCard(),
              const SizedBox(height: 12),
              _buildResponseCard(),
              const SizedBox(height: 16),
              _buildQuickSuggestions(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  /// Language Selection / Mode Selector bar
  Widget _buildLanguageSelector() {
    return Obx(() {
      final isHi = LanguageController.isAppHindi;
      final currentMode = c.selectedLanguageMode.value;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.translate, size: 20, color: _primaryLight),
            const SizedBox(width: 8),
            Text(
              isHi ? 'आवाज़ की भाषा:' : 'Speech Mode:',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const Spacer(),
            _buildModeChip('auto', isHi ? 'ऑटो' : 'Auto', currentMode == 'auto'),
            const SizedBox(width: 6),
            _buildModeChip('hi', 'हिंदी', currentMode == 'hi'),
            const SizedBox(width: 6),
            _buildModeChip('en', 'English', currentMode == 'en'),
            const SizedBox(width: 8),
            if (c.userTranscript.isNotEmpty || c.aiResponse.isNotEmpty)
              IconButton(
                onPressed: () => c.clearSession(),
                icon: const Icon(Icons.refresh, size: 20, color: Colors.grey),
                tooltip: isHi ? 'नया सत्र' : 'Reset session',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildModeChip(String mode, String label, bool isSelected) {
    return InkWell(
      onTap: () => c.setLanguageMode(mode),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? _primary : const Color(0xFFEEEEEE),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  /// Big central microphone interaction container
  Widget _buildMainMicInterface() {
    return Obx(() {
      final isHi = LanguageController.isAppHindi;
      final isListening = c.isListening.value;
      final isProcessing = c.isProcessing.value;
      final isSpeaking = c.isSpeaking.value;

      String statusText = isHi ? 'बोलने के लिए माइक दबाएं' : 'Tap microphone to speak';
      Color ringColor = _primary;

      if (isListening) {
        statusText = isHi ? 'सुन रहा हूँ... अपनी बात कहिए' : 'Listening... Speak now';
        ringColor = _listeningColor;
      } else if (isProcessing) {
        statusText = isHi ? 'समझ रहा हूँ और सलाह तैयार कर रहा हूँ...' : 'Thinking & preparing advice...';
        ringColor = Colors.orange.shade700;
      } else if (isSpeaking) {
        statusText = isHi ? 'उत्तर सुनाया जा रहा है...' : 'Speaking response...';
        ringColor = _accent;
      }

      return Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isListening
                ? [const Color(0xFFFFEBEE), Colors.white]
                : [const Color(0xFFE8F5E9), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isListening ? Colors.red.shade200 : const Color(0xFFC8E6C9),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Circular Microphone Button with Dynamic Glow
            GestureDetector(
              onTap: () {
                if (isSpeaking) {
                  c.stopSpeaking();
                } else if (isListening) {
                  c.stopListening();
                } else {
                  c.startListening();
                }
              },
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  final scale = isListening ? _pulseAnimation.value : 1.0;
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: isListening
                              ? [const Color(0xFFE53935), const Color(0xFFB71C1C)]
                              : isProcessing
                                  ? [Colors.orange.shade600, Colors.orange.shade800]
                                  : isSpeaking
                                      ? [const Color(0xFF2E7D32), const Color(0xFF1B5E20)]
                                      : [const Color(0xFF2E7D32), const Color(0xFF1B5E20)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (isListening ? Colors.red : _primary).withValues(alpha: 0.35),
                            blurRadius: isListening ? 20 : 12,
                            spreadRadius: isListening ? 4 : 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: isProcessing
                            ? const SizedBox(
                                width: 36,
                                height: 36,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3.5,
                                ),
                              )
                            : Icon(
                                isListening
                                    ? Icons.mic
                                    : isSpeaking
                                        ? Icons.volume_up_rounded
                                        : Icons.mic_none_rounded,
                                size: 48,
                                color: Colors.white,
                              ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Status message
            Text(
              statusText,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: ringColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isHi
                  ? 'फसल, बीमारी, खाद, कीटनाशक या मंडी भाव के बारे में पूछें'
                  : 'Ask about crops, diseases, fertilizers, pesticides, or mandi prices',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),

            // Sound level audio wave indicator when listening
            if (isListening) ...[
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(7, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2.5),
                    width: 4,
                    height: 12.0 + (index % 3 == 0 ? 16 : 8) * (c.soundLevel.value + 0.2),
                    decoration: BoxDecoration(
                      color: _listeningColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ],

            // Active Controls Bar (Stop / Repeat / Speak Again)
            if (c.aiResponse.isNotEmpty || isSpeaking) ...[
              const SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (isSpeaking)
                    ElevatedButton.icon(
                      onPressed: () => c.stopSpeaking(),
                      icon: const Icon(Icons.stop_circle_outlined, size: 18),
                      label: Text(isHi ? 'बोलना बंद करें' : 'Stop Speaking'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    )
                  else ...[
                    ElevatedButton.icon(
                      onPressed: () => c.repeatResponse(),
                      icon: const Icon(Icons.volume_up, size: 18),
                      label: Text(isHi ? 'दोबारा सुनें' : 'Repeat Audio'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryLight,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => c.startListening(),
                      icon: const Icon(Icons.mic, size: 18, color: _primary),
                      label: Text(
                        isHi ? 'दूसरा सवाल पूछें' : 'Ask Another Question',
                        style: const TextStyle(color: _primary),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: _primary, width: 1.5),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      );
    });
  }

  /// Recognized User Speech Transcript Card
  Widget _buildTranscriptCard() {
    return Obx(() {
      final text = c.userTranscript.value;
      if (text.isEmpty) return const SizedBox.shrink();

      final isHi = LanguageController.isAppHindi;
      final detectedLang = c.detectedLanguage.value == 'hi' ? 'हिंदी (Hindi)' : 'English';

      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE0E0E0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.record_voice_over, size: 16, color: _primaryLight),
                const SizedBox(width: 6),
                Text(
                  isHi ? 'आपने पूछा:' : 'You Asked:',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: _primary),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Text(
                    detectedLang,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green.shade800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '"$text"',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87, height: 1.3),
            ),
          ],
        ),
      );
    });
  }

  /// AI Spoken Response Card
  Widget _buildResponseCard() {
    return Obx(() {
      final reply = c.aiResponse.value;
      final error = c.errorMessage.value;

      if (error.isNotEmpty) {
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFEBEE),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red.shade300),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  error,
                  style: const TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        );
      }

      if (reply.isEmpty) return const SizedBox.shrink();

      final isHi = LanguageController.isAppHindi;
      final isSpeaking = c.isSpeaking.value;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFA5D6A7), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.eco, size: 18, color: _primary),
                ),
                const SizedBox(width: 8),
                Text(
                  isHi ? 'कृषि विशेषज्ञ सलाह:' : 'AgriShield Advice:',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: _primary,
                  ),
                ),
                const Spacer(),
                if (isSpeaking)
                  Row(
                    children: [
                      const Icon(Icons.graphic_eq, size: 16, color: _accent),
                      const SizedBox(width: 4),
                      Text(
                        isHi ? 'बोल रहा है...' : 'Speaking...',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _primaryLight),
                      ),
                    ],
                  ),
              ],
            ),
            const Divider(height: 18, color: Color(0xFFE8F5E9)),
            SelectableText(
              reply,
              style: const TextStyle(
                fontSize: 14.5,
                height: 1.5,
                color: Color(0xFF212121),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      );
    });
  }

  /// Quick Suggestions for Farmers
  Widget _buildQuickSuggestions() {
    final isHi = LanguageController.isAppHindi;

    final suggestionsHi = [
      '🌱 सोयाबीन में पीले पत्ते क्यों हो रहे हैं?',
      '🌾 धान में पत्ता लपेटक कीट का तुरंत उपचार',
      '🌧️ अगले 3 दिनों में बारिश होगी क्या?',
      '🧪 गेहूं की बुवाई में डीएपी और यूरिया की मात्रा',
      '🍅 टमाटर में फल छेदक इल्ली की रोकथाम',
      '📈 आज मंडी में सोयाबीन और चना का भाव क्या है?',
    ];

    final suggestionsEn = [
      '🌱 Why are my soybean leaves turning yellow?',
      '🌾 Best cure for leaf folder pest in paddy?',
      '🌧️ Will it rain in the next 3 days?',
      '🧪 Recommended DAP & Urea dosage for wheat',
      '🍅 How to prevent fruit borer in tomatoes?',
      '📈 What are today\'s market rates for soybean?',
    ];

    final list = isHi ? suggestionsHi : suggestionsEn;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.tips_and_updates_outlined, size: 16, color: _primaryLight),
            const SizedBox(width: 6),
            Text(
              isHi ? 'सुझाए गए सवाल (टैप करें):' : 'Suggested Questions (Tap to ask):',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: list.map((q) {
            return InkWell(
              onTap: () {
                c.userTranscript.value = q;
                c.processQuery(q);
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: Text(
                  q,
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: Color(0xFF333333)),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
