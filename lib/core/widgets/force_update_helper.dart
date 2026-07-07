import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/api_constants.dart';
import '../di/injection_container.dart' as di;
import '../theme/app_theme.dart';
import '../routes/app_routes.dart';
import '../services/fcm_token_service.dart';
import '../../features/login/domain/repositories/auth_repository.dart';
import '../../features/splash/data/datasources/local_storage_data_source.dart';

/// UI helpers for force-update and force-logout flows.
class ForceUpdateHelper {
  ForceUpdateHelper._();

  static bool _dialogVisible = false;

  static Future<void> showForceUpdateDialog(BuildContext context) async {
    if (_dialogVisible || !context.mounted) return;
    _dialogVisible = true;
    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        useRootNavigator: true,
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
    } finally {
      _dialogVisible = false;
    }
  }

  static Future<void> forceLogoutFromPolicy(BuildContext context) async {
    try {
      final apiSuccess = await di.sl<FcmTokenService>().logoutFromServer();
      if (!apiSuccess) {
        debugPrint(
          'ForceUpdate: FCM logout API failed or skipped, '
          'continuing with local logout',
        );
      }

      final localStorage = di.sl<LocalStorageDataSource>();
      await localStorage.setForceLogoutDoneAppVersion(ApiConstants.appVersion);

      await di.sl<AuthRepository>().logout();

      if (!context.mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.login,
        (route) => false,
      );
    } catch (e, stack) {
      debugPrint('ForceUpdate: force logout failed: $e\n$stack');
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
