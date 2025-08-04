import 'package:flutter/material.dart';

import 'constants/app_colors.dart';
import 'home_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JSON to Class Converter',
      theme: ThemeData(
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
        ),
        scaffoldBackgroundColor: AppColors.scaffoldBackground,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.cardBackground,
          elevation: 0.5,
          centerTitle: true,
          iconTheme: IconThemeData(color: AppColors.icon),
          titleTextStyle: TextStyle(
            color: AppColors.titleText,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            fontFamily: 'Inter',
          ),
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(fontWeight: FontWeight.w700),
          titleLarge: TextStyle(fontWeight: FontWeight.w600),
          titleMedium: TextStyle(fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(color: AppColors.bodyText),
          bodyMedium: TextStyle(color: AppColors.subtitleText),
        ),
        inputDecorationTheme: InputDecorationTheme(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.focusBorder, width: 2),
          ),
          filled: true,
          fillColor: AppColors.cardBackground,
          labelStyle: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w500),
          floatingLabelStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
        ),
        cardTheme: CardThemeData(
          color: AppColors.cardBackground,
          elevation: 1,
          shadowColor: AppColors.primary.withOpacity(0.1),
          surfaceTintColor: AppColors.cardBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 1,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.divider,
          thickness: 1,
          space: 24,
        ),
      ),
      home: const MyHomePage(title: 'JSON to Class Converter'),
      debugShowCheckedModeBanner: false,
    );
  }
}
