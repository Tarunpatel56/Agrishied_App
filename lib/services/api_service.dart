/// AgriShield AI — Centralized Backend API Service
/// ==================================================
/// Single source-of-truth for all HTTP calls to the Flask backend.
/// Backend base URL is read from AppConfig (app_config.dart).
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class ApiService {
  // ─── Singleton ────────────────────────────────────────────────
  ApiService._();
  static final ApiService instance = ApiService._();

  String get _base => AppConfig.baseUrl;

  String get _currentLang => Get.locale?.languageCode ?? 'hi';

  // ─── Helpers ──────────────────────────────────────────────────
  Map<String, String> get _jsonHeaders => {
        'Content-Type': 'application/json',
        'Accept-Language': _currentLang,
      };

  Future<Map<String, dynamic>> _get(
    String path, {
    Map<String, String>? params,
    Duration timeout = const Duration(seconds: 25),
  }) async {
    try {
      final query = Map<String, String>.from(params ?? {});
      if (!query.containsKey('lang')) {
        query['lang'] = _currentLang;
      }
      final uri = Uri.parse('$_base$path').replace(queryParameters: query);
      final response = await http.get(uri, headers: {'Accept-Language': _currentLang}).timeout(timeout);
      return _handleResponse(response);
    } on SocketException {
      throw Exception('Network error: Could not reach server. Please check your internet connection.');
    } on TimeoutException {
      throw Exception('Server took too long to respond. Render free servers may take ~30s to wake up on first request.');
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Invalid server response format.');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body, {
    Duration timeout = const Duration(seconds: 60),
  }) async {
    try {
      if (!body.containsKey('language')) {
        body['language'] = _currentLang;
      }
      final response = await http
          .post(Uri.parse('$_base$path'), headers: _jsonHeaders, body: json.encode(body))
          .timeout(timeout);
      return _handleResponse(response);
    } on SocketException {
      throw Exception('Network error: Could not reach server. Please check your internet connection.');
    } on TimeoutException {
      throw Exception('Server took too long to respond. Please try again.');
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Invalid server response format.');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _uploadMultipart(

    String path,
    File file, {
    Map<String, String>? extraFields,
    Duration timeout = const Duration(seconds: 90),
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse('$_base$path'));
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
      if (extraFields != null) {
        request.fields.addAll(extraFields);
      }
      final streamed = await request.send().timeout(timeout);
      final response = await http.Response.fromStream(streamed);
      return _handleResponse(response);
    } on SocketException {
      throw Exception('Network error during file upload. Check internet connectivity.');
    } on TimeoutException {
      throw Exception('File upload and analysis timed out. Please retry.');
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {

    try {
      final decoded = json.decode(utf8.decode(response.bodyBytes));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (decoded is Map<String, dynamic>) return decoded;
        if (decoded is List) return {'data': decoded, 'status': 'Success'};
        return {'data': decoded, 'status': 'Success'};
      }
      final errMsg = (decoded is Map)
          ? (decoded['error'] ?? decoded['message'] ?? 'Server error')
          : 'Unknown server error';
      throw Exception('Backend error ${response.statusCode}: $errMsg');
    } on FormatException {
      throw Exception('Backend returned status ${response.statusCode} with non-JSON body.');
    }
  }

  // ─── 1. Health Check ──────────────────────────────────────────
  Future<Map<String, dynamic>> healthCheck() => _get('/');

  // ─── 2. Crop Analysis (Vision AI) ────────────────────────────
  /// POST /predict   multipart image upload → Groq vision
  Future<Map<String, dynamic>> analyzeCrop(File imageFile) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse('$_base/predict'));
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
      request.fields['lang'] = _currentLang;
      final streamed = await request.send().timeout(const Duration(seconds: 90));
      final response = await http.Response.fromStream(streamed);
      return _handleResponse(response);
    } on SocketException {
      throw Exception('Network error during image upload. Check internet connectivity.');
    } on TimeoutException {
      throw Exception('Crop analysis timed out. Groq AI vision inference took too long, please retry.');
    }
  }

  // ─── 3. Soil Analysis (Vision AI) ────────────────────────────
  /// POST /analyze-soil   multipart image upload → Groq vision
  Future<Map<String, dynamic>> analyzeSoil(File imageFile) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse('$_base/analyze-soil'));
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
      request.fields['lang'] = _currentLang;
      final streamed = await request.send().timeout(const Duration(seconds: 90));
      final response = await http.Response.fromStream(streamed);
      return _handleResponse(response);
    } on SocketException {
      throw Exception('Network error during soil image upload. Check internet connectivity.');
    } on TimeoutException {
      throw Exception('Soil analysis timed out. Please retry with a clearer photo.');
    }
  }

  // ─── 9. Last Scan ─────────────────────────────────────────────

  Future<Map<String, dynamic>> getLastScan() => _get('/last-scan');

  // ─── 10. Weather Advisory ─────────────────────────────────────
  Future<Map<String, dynamic>> getWeather({
    double lat = 22.7196,
    double lon = 75.8577,
  }) =>
      _get('/weather-advisory', params: {
        'lat': lat.toString(),
        'lon': lon.toString(),
        't': DateTime.now().millisecondsSinceEpoch.toString(),
      });

  // ─── 11. Soil Plant Recommendations ───────────────────────────
  Future<Map<String, dynamic>> getSoilPlantRecommendations(Map<String, dynamic> soilData) =>
      _post('/soil-plant-recommendations', soilData);

  // ─── 12. Recovery Advice ──────────────────────────────────────
  Future<Map<String, dynamic>> getRecoveryAdvice(Map<String, dynamic> scanData) =>
      _post('/recovery-advice', scanData, timeout: const Duration(seconds: 60));

  // ─── 13. ROI Calculator ───────────────────────────────────────
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

  // ─── 14. Market Predictions ───────────────────────────────────
  Future<Map<String, dynamic>> getMarketPredictions() =>
      _get('/market-predictions', timeout: const Duration(seconds: 60));

  // ─── 15. AgriBot Chat ─────────────────────────────────────────
  Future<Map<String, dynamic>> agriChat({
    required String message,
    String? language,
    List<Map<String, String>> history = const [],
  }) =>
      _post('/agri-chat', {
        'message': message,
        'language': language ?? _currentLang,
        'history': history,
      }, timeout: const Duration(seconds: 45));

  // ─── 16. Send Alert (Twilio Voice / SMS) ──────────────────────
  Future<Map<String, dynamic>> sendAlert({
    String? phone,
    Map<String, dynamic>? scanData,
    String? message,
    String level = 'INFO',
    String? language,
  }) =>
      _post('/send-alert', {
        if (phone != null) 'phone': phone,
        if (scanData != null) 'scan_data': scanData,
        if (message != null) 'message': message,
        'level': level,
        'language': language ?? _currentLang,
      });

  // ─── 17. Alert History ────────────────────────────────────────
  Future<Map<String, dynamic>> getAlertHistory({int limit = 50}) =>
      _get('/alert-history', params: {'limit': limit.toString()});

  // ─── 18. AI Model Info ────────────────────────────────────────
  Future<Map<String, dynamic>> getAiInfo() => _get('/ai-info');

  // ─── 19. Crop Spray Advisor ───────────────────────────────────
  Future<Map<String, dynamic>> getCropSprayAdvisor({
    required String cropName,
    String growthStage = 'Vegetative',
    String symptoms = '',
    String affectedParts = 'Leaves',
    String severity = 'Moderate',
    String spread = 'Patches',
    String? language,
    String provider = 'gemini',
    File? imageFile,
  }) async {
    final lang = language ?? _currentLang;
    if (imageFile != null && await imageFile.exists()) {
      return _uploadMultipart('/crop-spray-advisor', imageFile, extraFields: {
        'crop_name': cropName,
        'growth_stage': growthStage,
        'symptoms': symptoms,
        'affected_parts': affectedParts,
        'severity': severity,
        'spread': spread,
        'language': lang,
        'provider': provider,
      });
    }

    return _post('/crop-spray-advisor', {
      'crop_name': cropName,
      'growth_stage': growthStage,
      'symptoms': symptoms,
      'affected_parts': affectedParts,
      'severity': severity,
      'spread': spread,
      'language': lang,
      'provider': provider,
    }, timeout: const Duration(seconds: 45));
  }

  // ─── 20. Fertilizer Prescription ──────────────────────────────
  Future<Map<String, dynamic>> getFertilizerPrescription(Map<String, dynamic> data) async {
    final payload = Map<String, dynamic>.from(data);
    if (!payload.containsKey('language')) {
      payload['language'] = _currentLang;
    }
    return _post('/fertilizer-advisor', payload, timeout: const Duration(seconds: 40));
  }

  // ─── 21. Mandi Prices with Filters ────────────────────────────
  Future<Map<String, dynamic>> getMandiPrices({
    String? state,
    String? commodity,
    String? search,
    String? language,
  }) async {
    final params = <String, String>{
      'language': language ?? _currentLang,
      'format': 'map',
      if (state != null && state.isNotEmpty && state != 'all') 'state': state,
      if (commodity != null && commodity.isNotEmpty && commodity != 'all') 'commodity': commodity,
      if (search != null && search.isNotEmpty) 'search': search,
    };
    return _get('/mandi-prices', params: params, timeout: const Duration(seconds: 25));
  }

  // ─── 22. Mandi AI Trend Analysis ──────────────────────────────
  Future<Map<String, dynamic>> getMandiTrend({
    required String cropName,
    required String mandiName,
    String? language,
  }) async {
    return _post('/mandi-trend', {
      'crop_name': cropName,
      'mandi_name': mandiName,
      'language': language ?? _currentLang,
    }, timeout: const Duration(seconds: 35));
  }

  // ─── 23. Government Schemes ───────────────────────────────────
  Future<Map<String, dynamic>> getGovtSchemes({
    String? language,
    String? category,
    String? search,
  }) async {
    final params = <String, String>{
      'language': language ?? _currentLang,
      if (category != null && category.isNotEmpty && category != 'all') 'category': category,
      if (search != null && search.isNotEmpty) 'search': search,
    };
    return _get('/govt-schemes', params: params, timeout: const Duration(seconds: 20));
  }

  // ─── 24. Government Scheme Detail ─────────────────────────────
  Future<Map<String, dynamic>> getGovtSchemeDetail(String schemeId, {String? language}) async {
    return _get('/govt-schemes/$schemeId', params: {
      'language': language ?? _currentLang,
    }, timeout: const Duration(seconds: 20));
  }
}

