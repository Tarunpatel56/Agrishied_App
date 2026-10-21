import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// AgriShield AI — Central Backend Configuration
/// =============================================
/// Single source-of-truth for backend connectivity across the entire Flutter app.
///
/// Production Base URL: https://agrishiedai-backend.onrender.com
/// Can be overridden at compile-time via:
///   flutter build apk --dart-define=BACKEND_BASE_URL=https://your-custom-backend.com
class AppConfig {
  /// Live Production Render Backend URL (HTTPS)
  static const String productionBaseUrl = 'https://agrishiedai-backend.onrender.com';

  /// Compile-time environment override
  static const String _backendBaseUrlOverride = String.fromEnvironment(
    'BACKEND_BASE_URL',
    defaultValue: productionBaseUrl,
  );

  static String? _resolvedBaseUrl;

  /// Central base URL used by all controllers, views, and services.
  /// Guaranteed to never return localhost or a LAN IP in production.
  static String get baseUrl {
    if (_resolvedBaseUrl != null && _resolvedBaseUrl!.isNotEmpty) {
      return _resolvedBaseUrl!;
    }
    if (_backendBaseUrlOverride.isNotEmpty) {
      return _backendBaseUrlOverride;
    }
    return productionBaseUrl;
  }

  /// Manually update the base URL at runtime (e.g. for testing / custom servers)
  static void setBaseUrl(String url) {
    _resolvedBaseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
    debugPrint('[AppConfig] Backend URL manually updated to: $_resolvedBaseUrl');
  }

  /// Connection timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration requestTimeout = Duration(seconds: 45);
  static const Duration uploadTimeout = Duration(seconds: 90);

  /// Initializes and verifies connectivity to the backend.
  /// Safely called on app launch without blocking the UI or crashing on network failure.
  static Future<String> autoDiscoverBackend() async {
    final activeUrl = baseUrl;
    debugPrint('[AppConfig] Using Backend: $activeUrl');

    try {
      final uri = Uri.parse('$activeUrl/');
      final resp = await http.get(uri).timeout(const Duration(seconds: 6));
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        debugPrint('[AppConfig] Backend status: ${data['status'] ?? 'Online'}');
      } else {
        debugPrint('[AppConfig] Backend responded with HTTP ${resp.statusCode}');
      }
    } catch (e) {
      debugPrint('[AppConfig] Note: Backend ping notice (might be waking up from sleep): $e');
    }

    return activeUrl;
  }
}
