import 'package:flutter/material.dart';

import '../di/injection_container.dart' as di;
import '../routes/app_routes.dart';
import '../services/fcm_token_service.dart';
import '../theme/app_theme.dart';
import '../utils/toast.dart';
import '../../features/login/domain/repositories/auth_repository.dart';

class LogoutHelper {
  LogoutHelper._();

  static bool _logoutInProgress = false;

  static Future<void> showConfirmationAndLogout(BuildContext context) async {
    if (_logoutInProgress) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'Logout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    _logoutInProgress = true;
    _showProgressDialog(context);

    try {
      final apiSuccess = await di.sl<FcmTokenService>().logoutFromServer();

      if (!apiSuccess && context.mounted) {
        Toast.show(
          context,
          'Could not reach logout service. Signing out locally.',
          backgroundColor: Colors.orange.shade800,
          icon: Icons.warning_amber_rounded,
        );
      }

      await di.sl<AuthRepository>().logout();

      if (context.mounted) {
        _hideProgressDialog(context);
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.login,
          (route) => false,
        );
      }
    } catch (_) {
      if (context.mounted) {
        _hideProgressDialog(context);
        Toast.show(
          context,
          'Logout failed. Please try again.',
          icon: Icons.error_outline,
        );
      }
    } finally {
      _logoutInProgress = false;
    }
  }

  static void _showProgressDialog(BuildContext context) {
    showDialog<void>(
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
            content: const Row(
              children: [
                SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: AppTheme.mitsuiDarkBlue,
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Text(
                    'Logging out...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static void _hideProgressDialog(BuildContext context) {
    final navigator = Navigator.of(context, rootNavigator: true);
    if (navigator.canPop()) {
      navigator.pop();
    }
  }
}
