import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Centralized iOS-safe location permission flow.
///
/// Rules enforced:
/// - Never auto-open Settings after denial.
/// - Pre-permission explanation shown once before first request.
/// - Only user-initiated "Open Settings" triggers settings navigation.
class LocationPermissionFlow {
  static const _prefKeyShownPrePrompt = 'shown_location_pre_permission_prompt';

  static const String requiredTitle = 'Location Permission Required';
  static const String requiredMessage =
      'Location access is required to verify your attendance at your assigned work location.';

  static const String prePromptMessage =
      'This app uses your location only to verify attendance at your assigned work location.';

  /// Call this only from a user action (tap) that needs location.
  ///
  /// Returns `true` if we have permission to access location, otherwise `false`.
  static Future<bool> ensureForAttendanceFeature(BuildContext context) async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      final open = await _showRequiredDialog(context);
      if (open) {
        await Geolocator.openLocationSettings();
      }
      return false;
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      final prefs = await SharedPreferences.getInstance();
      final shown = prefs.getBool(_prefKeyShownPrePrompt) ?? false;

      if (!shown) {
        final proceed = await _showPrePermissionDialog(context);
        await prefs.setBool(_prefKeyShownPrePrompt, true);
        if (!proceed) return false;
      }

      permission = await Geolocator.requestPermission();
    }

    final granted = permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;

    if (granted) return true;

    // Denied or deniedForever: do not auto-redirect. Offer explicit dialog.
    final open = await _showRequiredDialog(context);
    if (open) {
      await Geolocator.openAppSettings();
    }
    return false;
  }

  /// Returns the current position if permission is granted, else null.
  ///
  /// Must only be called after [ensureForAttendanceFeature] returns true.
  static Future<Position?> getCurrentPositionSafe() async {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<bool> _showPrePermissionDialog(BuildContext context) async {
    final res = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: const Text(requiredTitle),
          content: const Text(prePromptMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
    return res ?? false;
  }

  static Future<bool> _showRequiredDialog(BuildContext context) async {
    final res = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: const Text(requiredTitle),
          content: const Text(requiredMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
    return res ?? false;
  }
}

