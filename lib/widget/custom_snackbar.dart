import 'package:flutter/material.dart';

/// A premium, reusable SnackBar styling helper that presents status alerts.
class CustomSnackBar {
  /// Shows a beautiful success SnackBar.
  static void showSuccess({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context: context,
      message: message,
      backgroundColor: const Color(0xFFE8F5E9),
      textColor: const Color(0xFF0D631B),
      icon: const Icon(
        Icons.check_circle_rounded,
        color: Color(0xFF0D631B),
        size: 24,
      ),
      duration: duration,
    );
  }

  /// Shows a beautiful error SnackBar.
  static void showError({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context: context,
      message: message,
      backgroundColor: const Color(0xFFFFEBEE),
      textColor: const Color(0xFFD32F2F),
      icon: const Icon(
        Icons.error_rounded,
        color: Color(0xFFD32F2F),
        size: 24,
      ),
      duration: duration,
    );
  }

  /// Shows a beautiful warning SnackBar.
  static void showWarning({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context: context,
      message: message,
      backgroundColor: const Color(0xFFFFF8E1),
      textColor: const Color(0xFFF57F17),
      icon: const Icon(
        Icons.warning_amber_rounded,
        color: Color(0xFFF57F17),
        size: 24,
      ),
      duration: duration,
    );
  }

  /// Shows a beautiful info SnackBar.
  static void showInfo({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context: context,
      message: message,
      backgroundColor: const Color(0xFFE3F2FD),
      textColor: const Color(0xFF0D47A1),
      icon: const Icon(
        Icons.info_outline_rounded,
        color: Color(0xFF0D47A1),
        size: 24,
      ),
      duration: duration,
    );
  }

  /// Internal base function to present custom floating SnackBars.
  static void _show({
    required BuildContext context,
    required String message,
    required Color backgroundColor,
    required Color textColor,
    required Widget icon,
    required Duration duration,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: duration,
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: textColor.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              icon,
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
