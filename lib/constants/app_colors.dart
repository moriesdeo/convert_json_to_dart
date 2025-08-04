import 'package:flutter/material.dart';

/// App color constants to be used throughout the application
/// This centralizes all color definitions to avoid repetition
class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF6366F1);
  static const Color secondary = Color(0xFFEC4899);

  // Background colors
  static const Color scaffoldBackground = Color(0xFFF8FAFC);
  static const Color cardBackground = Colors.white;
  static const Color inputBackground = Color(0xFFF1F5F9);

  // Text colors
  static const Color titleText = Color(0xFF1E293B);
  static const Color bodyText = Color(0xFF334155);
  static const Color subtitleText = Color(0xFF475569);

  // Border and divider colors
  static const Color divider = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFE2E8F0);

  // Gradient colors
  static const List<Color> primaryGradient = [Color(0xFF6366F1), Color(0xFF8B5CF6)];

  // Icon colors
  static const Color icon = Color(0xFF334155);

  // Other UI element colors
  static const Color focusBorder = primary;
  static const Color labelText = Color(0xFF64748B);

  // Syntax highlighting colors
  static const Color syntaxType = Color(0xFFD946EF);
  static const Color syntaxParameter = bodyText;
  static const Color syntaxKeyword = Color(0xFF0EA5E9);
  static const Color syntaxDefault = Color(0xFFF97316);
}
