import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class JsonFormatter {
  /// Converts a JSON string into a colored TextSpan with syntax highlighting
  static TextSpan buildColoredJson(String json) {
    final List<TextSpan> spans = [];
    final regExp = RegExp(
        r'(".*?":)|(:)|(\d+)|(".*?")|(\[)|(\])|(\{)|(\})|(\btrue\b|\bfalse\b)');

    int lastMatchEnd = 0;

    for (var match in regExp.allMatches(json)) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(text: json.substring(lastMatchEnd, match.start)));
      }

      final matchText = match.group(0)!;

      if (matchText == '{' || matchText == '}') {
        spans.add(TextSpan(
            text: matchText,
            style: const TextStyle(
                color: AppColors.syntaxKeyword, fontWeight: FontWeight.w600)));
      } else if (matchText == '[' || matchText == ']') {
        spans.add(TextSpan(
            text: matchText,
            style: const TextStyle(
                color: AppColors.primary, fontWeight: FontWeight.w600)));
      } else if (matchText.endsWith('":')) {
        spans.add(TextSpan(
            text: matchText,
            style: const TextStyle(
                color: AppColors.syntaxType, fontWeight: FontWeight.w600)));
      } else if (matchText.startsWith('"') && matchText.endsWith('"')) {
        spans.add(TextSpan(
            text: matchText,
            style: const TextStyle(
                color: AppColors.secondary, fontWeight: FontWeight.w600)));
      } else if (RegExp(r'^\d+$').hasMatch(matchText)) {
        spans.add(TextSpan(
            text: matchText,
            style: const TextStyle(
                color: AppColors.syntaxDefault, fontWeight: FontWeight.w600)));
      } else if (matchText == 'true' || matchText == 'false') {
        spans.add(TextSpan(
            text: matchText,
            style: const TextStyle(
                color: AppColors.primary, fontWeight: FontWeight.w600)));
      } else {
        spans.add(TextSpan(
            text: matchText,
            style: const TextStyle(color: AppColors.bodyText)));
      }

      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < json.length) {
      spans.add(TextSpan(text: json.substring(lastMatchEnd)));
    }

    return TextSpan(children: spans);
  }
}
