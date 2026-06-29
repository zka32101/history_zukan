class AppConstants {
  // App Info
  static const String appName = '歴史図鑑';
  static const String appVersion = '1.0.0';

  // Pricing
  static const double mvpPrice = 300; // ¥300 (JPY)
  static const double addonAiChatPrice = 120; // ¥120 (JPY)

  // Timeouts
  static const Duration firestoreTimeout = Duration(seconds: 30);
  static const Duration networkTimeout = Duration(seconds: 10);

  // Pagination
  static const int defaultPageSize = 50;
  static const int maxQueryResults = 500;

  // A1: World Synchronous Panorama
  static const int defaultYearWindow = 365; // Days

  // B1: My Timeline
  static const int minBirthYear = 1900;
  static const int maxBirthYear = 2024;

  // B3: Nearby History
  static const double defaultSearchRadius = 5.0; // Kilometers
  static const double maxSearchRadius = 10.0;

  // C1: Progress Tracking
  static const int totalCardsTarget = 200;
  static const List<String> medalTypes = [
    'complete_era',
    'find_100_cards',
    'find_all_themes',
    'world_explorer',
    'time_traveler',
  ];

  // C2: Daily Notifications
  static const int notificationId = 1;

  // C3: Bedtime Mode
  static const double defaultTtsSpeed = 0.8;
  static const int bedtimeAutoStopMinutes = 10;

  // Data Validation
  static const int minEventYear = -10000;
  static const int maxEventYear = 2050;
}
