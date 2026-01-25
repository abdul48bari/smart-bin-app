import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'navigation/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const SmartBinApp());
}

class SmartBinApp extends StatelessWidget {
  const SmartBinApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTextTheme = ThemeData.light().textTheme.apply(
          fontFamily: 'Inter',
          bodyColor: Colors.black,
          displayColor: Colors.black,
        );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Bin',
      theme: ThemeData(
        useMaterial3: true,

        // ✅ FONT
        fontFamily: 'Inter',

        // ✅ FORCE BLACK COLOR SCHEME
        colorScheme: const ColorScheme.light(
          primary: Colors.black,
          onPrimary: Colors.black,
          surface: Colors.white,
          onSurface: Colors.black,
          background: Color(0xFFF6F8F7),
          onBackground: Colors.black,
        ),

        scaffoldBackgroundColor: const Color(0xFFF6F8F7),

        // ✅ TEXT THEME (ACTUALLY USED BY MATERIAL 3)
        textTheme: baseTextTheme.copyWith(
          titleLarge: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Colors.black,
            letterSpacing: -0.3,
          ),
          titleMedium: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
          titleSmall: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
          bodyLarge: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          bodyMedium: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),

        // ✅ APPBAR – THIS IS THE KEY FIX
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(color: Colors.black),

          // Material 3 uses THIS, not titleTextStyle
          toolbarTextStyle: TextStyle(
            fontFamily: 'Inter',
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),

          titleTextStyle: TextStyle(
            fontFamily: 'Inter',
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
      ),
      home: const MainNavigation(),
    );
  }
}
