class AppConfig {
  AppConfig._();

  static const String appName = 'TrackGov AI';
  static const String appVersion = '1.0.0';
  
  // API Configuration
  // Until backend is live, we will use mock services, but here is the base URL structure
  static const String apiBaseUrl = 'http://localhost:8000/api/v1';
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds

  // Feature Flags
  static const bool useMockData = false; // Set to true to use mock services
}
