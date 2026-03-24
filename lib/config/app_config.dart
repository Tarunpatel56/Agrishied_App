/// AgriShield AI - Central Backend Configuration
///
/// Preferred flow for local development:
/// flutter run --dart-define=BACKEND_HOST=10.33.215.46
///
/// If no dart-define is supplied, the verified Wi-Fi IP below is used.
class AppConfig {
  static const String _defaultBackendHost = '10.33.215.46';
  static const int _defaultBackendPort = 5000;

  static const String _backendBaseUrlOverride =
      String.fromEnvironment('BACKEND_BASE_URL');
  static const String _backendHost =
      String.fromEnvironment('BACKEND_HOST', defaultValue: _defaultBackendHost);
  static const int _backendPort =
      int.fromEnvironment('BACKEND_PORT', defaultValue: _defaultBackendPort);

  /// Full backend base URL used by all API controllers.
  static String get baseUrl {
    if (_backendBaseUrlOverride.isNotEmpty) {
      return _backendBaseUrlOverride;
    }
    return 'http://$_backendHost:$_backendPort';
  }
}
