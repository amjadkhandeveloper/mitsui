import 'package:flutter/material.dart';

class Toast {
  static void show(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: textColor ?? Colors.white, size: 20),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: textColor ?? Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor ?? Colors.red.shade700,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 6,
      ),
    );
  }

  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    show(
      context,
      message,
      duration: duration,
      backgroundColor: Colors.green.shade700,
      icon: Icons.check_circle,
    );
  }

  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message,
      duration: duration,
      backgroundColor: Colors.red.shade700,
      icon: Icons.error_outline,
    );
  }

  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    show(
      context,
      message,
      duration: duration,
      backgroundColor: Colors.blue.shade700,
      icon: Icons.info_outline,
    );
  }

  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    show(
      context,
      message,
      duration: duration,
      backgroundColor: Colors.orange.shade700,
      icon: Icons.warning_amber_rounded,
    );
  }

  /// Helper to show different toast severity based on numeric status code.
  /// - 2xx (<=200): success (green)
  /// - >200 and <400: warning (orange)
  /// - >=400 or null: error (red)
  static void showForStatusCode(
    BuildContext context, {
    required int? statusCode,
    required String message,
  }) {
    if (statusCode != null && statusCode <= 200) {
      showSuccess(context, message);
    } else if (statusCode != null && statusCode > 200 && statusCode < 400) {
      showWarning(context, message);
    } else {
      showError(context, message);
    }
  }
}
