import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// AgriShield AI - Central Backend Configuration
///
/// Automatically discovers the active working backend endpoint:
/// 1. http://127.0.0.1:5000 (via `adb reverse tcp:5000 tcp:5000` on USB device / desktop / web)
/// 2. http://10.186.46.46:5000 (Current active Wi-Fi LAN IP)
/// 3. http://10.0.2.2:5000 (Android Emulator)
class AppConfig {
  /// Current active Wi-Fi IP of this development machine
  static const String currentWifiIp = '10.186.46.46';
  static const int defaultBackendPort = 5000;

  static const String _backendBaseUrlOverride = String.fromEnvironment(
    'BACKEND_BASE_URL',
  );
  static const String _backendHost = String.fromEnvironment(
    'BACKEND_HOST',
    defaultValue: currentWifiIp,
  );
  static const int _backendPort = int.fromEnvironment(
    'BACKEND_PORT',
    defaultValue: defaultBackendPort,
  );

  static String? _resolvedBaseUrl;

  /// Full backend base URL used by all API controllers.
  static String get baseUrl {
    if (_backendBaseUrlOverride.isNotEmpty) {
      return _backendBaseUrlOverride;
    }
    if (_resolvedBaseUrl != null && _resolvedBaseUrl!.isNotEmpty) {
      return _resolvedBaseUrl!;
    }
    return 'http://$_backendHost:$_backendPort';
  }

  /// Manually override or update the base URL
  static void setBaseUrl(String url) {
    _resolvedBaseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
    debugPrint('[AppConfig] Base URL manually updated to: $_resolvedBaseUrl');
  }

  /// Automatically probe candidates and lock onto the responsive backend URL
  static Future<String> autoDiscoverBackend() async {
    if (_backendBaseUrlOverride.isNotEmpty) {
      _resolvedBaseUrl = _backendBaseUrlOverride;
      return _resolvedBaseUrl!;
    }
    if (_backendHost.isNotEmpty) {
      _resolvedBaseUrl = 'http://$_backendHost:$_backendPort';
      return _resolvedBaseUrl!;
    }

    final candidates = [
      'http://127.0.0.1:$defaultBackendPort',     // USB with adb reverse / Desktop
      'http://$currentWifiIp:$defaultBackendPort', // Direct Wi-Fi LAN
      'http://10.0.2.2:$defaultBackendPort',       // Android emulator loopback
    ];

    debugPrint('[AppConfig] Checking backend connection...');
    for (final candidate in candidates) {
      try {
        final uri = Uri.parse('$candidate/');
        final resp = await http.get(uri).timeout(const Duration(milliseconds: 1200));
        if (resp.statusCode == 200) {
          final data = json.decode(resp.body);
          if (data is Map && data.containsKey('status')) {
            _resolvedBaseUrl = candidate;
            debugPrint('[AppConfig] Connected successfully to backend: $candidate');
            return candidate;
          }
        }
      } catch (_) {
        // Candidate not responding, try next
      }
    }

    // Default fallback
    _resolvedBaseUrl = 'http://127.0.0.1:$defaultBackendPort';
    debugPrint('[AppConfig] Backend probe complete, using: $_resolvedBaseUrl');
    return _resolvedBaseUrl!;
  }
}
