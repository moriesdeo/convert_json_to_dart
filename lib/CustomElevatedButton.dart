import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String? text;
  final Color? backgroundColor;
  final Color? textColor;
  final Widget? child; // Tambahan child

  const CustomElevatedButton({
    super.key,
    required this.onPressed,
    this.text,
    this.backgroundColor,
    this.textColor,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? const Color(0xFF6366F1);
    final fgColor = textColor ?? Colors.white;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: bgColor.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
          gradient: LinearGradient(
            colors: [
              bgColor,
              Color.fromARGB(
                bgColor.alpha,
                (bgColor.red - 10).clamp(0, 255),
                (bgColor.green - 10).clamp(0, 255),
                (bgColor.blue + 15).clamp(0, 255),
              ),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onPressed,
            splashColor: Colors.white.withOpacity(0.1),
            highlightColor: Colors.white.withOpacity(0.05),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: child ??
                  Text(
                    text ?? '',
                    style: TextStyle(
                      color: fgColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      letterSpacing: 0.4,
                    ),
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
