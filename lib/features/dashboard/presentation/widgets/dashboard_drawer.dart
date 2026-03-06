import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/routes/app_routes.dart';

/// Navigation drawer for dashboard with Reset password, Admin contact, Logout and version.
class DashboardDrawer extends StatelessWidget {
  final VoidCallback onLogout;
  final String? userName;

  const DashboardDrawer({
    super.key,
    required this.onLogout,
    this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppTheme.mitsuiDarkBlue,
            ),
            child: SafeArea(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName ?? 'Dashboard',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Mitsui FleetPlus',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                ListTile(
                  leading:
                      const Icon(Icons.lock_reset, color: AppTheme.mitsuiDarkBlue),
                  title: const Text('Reset password'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.resetPassword);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.contact_phone,
                      color: AppTheme.mitsuiDarkBlue),
                  title: const Text('Support'),
                  onTap: () {
                    Navigator.pop(context);
                    _showAdminContact(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline,
                      color: AppTheme.mitsuiDarkBlue),
                  title: const Text('About app'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.aboutApp);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    'Logout',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    onLogout();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAdminContact(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.adminContact);
  }
}
