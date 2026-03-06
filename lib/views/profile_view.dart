import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../controllers/auth_controller.dart';
import 'reports_view.dart';
import 'login_view.dart';
import 'soil_view.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(
                child: CircularProgressIndicator(color: Colors.green),
              )
            : RefreshIndicator(
                onRefresh: () => controller.fetchAlertStats(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // ── Profile Card ──
                      _buildProfileCard(controller),
                      const SizedBox(height: 16),

                      // ── Communication Buttons ──
                      _buildCommunicationButtons(controller),
                      const SizedBox(height: 16),

                      // ── Alert Stats ──
                      _buildStatsRow(controller),
                      const SizedBox(height: 16),

                      // ── Recent Alerts ──
                      _buildRecentAlerts(controller),
                      const SizedBox(height: 16),

                      // ── Test Alert Button ──
                      _buildTestAlertButton(controller),
                      const SizedBox(height: 16),

                      // ── View Reports ──
                      _buildReportsButton(),
                      const SizedBox(height: 16),

                      // ── Soil Analysis ──
                      _buildSoilAnalysisButton(),
                      const SizedBox(height: 16),

                      // ── Logout Button ──
                      _buildLogoutButton(),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildProfileCard(ProfileController c) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: const Icon(
              Icons.person_rounded,
              size: 45,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Obx(
            () => Text(
              c.farmerName.value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Obx(
            () => Text(
              '📍 ${c.farmerLocation.value}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Obx(
            () => Text(
              '🌾 Farm: ${c.farmSize.value}  •  📱 ${c.farmerPhone.value}',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.85),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Obx(
            () => Text(
              '📧 ${c.farmerEmail.value}',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.85),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Obx(
            () => c.enrollmentId.value.isNotEmpty
                ? Text(
                    '🆔 PM-KISAN: ${c.enrollmentId.value}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.85),
                      fontWeight: FontWeight.w500,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunicationButtons(ProfileController c) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🤖 AI Assistant',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Call our AI for instant farming advice',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () => c.callAIAssistant(),
              icon: const Icon(Icons.call_rounded, size: 26),
              label: const Text(
                'Call AI Assistant',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(ProfileController c) {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            '🔔',
            'Total Alerts',
            c.totalAlerts.value.toString(),
            Colors.orange,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            '🚨',
            'Critical',
            c.criticalAlerts.value.toString(),
            Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _statCard(String emoji, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildRecentAlerts(ProfileController c) {
    if (c.recentAlerts.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Column(
          children: [
            Icon(Icons.notifications_none, size: 40, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'No alerts at the moment',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📋 Recent Alerts',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ...c.recentAlerts.map((alert) => _alertTile(alert)),
        ],
      ),
    );
  }

  Widget _alertTile(Map<String, dynamic> alert) {
    final level = alert['alert_level'] ?? 'INFO';
    final type = alert['type'] ?? 'unknown';
    final crop = alert['crop_name'] ?? alert['soil_type'] ?? '';
    final time = alert['timestamp'] ?? '';

    Color levelColor;
    IconData levelIcon;
    switch (level) {
      case 'CRITICAL':
        levelColor = Colors.red;
        levelIcon = Icons.error;
        break;
      case 'WARNING':
        levelColor = Colors.orange;
        levelIcon = Icons.warning;
        break;
      default:
        levelColor = Colors.green;
        levelIcon = Icons.info;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: levelColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: levelColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(levelIcon, color: levelColor, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$level — $type',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: levelColor,
                    fontSize: 13,
                  ),
                ),
                if (crop.isNotEmpty)
                  Text(
                    crop,
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                Text(
                  time.length > 16 ? time.substring(0, 16) : time,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestAlertButton(ProfileController c) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: () => c.sendTestAlert(),
        icon: const Icon(Icons.send_rounded),
        label: const Text(
          'Send Test Alert 🧪',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1565C0),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 4,
        ),
      ),
    );
  }

  Widget _buildReportsButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: () => Get.to(() => const ReportsView()),
        icon: const Icon(Icons.analytics_rounded),
        label: const Text(
          '📊 View Reports',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6A1B9A),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 4,
        ),
      ),
    );
  }

  Widget _buildSoilAnalysisButton() {
    return InkWell(
      onTap: () => Get.to(() => const SoilView(showAppBar: true)),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF3E2723), Color(0xFF6D4C41)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3E2723).withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Text('🌍', style: TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Soil Analysis',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Scan soil & get plant/crop recommendations',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withOpacity(0.7),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: () async {
          final auth = Get.find<AuthController>();
          await auth.logout();
          Get.offAll(() => LoginView());
        },
        icon: const Icon(Icons.logout_rounded, color: Colors.red),
        label: const Text(
          'Logout',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.red,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.red, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
