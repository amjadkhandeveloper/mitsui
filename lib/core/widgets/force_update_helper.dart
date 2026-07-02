import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/api_constants.dart';
import '../di/injection_container.dart' as di;
import '../services/force_update_service.dart';
import '../theme/app_theme.dart';
import '../routes/app_routes.dart';
import '../../features/login/domain/repositories/auth_repository.dart';
import '../../features/splash/data/datasources/local_storage_data_source.dart';

class ForceUpdateHelper {
  ForceUpdateHelper._();

  static bool _isChecking = false;
  static bool _dialogVisible = false;
  static bool _logoutInProgress = false;

  /// Runs the force-update API in the background and shows a blocking dialog
  /// when the installed version is below the server minimum.
  static Future<void> checkInBackground(BuildContext context) async {
    if (_isChecking || _dialogVisible || _logoutInProgress) {
      return;
    }

    _isChecking = true;
    try {
      final service = di.sl<ForceUpdateService>();
      final policy = await service.fetchPolicy();
      if (policy == null || !context.mounted || _dialogVisible) return;

      final updateRequired = ApiConstants.localAppVersion < policy.remoteAppVersion;

      // Force update has higher priority (blocking UI).
      if (updateRequired) {
        await _showForceUpdateDialog(context);
        return;
      }

      final shouldLogout = await service.shouldForceLogoutOncePerVersion(
        remoteAppVersion: policy.remoteAppVersion,
        forceLogout: policy.forceLogout,
      );

      if (shouldLogout && context.mounted) {
        _logoutInProgress = true;
        await _forceLogoutNow(context, policy.remoteAppVersion);
      }
    } catch (_) {
      // Do not interrupt dashboard behaviour on failure.
    } finally {
      _isChecking = false;
      _dialogVisible = false;
      _logoutInProgress = false;
    }
  }

  static Future<void> _showForceUpdateDialog(BuildContext context) async {
    if (_dialogVisible) return;
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
  }

  static Future<void> _forceLogoutNow(BuildContext context, int remoteAppVersion) async {
    try {
      // Mark as done first to avoid loops if navigation rebuilds quickly.
      final localStorage = di.sl<LocalStorageDataSource>();
      await localStorage.setForceLogoutDoneAppVersion(remoteAppVersion);

      await di.sl<AuthRepository>().logout();

      if (!context.mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.login,
        (route) => false,
      );
    } catch (_) {
      // ignore
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
