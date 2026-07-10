import 'package:flutter/material.dart';

import '../navigation/app_navigator.dart';
import 'toast.dart';

class NetworkFeedback {
  NetworkFeedback._();

  static const String noInternetMessage =
      'No internet connection. Please check your network.';

  static DateTime? _lastShownAt;

  /// Shows a debounced no-internet toast when connectivity is unavailable.
  static void showNoInternet() {
    final now = DateTime.now();
    if (_lastShownAt != null &&
        now.difference(_lastShownAt!) < const Duration(seconds: 3)) {
      return;
    }
    _lastShownAt = now;

    final context = rootNavigatorKey.currentContext;
    if (context == null || !context.mounted) return;

    Toast.show(
      context,
      noInternetMessage,
      backgroundColor: Colors.red.shade700,
      icon: Icons.wifi_off_rounded,
    );
  }
}
