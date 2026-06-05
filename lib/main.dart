import 'package:flutter/material.dart';

import 'login.dart';
import 'signup.dart';
import 'forgot_password.dart';
import 'home.dart';
import 'wishlist.dart';
import 'orders.dart';
import 'profile.dart';

void main() {
  runApp(const MindCareApp());
}

class MindCareApp extends StatelessWidget {
  const MindCareApp({super.key});

  static const Color primaryColor = Color(0xFF5E8C75);
  static const Color accentColor = Color(0xFFE8B86D);
  static const Color backgroundColor = Color(0xFFF7F4EF);
  static const Color textColor = Color(0xFF26332D);
  static const Color borderColor = Color(0xFFDAD7D0);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MindCare Wellness Marketplace',
      initialRoute: '/login',

      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: backgroundColor,

        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
          secondary: accentColor,
          surface: Colors.white,
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),

        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          margin: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 6,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: borderColor,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: primaryColor,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Colors.red,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 2,
            ),
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primaryColor,
            side: const BorderSide(
              color: primaryColor,
            ),
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: primaryColor,
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),

        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
          titleLarge: TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
          titleMedium: TextStyle(
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
          bodyLarge: TextStyle(
            color: textColor,
          ),
          bodyMedium: TextStyle(
            color: textColor,
          ),
          bodySmall: TextStyle(
            color: textColor,
          ),
        ),

        snackBarTheme: SnackBarThemeData(
          backgroundColor: textColor,
          contentTextStyle: const TextStyle(
            color: Colors.white,
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),

        dividerTheme: const DividerThemeData(
          color: borderColor,
          thickness: 1,
        ),
      ),

      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/forgot_password': (context) => const ForgotPasswordScreen(),

        '/home': (context) => const HomeScreen(),
        '/dashboard': (context) => const HomeScreen(),

        '/wishlist': (context) => const WishlistScreen(),
        '/orders': (context) => const OrdersScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}