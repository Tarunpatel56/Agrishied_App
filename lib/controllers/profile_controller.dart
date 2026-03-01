import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileController extends GetxController {
  final _storage = GetStorage();
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  // Profile fields
  var farmerName = 'Farmer'.obs;
  var farmerPhone = ''.obs;
  var farmerEmail = ''.obs;
  var farmerLocation = 'Madhya Pradesh, India'.obs;
  var farmSize = '5 Acre'.obs;

  // Alert stats
  var totalAlerts = 0.obs;
  var criticalAlerts = 0.obs;
  var totalScans = 0.obs;
  var isLoading = false.obs;

  // Recent alerts
  var recentAlerts = <Map<String, dynamic>>[].obs;

  static const String baseUrl = 'http://10.179.18.46:5000';

  @override
  void onInit() {
    super.onInit();
    loadProfile();
    fetchAlertStats();
  }

  /// Load profile from Firestore (primary) + GetStorage (fallback)
  Future<void> loadProfile() async {
    // First load from local storage (instant)
    farmerName.value = _storage.read('farmer_name') ?? 'Farmer';
    farmerPhone.value = _storage.read('farmer_phone') ?? '';
    farmerEmail.value = _storage.read('farmer_email') ?? '';
    farmerLocation.value =
        _storage.read('farmer_location') ?? 'Madhya Pradesh, India';
    farmSize.value = _storage.read('farm_size') ?? '5 Acre';

    // Then try to load from Firestore (latest data)
    try {
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        final doc = await _db.collection('users').doc(uid).get();
        if (doc.exists) {
          final data = doc.data()!;
          farmerName.value = data['name'] ?? farmerName.value;
          farmerPhone.value = data['phone'] ?? farmerPhone.value;
          farmerEmail.value = data['email'] ?? farmerEmail.value;
          farmerLocation.value = data['location'] ?? farmerLocation.value;
          farmSize.value = data['farm_size'] ?? farmSize.value;

          // Sync to local storage
          _storage.write('farmer_name', farmerName.value);
          _storage.write('farmer_phone', farmerPhone.value);
          _storage.write('farmer_email', farmerEmail.value);
          _storage.write('farmer_location', farmerLocation.value);
          _storage.write('farm_size', farmSize.value);
        }
      }
    } catch (e) {
      print('[Profile] Firestore load error: $e');
    }
  }

  void saveProfile({
    String? name,
    String? phone,
    String? email,
    String? location,
    String? size,
  }) {
    if (name != null) {
      farmerName.value = name;
      _storage.write('farmer_name', name);
    }
    if (phone != null) {
      farmerPhone.value = phone;
      _storage.write('farmer_phone', phone);
    }
    if (email != null) {
      farmerEmail.value = email;
      _storage.write('farmer_email', email);
    }
    if (location != null) {
      farmerLocation.value = location;
      _storage.write('farmer_location', location);
    }
    if (size != null) {
      farmSize.value = size;
      _storage.write('farm_size', size);
    }
    Get.snackbar('✅ Saved', 'Profile updated successfully',
        snackPosition: SnackPosition.BOTTOM);
  }

  // ── Communication — Call AI Assistant via Twilio ────────────
  static const String twilioPhoneNumber = '+13639990565';

  Future<void> callAIAssistant() async {
    final url = Uri.parse('tel:$twilioPhoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      Get.snackbar('Error', 'Could not make the call',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  // ── Fetch alert stats from backend ─────────────────────────
  Future<void> fetchAlertStats() async {
    isLoading(true);
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/alert-history?limit=50'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'Success') {
          final List alerts = data['data'] ?? [];
          totalAlerts.value = alerts.length;
          criticalAlerts.value =
              alerts.where((a) => a['alert_level'] == 'CRITICAL').length;
          recentAlerts.value = List<Map<String, dynamic>>.from(
              alerts.take(5).map((a) => Map<String, dynamic>.from(a)));
        }
      }
    } catch (e) {
      print('[Profile] Alert fetch error: $e');
    } finally {
      isLoading(false);
    }
  }

  // ── Send test alert ────────────────────────────────────────
  Future<void> sendTestAlert() async {
    try {
      Get.snackbar('🔔 Sending...', 'Sending test alert...',
          snackPosition: SnackPosition.BOTTOM);
      final response = await http.post(
        Uri.parse('$baseUrl/send-alert'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'message': '🧪 Test Alert: AgriShield AI system is working! All systems OK.',
          'level': 'INFO',
        }),
      );
      if (response.statusCode == 200) {
        Get.snackbar('✅ Sent!', 'Test alert sent successfully!',
            snackPosition: SnackPosition.BOTTOM);
        fetchAlertStats();
      }
    } catch (e) {
      Get.snackbar('❌ Error', 'Could not send alert: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
