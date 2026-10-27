import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agrishield_app/views/scan_view.dart';
import 'package:agrishield_app/views/wx.dart';
import 'package:agrishield_app/views/market_view.dart';
import 'package:agrishield_app/views/claims_view.dart';
import 'package:agrishield_app/views/soil_view.dart';
import 'package:agrishield_app/views/profile_view.dart';
import 'package:agrishield_app/views/reports_view.dart';
import 'package:agrishield_app/views/govt_schemes_view.dart';
import 'package:agrishield_app/views/buy_policy_view.dart';
import 'package:agrishield_app/views/recovery_dashboard_view.dart';
import 'package:agrishield_app/views/roi_calculator_view.dart';
import 'package:agrishield_app/views/market_predictor_view.dart';
import 'package:agrishield_app/views/claim_reinvest_view.dart';
import 'package:agrishield_app/views/chatbot_view.dart';
import 'package:agrishield_app/views/voice_assistance_view.dart';
import 'package:agrishield_app/views/voice_assistant_view.dart';
import 'package:agrishield_app/views/spray_advisor_view.dart';
import 'package:agrishield_app/views/fertilizer_advisor_view.dart';
import '../controllers/auth_controller.dart';

import 'login_view.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final RxInt currentIndex = 0.obs;

  final List<Widget> pages = [
    const ScanView(),
    const Wx(),
    const VoiceAssistantView(),
    const ClaimsView(),
    const ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {

    final List<String> pageTitles = [
      'app_name'.tr,
      'weather'.tr,
      'voice_assistant'.tr,
      'claims'.tr,
      'profile'.tr,
    ];

    return Obx(() => Scaffold(
          appBar: AppBar(
            title: Text(
              currentIndex.value == 0 ? 'AgriShield AI' : pageTitles[currentIndex.value],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            centerTitle: false,
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
            elevation: 1,
            automaticallyImplyLeading: currentIndex.value == 0,
            actions: [
              IconButton(
                onPressed: () {
                  currentIndex.value = 4;
                },
                icon: const Icon(Icons.account_circle_outlined, color: Colors.white, size: 28),
                tooltip: 'profile'.tr,
              ),
            ],
          ),
          drawer: currentIndex.value == 0 ? _buildDrawer(context) : null,
          body: pages[currentIndex.value],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: currentIndex.value,
            onTap: (index) => currentIndex.value = index,
            selectedItemColor: const Color(0xFF2E7D32),
            unselectedItemColor: const Color(0xFF757575),
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontSize: 12),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            elevation: 8,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.camera_alt_outlined),
                activeIcon: const Icon(Icons.camera_alt),
                label: 'scan'.tr,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.cloud_outlined),
                activeIcon: const Icon(Icons.cloud),
                label: 'weather'.tr,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.mic_none_rounded),
                activeIcon: const Icon(Icons.mic_rounded),
                label: 'voice_assistant'.tr,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.shield_outlined),
                activeIcon: const Icon(Icons.shield),
                label: 'claims'.tr,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person_outline),
                activeIcon: const Icon(Icons.person),
                label: 'profile'.tr,
              ),
            ],
          ),
        ));
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // ── Drawer Header ──
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              bottom: 22,
              left: 20,
              right: 20,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF388E3C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 2),
                  ),
                  child: Center(
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF1B5E20),
                      ),
                      child: const Center(
                        child: Icon(Icons.eco, size: 30, color: Color(0xFFA5D6A7)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'AgriShield AI',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Smart Farming & AI Protection',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),

          // ── Menu Items ──
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _drawerItem(
                  emoji: '📷',
                  label: 'scan'.tr,
                  onTap: () {
                    currentIndex.value = 0;
                    Get.back();
                  },
                ),
                _drawerItem(
                  emoji: '🌤️',
                  label: 'weather'.tr,
                  onTap: () {
                    currentIndex.value = 1;
                    Get.back();
                  },
                ),
                _drawerItem(
                  emoji: '🎙️',
                  label: 'voice_assistant'.tr,
                  onTap: () {
                    currentIndex.value = 2;
                    Get.back();
                  },
                ),
                _drawerItem(
                  emoji: '🏪',
                  label: 'market_rates'.tr,
                  onTap: () {
                    Get.back();
                    Get.to(() => const MarketView());
                  },
                ),
                _drawerItem(
                  emoji: '🌍',
                  label: 'soil_analysis'.tr,
                  onTap: () {
                    Get.back();
                    Get.to(() => const SoilView(showAppBar: true));
                  },
                ),
                _drawerItem(
                  emoji: '🏛️',
                  label: 'govt_schemes'.tr,
                  onTap: () {
                    Get.back();
                    Get.to(() => const GovtSchemesView());
                  },
                ),
                _drawerItem(
                  emoji: '🛡️',
                  label: 'buy_insurance'.tr,
                  onTap: () {
                    Get.back();
                    Get.to(() => const BuyPolicyView());
                  },
                ),
                const Divider(height: 16, indent: 16, endIndent: 16, color: Color(0xFFEEEEEE)),
                _drawerItem(
                  emoji: '👤',
                  label: 'profile'.tr,
                  onTap: () {
                    currentIndex.value = 4;
                    Get.back();
                  },
                ),
                _drawerItem(
                  emoji: '📊',
                  label: 'reports'.tr,
                  onTap: () {
                    Get.back();
                    Get.to(() => const ReportsView());
                  },
                ),
                const Divider(height: 16, indent: 16, endIndent: 16, color: Color(0xFFEEEEEE)),
                Padding(
                  padding: const EdgeInsets.only(left: 20, top: 4, bottom: 8),
                  child: Text(
                    'ai_features'.tr,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[500],
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                _drawerItem(
                  emoji: '🌦️',
                  label: 'spray_advisor'.tr,
                  onTap: () {
                    Get.back();
                    Get.to(() => const SprayAdvisorView());
                  },
                ),
                _drawerItem(
                  emoji: '📋',
                  label: 'fertilizer_advisor'.tr,
                  onTap: () {
                    Get.back();
                    Get.to(() => const FertilizerAdvisorView());
                  },
                ),
                _drawerItem(
                  emoji: '🔬',
                  label: 'recovery_advisor'.tr,
                  onTap: () {
                    Get.back();
                    Get.to(() => const RecoveryDashboardView());
                  },
                ),
                _drawerItem(
                  emoji: '💰',
                  label: 'roi_calculator'.tr,
                  onTap: () {
                    Get.back();
                    Get.to(() => const RoiCalculatorView());
                  },
                ),
                _drawerItem(
                  emoji: '📈',
                  label: 'market_predictor'.tr,
                  onTap: () {
                    Get.back();
                    Get.to(() => const MarketPredictorView());
                  },
                ),
                _drawerItem(
                  emoji: '🔗',
                  label: 'claim_reinvest'.tr,
                  onTap: () {
                    Get.back();
                    Get.to(() => const ClaimReinvestView());
                  },
                ),
                _drawerItem(
                  emoji: '🤖',
                  label: 'agribot_chat'.tr,
                  onTap: () {
                    Get.back();
                    Get.to(() => const ChatbotView());
                  },
                ),
              ],
            ),
          ),

          // ── Footer ──
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'AgriShield AI v1.0',
                style: TextStyle(fontSize: 12, color: Colors.grey[400], fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem({
    required String emoji,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: SizedBox(
        width: 32,
        child: Text(emoji, style: const TextStyle(fontSize: 20)),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: color ?? const Color(0xFF212121),
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        size: 20,
        color: Color(0xFFBDBDBD),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      minLeadingWidth: 32,
      dense: true,
    );
  }
}
