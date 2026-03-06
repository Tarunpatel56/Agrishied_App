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
import '../controllers/auth_controller.dart';
import 'login_view.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final RxInt currentIndex = 0.obs;

  final List<Widget> pages = [
    const ScanView(),
    const Wx(),
    const ClaimsView(),
    const ProfileView(),
  ];

  final List<String> pageTitles = [
    'AgriShield AI',
    'Weather',
    'Claims',
    'Profile',
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          appBar: AppBar(
            title: Text(pageTitles[currentIndex.value]),
            centerTitle: true,
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
            elevation: 2,
            automaticallyImplyLeading: currentIndex.value == 0,
            actions: currentIndex.value == 0
                ? [
                    IconButton(
                      onPressed: () {
                        currentIndex.value = 3;
                      },
                      icon: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: const Icon(Icons.person, size: 20),
                      ),
                      tooltip: 'Profile',
                    ),
                  ]
                : null,
          ),
          drawer: currentIndex.value == 0 ? _buildDrawer(context) : null,
          body: pages[currentIndex.value],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: currentIndex.value,
            onTap: (index) => currentIndex.value = index,
            selectedItemColor: const Color(0xFF2E7D32),
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.camera_alt),
                label: 'Scan',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.cloud),
                label: 'Weather',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shield_rounded),
                label: 'Claims',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
            ],
          ),
        ));
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // ── Drawer Header ──
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              bottom: 20,
              left: 20,
              right: 20,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 65,
                  height: 65,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.eco, size: 32, color: Colors.white),
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
                  'Smart Farming System 🌱',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.85),
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
                  icon: Icons.camera_alt_rounded,
                  label: 'Crop Scan',
                  emoji: '📷',
                  onTap: () {
                    currentIndex.value = 0;
                    Get.back();
                  },
                ),
                _drawerItem(
                  icon: Icons.cloud_rounded,
                  label: 'Weather',
                  emoji: '🌤️',
                  onTap: () {
                    currentIndex.value = 1;
                    Get.back();
                  },
                ),
                _drawerItem(
                  icon: Icons.store_rounded,
                  label: 'Market Rates',
                  emoji: '🏪',
                  onTap: () {
                    Get.back();
                    Get.to(() => const MarketView());
                  },
                ),
                _drawerItem(
                  icon: Icons.landscape_rounded,
                  label: 'Soil Analysis',
                  emoji: '🌍',
                  onTap: () {
                    Get.back();
                    Get.to(() => const SoilView(showAppBar: true));
                  },
                ),
                _drawerItem(
                  icon: Icons.account_balance_rounded,
                  label: 'Govt Schemes',
                  emoji: '🏦',
                  onTap: () {
                    Get.back();
                    Get.to(() => const GovtSchemesView());
                  },
                ),
                _drawerItem(
                  icon: Icons.shield_rounded,
                  label: 'Buy Insurance',
                  emoji: '🛡️',
                  onTap: () {
                    Get.back();
                    Get.to(() => const BuyPolicyView());
                  },
                ),
                const Divider(height: 20, indent: 16, endIndent: 16),
                _drawerItem(
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  emoji: '👤',
                  onTap: () {
                    currentIndex.value = 3;
                    Get.back();
                  },
                ),
                _drawerItem(
                  icon: Icons.analytics_rounded,
                  label: 'Reports',
                  emoji: '📊',
                  onTap: () {
                    Get.back();
                    Get.to(() => const ReportsView());
                  },
                ),
                const Divider(height: 20, indent: 16, endIndent: 16),
                _drawerItem(
                  icon: Icons.logout_rounded,
                  label: 'Logout',
                  emoji: '🚪',
                  color: Colors.red,
                  onTap: () async {
                    Get.back();
                    final auth = Get.find<AuthController>();
                    await auth.logout();
                    Get.offAll(() => LoginView());
                  },
                ),
              ],
            ),
          ),

          // ── Footer ──
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              'AgriShield AI v1.0',
              style: TextStyle(fontSize: 11, color: Colors.grey[400]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String label,
    required String emoji,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Text(emoji, style: const TextStyle(fontSize: 22)),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: color ?? Colors.black87,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: color?.withOpacity(0.5) ?? Colors.grey[400],
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
    );
  }
}
