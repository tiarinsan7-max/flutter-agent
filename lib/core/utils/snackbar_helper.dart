import 'package:flutter/material.dart';

class SnackBarHelper {
  /// Show success message
  static void showSuccess(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      Colors.green,
      Icons.check_circle,
    );
  }

  /// Show error message
  static void showError(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      Colors.red,
      Icons.error,
    );
  }

  /// Show info message
  static void showInfo(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      Colors.blue,
      Icons.info,
    );
  }

  /// Show warning message
  static void showWarning(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      Colors.orange,
      Icons.warning,
    );
  }

  /// Internal method to show snackbar
  static void _showSnackBar(
    BuildContext context,
    String message,
    Color backgroundColor,
    IconData icon,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
