import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/firestore_service.dart';

class ReportsController extends GetxController {
  var isLoading = false.obs;
  var cropScans = <Map<String, dynamic>>[].obs;
  var soilAnalyses = <Map<String, dynamic>>[].obs;
  var alertHistory = <Map<String, dynamic>>[].obs;
  var lastScan = Rxn<Map<String, dynamic>>();

  // Stats
  var avgHealthScore = 0.0.obs;
  var totalScans = 0.obs;
  var diseasesDetected = 0.obs;
  var totalAlerts = 0.obs;

  static const String baseUrl = 'http://10.179.18.46:5000';

  @override
  void onInit() {
    super.onInit();
    loadAllData();
  }

  Future<void> loadAllData() async {
    isLoading(true);
    await Future.wait([
      fetchCropScans(),
      fetchSoilAnalyses(),
      fetchAlertHistory(),
      fetchLastScan(),
    ]);
    _computeStats();
    isLoading(false);
  }

  void _computeStats() {
    totalScans.value = cropScans.length;

    if (cropScans.isNotEmpty) {
      double total = 0;
      int diseaseCount = 0;
      for (var scan in cropScans) {
        total += (scan['health_score'] ?? 0).toDouble();
        String disease = scan['disease']?.toString() ?? '';
        if (disease.isNotEmpty &&
            disease.toLowerCase() != 'no disease detected' &&
            disease.toLowerCase() != 'none') {
          diseaseCount++;
        }
      }
      avgHealthScore.value = total / cropScans.length;
      diseasesDetected.value = diseaseCount;
    }

    totalAlerts.value = alertHistory.length;
  }

  Future<void> fetchCropScans() async {
    try {
      final scans = await FirestoreService.getCriticalCropScans(healthThreshold: 100);
      cropScans.value = scans;
    } catch (e) {
      print('[Reports] Crop scan error: $e');
    }
  }

  Future<void> fetchSoilAnalyses() async {
    try {
      final analyses = await FirestoreService.getRecentSoilAnalyses(limit: 20);
      soilAnalyses.value = analyses;
    } catch (e) {
      print('[Reports] Soil analysis error: $e');
    }
  }

  Future<void> fetchAlertHistory() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/alert-history?limit=50'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'Success') {
          alertHistory.value = List<Map<String, dynamic>>.from(
              (data['data'] as List).map((a) => Map<String, dynamic>.from(a)));
        }
      }
    } catch (e) {
      print('[Reports] Alert history error: $e');
    }
  }

  Future<void> fetchLastScan() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/last-scan'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'Success') {
          lastScan.value = Map<String, dynamic>.from(data['data']);
        }
      }
    } catch (e) {
      print('[Reports] Last scan error: $e');
    }
  }
}
