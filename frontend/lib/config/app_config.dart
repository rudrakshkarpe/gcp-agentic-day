class AppConfig {
  // Backend Configuration
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );
  
  static const String prodUrl = 'https://kisan-backend-xyz-uc.a.run.app';
  
  // Get the appropriate API URL based on environment
  static String get apiBaseUrl {
    return const bool.fromEnvironment('dart.vm.product') 
        ? prodUrl 
        : baseUrl;
  }
  
  // API Endpoints
  static String get healthUrl => '$apiBaseUrl/health';
  static String get textChatUrl => '$apiBaseUrl/api/chat/text';
  static String get voiceChatUrl => '$apiBaseUrl/api/chat/voice';
  static String get imageChatUrl => '$apiBaseUrl/api/chat/image';
  static String get historyUrl => '$apiBaseUrl/api/chat/history';
  static String get marketPricesUrl => '$apiBaseUrl/api/market/prices';
  static String get schemesUrl => '$apiBaseUrl/api/schemes/search';
  static String get userContextUrl => '$apiBaseUrl/api/user/context';
  
  // Firebase Configuration
  static const String firebaseProjectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: 'your-project-id',
  );
  
  // Audio Configuration
  static const int maxRecordingDuration = 60; // seconds
  static const String audioFormat = 'wav';
  static const int sampleRate = 16000;
  
  // App Configuration
  static const String appName = 'ಕೃಷಿ ಮಿತ್ರ';
  static const String appNameEnglish = 'Kisan AI';
  static const String appVersion = '1.0.0';
  
  // Supported Languages
  static const List<String> supportedLanguages = ['kn', 'en'];
  static const String defaultLanguage = 'kn';
  
  // Chat Configuration
  static const int maxMessageLength = 500;
  static const int maxHistoryItems = 50;
  static const Duration typingDelay = Duration(milliseconds: 1000);
  
  // Image Configuration
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> supportedImageFormats = ['jpg', 'jpeg', 'png'];
  
  // Networking
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 60);
  static const int maxRetries = 3;
  
  // Cache Configuration
  static const Duration cacheExpiry = Duration(hours: 24);
  static const String cacheKey = 'kisan_app_cache';
  
  // User Defaults
  static const Map<String, dynamic> defaultUserContext = {
    'location': 'Karnataka',
    'language': 'kn',
    'farming_type': 'mixed',
    'land_size': 'small',
  };
}
