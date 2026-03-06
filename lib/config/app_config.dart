/// AgriShield AI — Central Backend Configuration
///
/// ⚡ SIRF YAHAN IP BADLO — baaki sab automatically update ho jayega
/// Apne computer ka WiFi IP yahan daalo (cmd > ipconfig > IPv4 Address)
///
/// Example: 'http://192.168.1.5:5000'
class AppConfig {
  // ✅ Apne computer ka current WiFi IP yahan daalo
  static const String _backendHost = '172.31.22.46';
  static const int _backendPort = 5000;

  /// Full backend base URL
  static String get baseUrl => 'http://$_backendHost:$_backendPort';
}
