import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';

class VoiceAssistanceView extends StatefulWidget {
  const VoiceAssistanceView({super.key});

  @override
  State<VoiceAssistanceView> createState() => _VoiceAssistanceViewState();
}

class _VoiceAssistanceViewState extends State<VoiceAssistanceView> {
  final TextEditingController _phoneController = TextEditingController(text: '+91');
  bool _isLoading = false;
  String _statusMessage = '';
  bool _isSuccess = false;

  final String twilioHelplineNumber = '+1 251 313 0643';

  Future<void> _makeDirectCall() async {
    final uri = Uri.parse('tel:$twilioHelplineNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar('Dialer Error', 'Could not open phone dialer',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  Future<void> _requestAiCallback() async {
    final phone = _phoneController.text.trim();
    if (phone.length < 10) {
      Get.snackbar('Invalid Phone', 'Please enter a valid phone number with country code (e.g. +91XXXXXXXXXX)',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white);
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = '';
    });

    try {
      final res = await ApiService.instance.sendAlert(
        phone: phone,
        message: 'AgriShield AI Voice Call Requested. Dual-language selection active.',
        level: 'INFO',
      );

      setState(() {
        _isSuccess = true;
        _statusMessage = res['message'] ?? 'Voice call alert triggered successfully!';
      });
    } catch (e) {
      setState(() {
        _isSuccess = false;
        _statusMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F5),
      appBar: AppBar(
        title: Text('voice_assistance'.tr),
        centerTitle: true,
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Helpline Banner ──
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1B5E20), Color(0xFF388E3C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  const Icon(Icons.support_agent_rounded, size: 48, color: Colors.white),
                  const SizedBox(height: 10),
                  const Text(
                    '24x7 AgriShield AI Helpline',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    twilioHelplineNumber,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 1),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    onPressed: _makeDirectCall,
                    icon: const Icon(Icons.call, color: Color(0xFF1B5E20)),
                    label: const Text('Call Helpline Now', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Language Selection Call Flow Card ──
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.dialpad_rounded, color: Color(0xFF2E7D32), size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Interactive Voice Menu',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _stepItem(
                    step: '1',
                    title: 'Call AgriShield Voice Number',
                    subtitle: 'Twilio answers automatically with interactive voice response (IVR).',
                  ),
                  _stepItem(
                    step: '2',
                    title: 'Language Selection Prompt',
                    subtitle: '• Press 1 for Hindi (हिंदी के लिए 1 दबाएं)\n• Press 2 for English',
                    highlight: true,
                  ),
                  _stepItem(
                    step: '3',
                    title: 'Speak Agricultural Query',
                    subtitle: 'Ask about crop diseases, pest outbreaks, weather, or mandi prices.',
                  ),
                  _stepItem(
                    step: '4',
                    title: 'Bilingual AI Voice Response',
                    subtitle: 'AgriShield analyzes query and speaks back in the selected language (Amazon Polly Aditi/Kajal).',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Request Callback Card ──
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Request Instant AI Voice Call',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Enter farmer phone number to receive an automated advisory call.',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Farmer Phone Number',
                      hintText: '+919876543210',
                      prefixIcon: const Icon(Icons.phone_android_rounded, color: Color(0xFF2E7D32)),
                      filled: true,
                      fillColor: const Color(0xFFF9FBF8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _requestAiCallback,
                    icon: _isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.ring_volume_rounded),
                    label: Text(
                      _isLoading ? 'Initiating Call...' : 'request_call'.tr,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  if (_statusMessage.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _isSuccess ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _isSuccess ? Colors.green.shade300 : Colors.red.shade300),
                      ),
                      child: Text(
                        _statusMessage,
                        style: TextStyle(fontSize: 12, color: _isSuccess ? Colors.green[900] : Colors.red[900]),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Architecture & Security Note ──
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFECEFF1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock_outline_rounded, size: 20, color: Colors.blueGrey),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Twilio API credentials are kept strictly in backend environment variables. Webhook routes `/voice-incoming`, `/voice-lang-select`, and `/voice-respond` handle session state securely.',
                      style: TextStyle(fontSize: 11, color: Colors.blueGrey[800], height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepItem({
    required String step,
    required String title,
    required String subtitle,
    bool highlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: highlight ? const Color(0xFF2E7D32) : Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: highlight ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: highlight ? const Color(0xFF1B5E20) : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey[700], height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
