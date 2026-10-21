/// AgriShield AI — Centralized Backend API Service
/// ==================================================
/// Single source-of-truth for all HTTP calls to the
/// Flask backend (powered by Groq AI).
///
/// Backend base URL is read from AppConfig (app_config.dart).
/// All methods return the parsed JSON body or throw on error.
library;

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class ApiService {
  // ─── Singleton ────────────────────────────────────────────────
  ApiService._();
  static final ApiService instance = ApiService._();

  String get _base => AppConfig.baseUrl;

  // ─── Helpers ──────────────────────────────────────────────────
  Map<String, String> get _jsonHeaders => {'Content-Type': 'application/json'};

  Future<Map<String, dynamic>> _get(String path,
      {Map<String, String>? params, Duration timeout = const Duration(seconds: 20)}) async {
    final uri = Uri.parse('$_base$path').replace(queryParameters: params);
    final response = await http.get(uri).timeout(timeout);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body,
      {Duration timeout = const Duration(seconds: 60)}) async {
    final response = await http
        .post(Uri.parse('$_base$path'), headers: _jsonHeaders, body: json.encode(body))
        .timeout(timeout);
    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final decoded = json.decode(response.body);
    if (response.statusCode == 200) return decoded as Map<String, dynamic>;
    final errMsg = (decoded as Map<String, dynamic>)['error'] ?? 'Unknown error';
    throw Exception('Backend error ${response.statusCode}: $errMsg');
  }

  // ─── 1. Health Check ──────────────────────────────────────────
  /// GET /
  Future<Map<String, dynamic>> healthCheck() => _get('/');

  // ─── 2. Crop Analysis (Vision AI) ────────────────────────────
  /// POST /predict   multipart image upload → Groq llama-4-scout vision
  Future<Map<String, dynamic>> analyzeCrop(File imageFile) async {
    final request = http.MultipartRequest('POST', Uri.parse('$_base/predict'));
    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
    final streamed = await request.send().timeout(const Duration(seconds: 90));
    final response = await http.Response.fromStream(streamed);
    return _handleResponse(response);
  }

  // ─── 3. Last Scan ─────────────────────────────────────────────
  /// GET /last-scan
  Future<Map<String, dynamic>> getLastScan() => _get('/last-scan');

  // ─── 4. Weather Advisory ──────────────────────────────────────
  /// GET /weather-advisory?lat=&lon=
  Future<Map<String, dynamic>> getWeather({
    double lat = 22.7196,
    double lon = 75.8577,
  }) =>
      _get('/weather-advisory', params: {
        'lat': lat.toString(),
        'lon': lon.toString(),
        't': DateTime.now().millisecondsSinceEpoch.toString(),
      });

  // ─── 5. Mandi Prices ──────────────────────────────────────────
  /// GET /mandi-prices
  Future<Map<String, dynamic>> getMandiPrices() => _get('/mandi-prices');

  // ─── 6. Soil Analysis (Vision AI) ────────────────────────────
  /// POST /analyze-soil   multipart image upload → Groq llama-4-scout vision
  Future<Map<String, dynamic>> analyzeSoil(File imageFile) async {
    final request = http.MultipartRequest('POST', Uri.parse('$_base/analyze-soil'));
    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
    final streamed = await request.send().timeout(const Duration(seconds: 90));
    final response = await http.Response.fromStream(streamed);
    return _handleResponse(response);
  }

  // ─── 7. Soil Plant Recommendations ───────────────────────────
  /// POST /soil-plant-recommendations   body: soil_data JSON
  Future<Map<String, dynamic>> getSoilPlantRecommendations(Map<String, dynamic> soilData) =>
      _post('/soil-plant-recommendations', soilData);

  // ─── 8. Recovery Advice ───────────────────────────────────────
  /// POST /recovery-advice   body: scan data JSON → Groq llama-3.3-70b
  Future<Map<String, dynamic>> getRecoveryAdvice(Map<String, dynamic> scanData) =>
      _post('/recovery-advice', scanData, timeout: const Duration(seconds: 60));

  // ─── 9. ROI Calculator ────────────────────────────────────────
  /// POST /roi-calculate   body: investment_amount, land_size, crop_name
  Future<Map<String, dynamic>> calculateRoi({
    required int investmentAmount,
    required double landSize,
    String cropName = 'General',
  }) =>
      _post('/roi-calculate', {
        'investment_amount': investmentAmount,
        'land_size': landSize,
        'crop_name': cropName,
      }, timeout: const Duration(seconds: 60));

  // ─── 10. Market Predictions ───────────────────────────────────
  /// GET /market-predictions → Groq llama-3.3-70b
  Future<Map<String, dynamic>> getMarketPredictions() =>
      _get('/market-predictions', timeout: const Duration(seconds: 60));

  // ─── 11. AgriBot Chat ─────────────────────────────────────────
  /// POST /agri-chat   body: message, language, history → Groq llama-3.3-70b
  Future<Map<String, dynamic>> agriChat({
    required String message,
    String language = 'hi',
    List<Map<String, String>> history = const [],
  }) =>
      _post('/agri-chat', {
        'message': message,
        'language': language,
        'history': history,
      }, timeout: const Duration(seconds: 45));

  // ─── 12. Government Schemes ───────────────────────────────────
  /// GET /govt-schemes
  Future<Map<String, dynamic>> getGovtSchemes() => _get('/govt-schemes');

  // ─── 13. Send Alert (Twilio + Groq Voice) ────────────────────
  /// POST /send-alert
  Future<Map<String, dynamic>> sendAlert({
    String? phone,
    Map<String, dynamic>? scanData,
    String? message,
    String level = 'INFO',
  }) =>
      _post('/send-alert', {
        if (phone != null) 'phone': phone,
        if (scanData != null) 'scan_data': scanData,
        if (message != null) 'message': message,
        'level': level,
      });

  // ─── 14. Alert History ────────────────────────────────────────
  /// GET /alert-history?limit=50
  Future<Map<String, dynamic>> getAlertHistory({int limit = 50}) =>
      _get('/alert-history', params: {'limit': limit.toString()});

  // ─── 15. AI Model Info ────────────────────────────────────────
  /// GET /ai-info → returns active Groq model details
  /// Models (Oct 2026):
  ///   text   → moonshotai/kimi-k2-instruct  (1T MoE, 128K ctx)
  ///   vision → meta-llama/llama-4-scout-17b-16e-instruct
  ///   fallback → openai/gpt-oss-120b
  Future<Map<String, dynamic>> getAiInfo() => _get('/ai-info');
}
