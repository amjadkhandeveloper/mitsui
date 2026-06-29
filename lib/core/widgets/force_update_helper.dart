import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/api_constants.dart';
import '../di/injection_container.dart' as di;
import '../services/force_update_service.dart';
import '../theme/app_theme.dart';

class ForceUpdateHelper {
  ForceUpdateHelper._();

  static bool _isChecking = false;
  static bool _dialogVisible = false;

  /// Runs the force-update API in the background and shows a blocking dialog
  /// when the installed version is below the server minimum.
  static Future<void> checkInBackground(BuildContext context) async {
    if (_isChecking || _dialogVisible) {
      return;
    }

    _isChecking = true;
    try {
      final updateRequired =
          await di.sl<ForceUpdateService>().isUpdateRequired();
      if (!updateRequired || !context.mounted || _dialogVisible) {
        return;
      }

      _dialogVisible = true;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return PopScope(
            canPop: false,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Row(
                children: [
                  Icon(Icons.system_update, color: AppTheme.mitsuiDarkBlue),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Update Required',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
              content: const Text(
                'A new version of ${ApiConstants.appName} is available. '
                'Please update the app to continue using it.',
              ),
              actions: [
                FilledButton(
                  onPressed: () => _openStore(),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.mitsuiDarkBlue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Update Now'),
                ),
              ],
            ),
          );
        },
      );
    } catch (_) {
      // Do not interrupt dashboard behaviour on failure.
    } finally {
      _isChecking = false;
      _dialogVisible = false;
    }
  }

  static Future<void> _openStore() async {
    final uri = Uri.parse(_storeUrl);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // Keep dialog open if the store cannot be opened.
    }
  }

  static String get _storeUrl {
    if (Platform.isIOS) {
      return ApiConstants.iosAppStoreUrl;
    }
    return ApiConstants.androidPlayStoreUrl;
  }
}
