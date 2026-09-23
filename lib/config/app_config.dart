class AppConfig {
  /// Base API URL dynamically populated at build/runtime via `--dart-define=BASE_URL=...`
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    // defaultValue: 'https://iespoc.soukhyatech.com/api',
    defaultValue: 'http://192.168.1.42:8080',
  );

  /// WebSocket URL dynamically populated at build/runtime via `--dart-define=WEBSOCKET_URL=...`
  static const String webSocketBaseUrl = String.fromEnvironment(
    'WEBSOCKET_URL',
    // defaultValue: 'wss://iespoc.soukhyatech.com/be-service/ws/sensors?token=',
    defaultValue: 'ws://192.168.1.42:8080/be-service/ws/sensors?token=',
  );

  /// Connection timeout in milliseconds
  static const int connectionTimeoutMs = int.fromEnvironment(
    'CONNECTION_TIMEOUT',
    defaultValue: 15000,
  );
  /// Dashboard auto-refresh interval in seconds
  static const int dashboardRefreshIntervalSeconds = int.fromEnvironment(
    'DASHBOARD_REFRESH_INTERVAL',
    defaultValue: 20,
  );
}
