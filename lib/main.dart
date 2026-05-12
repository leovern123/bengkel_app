import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/storage/token_storage.dart';
import 'features/auth/login_page.dart';
import 'features/dashboard/dashboard_page.dart';
import 'core/utils/notification_service.dart';

// Global theme notifier
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();

  // Load saved theme
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('isDarkMode') ?? true;
  themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;

  // Add listener to save theme preference
  themeNotifier.addListener(() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', themeNotifier.value == ThemeMode.dark);
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'Bengkel App',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,
          // MODE TERANG
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: const Color(0xFFFF8C00),
            scaffoldBackgroundColor: const Color(0xFFF8F9FA),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              elevation: 0,
            ),
            textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFFF8C00),
              primary: const Color(0xFFFF8C00),
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),
          // MODE GELAP
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: const Color(0xFFFF8C00),
            scaffoldBackgroundColor: const Color(0xFF0F0F0F),
            textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFFF8C00),
              surface: Color(0xFF1A1A1A),
            ),
            useMaterial3: true,
          ),
          home: FutureBuilder<String?>(
            future: TokenStorage.getToken(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(color: Color(0xFFFF8C00)),
                  ),
                );
              }
              if (snapshot.hasData && snapshot.data != null) {
                return const DashboardPage();
              }
              return const LoginPage();
            },
          ),
        );
      },
    );
  }
}