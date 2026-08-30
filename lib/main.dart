import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'firebase_options.dart';
import 'models/index.dart';
import 'screens/improved_home_screen.dart';
import 'screens/whats_new_screen.dart';
import 'services/notification_service.dart';
import 'utils/hive_storage.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Hive
  await Hive.initFlutter();

  // Register every @HiveType adapter used by typed boxes below. Opening a
  // typed Box<T> or writing a T without its adapter registered first
  // throws a HiveError at runtime — this used to crash (or silently drop
  // writes inside a try/catch) the first time login streak, gacha,
  // puzzle, quiz, or diagnosis data was touched.
  Hive.registerAdapter(UserProfileAdapter());
  Hive.registerAdapter(ChatHistoryAdapter());
  Hive.registerAdapter(GachaRecordAdapter());
  Hive.registerAdapter(LoginStreakAdapter());
  Hive.registerAdapter(PersonalityDiagnosisResultAdapter());
  Hive.registerAdapter(QuizNotificationRecordAdapter());
  Hive.registerAdapter(PersonRelationPuzzleRecordAdapter());

  await Hive.openBox<String>(ChatHistoryStorage.boxName);
  await Hive.openBox<String>(AppMetaStorage.boxName);
  await Hive.openBox<GachaRecord>('gacha_records');
  await Hive.openBox<LoginStreak>('login_streaks');
  await Hive.openBox<PersonRelationPuzzleRecord>('puzzle_records');
  await Hive.openBox<QuizNotificationRecord>('quiz_records');
  await Hive.openBox<PersonalityDiagnosisResult>('diagnosis_results');

  // Initialize notifications (C2)
  await NotificationService().initialize();

  // NOTE: seed data (persons/events) is uploaded to Firestore via the
  // admin-only `scripts/upload_gacha_persons.js` script (a service-account
  // key, never shipped in the app). This app used to also bulk-write
  // 300+ person/event docs directly from the client on first launch —
  // that logic was removed: Firestore's security rules correctly require
  // `admin` custom claims to write `persons`/`events`, which this
  // unauthenticated client never has, so the writes always failed
  // (silently, one per document) anyway. Shipping bulk-write-to
  // admin-collections logic in a public client binary is a needless
  // attack-surface/cost risk even when it's currently rejected by rules.

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'たくさん知りたくなる歴史図鑑',
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      home: const ImprovedHomeScreen(),
    );
  }

  static ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6A1B9A),
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Color(0xFF6A1B9A),
        foregroundColor: Colors.white,
        centerTitle: false,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF6A1B9A),
        foregroundColor: Colors.white,
      ),
    );
  }

  static ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6A1B9A),
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Color(0xFF37474F),
        foregroundColor: Colors.white,
        centerTitle: false,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: const Color(0xFF424242),
      ),
      scaffoldBackgroundColor: const Color(0xFF303030),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF6A1B9A),
        foregroundColor: Colors.white,
      ),
    );
  }
}
