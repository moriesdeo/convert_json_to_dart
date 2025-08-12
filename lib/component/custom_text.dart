import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// A reusable text component with predefined styles
/// This can be used throughout the application to maintain consistent text styling
class CustomText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final bool isTitle;
  final bool isSubtitle;
  final bool isBold;

  const CustomText({
    super.key,
    required this.text,
    this.style,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.isTitle = false,
    this.isSubtitle = false,
    this.isBold = false,
  });

  /// Factory constructor for title text
  factory CustomText.title(
    String text, {
    Key? key,
    TextStyle? style,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
    double fontSize = 18.0,
    FontWeight fontWeight = FontWeight.bold,
    Color color = AppColors.titleText,
  }) {
    return CustomText(
      key: key,
      text: text,
      style: style,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      isTitle: true,
    );
  }

  /// Factory constructor for subtitle text
  factory CustomText.subtitle(
    String text, {
    Key? key,
    TextStyle? style,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
    double fontSize = 14.0,
    FontWeight fontWeight = FontWeight.w500,
    Color color = AppColors.subtitleText,
  }) {
    return CustomText(
      key: key,
      text: text,
      style: style,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      isSubtitle: true,
    );
  }

  /// Factory constructor for body text
  factory CustomText.body(
    String text, {
    Key? key,
    TextStyle? style,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
    double fontSize = 15.0,
    FontWeight fontWeight = FontWeight.normal,
    Color color = AppColors.bodyText,
  }) {
    return CustomText(
      key: key,
      text: text,
      style: style,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  /// Factory constructor for label text
  factory CustomText.label(
    String text, {
    Key? key,
    TextStyle? style,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
    double fontSize = 13.0,
    FontWeight fontWeight = FontWeight.w500,
    Color color = AppColors.labelText,
  }) {
    return CustomText(
      key: key,
      text: text,
      style: style,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  /// Factory constructor for bold text
  factory CustomText.bold(
    String text, {
    Key? key,
    TextStyle? style,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
    double fontSize = 15.0,
    Color color = AppColors.bodyText,
  }) {
    return CustomText(
      key: key,
      text: text,
      style: style,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      color: color,
      isBold: true,
    );
  }

  /// Factory constructor for keyword text (for syntax highlighting)
  factory CustomText.keyword(
    String text, {
    Key? key,
    TextStyle? style,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
    double fontSize = 15.0,
    FontWeight fontWeight = FontWeight.bold,
  }) {
    return CustomText(
      key: key,
      text: text,
      style: style,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: AppColors.syntaxKeyword,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine the text style based on the provided properties
    TextStyle effectiveStyle = style ?? TextStyle();

    // Apply properties if they are provided
    if (fontSize != null) {
      effectiveStyle = effectiveStyle.copyWith(fontSize: fontSize);
    }

    if (fontWeight != null) {
      effectiveStyle = effectiveStyle.copyWith(fontWeight: fontWeight);
    }

    if (color != null) {
      effectiveStyle = effectiveStyle.copyWith(color: color);
    }

    // Apply specific styles based on the type of text
    if (isTitle) {
      effectiveStyle = effectiveStyle.copyWith(
        fontSize: effectiveStyle.fontSize ?? 18.0,
        fontWeight: effectiveStyle.fontWeight ?? FontWeight.bold,
        color: effectiveStyle.color ?? AppColors.titleText,
      );
    } else if (isSubtitle) {
      effectiveStyle = effectiveStyle.copyWith(
        fontSize: effectiveStyle.fontSize ?? 14.0,
        fontWeight: effectiveStyle.fontWeight ?? FontWeight.w500,
        color: effectiveStyle.color ?? AppColors.subtitleText,
      );
    } else if (isBold) {
      effectiveStyle = effectiveStyle.copyWith(
        fontWeight: FontWeight.bold,
      );
    }

    return Text(
      text,
      style: effectiveStyle,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
    );
  }
}
