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
      backgroundColor: Theme.of(context).colorScheme.surface,
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
                        color: Colors.white.withValues(alpha: 0.9),
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
                _DrawerTile(
                  icon: Icons.lock_reset,
                  label: 'Reset password',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.resetPassword);
                  },
                ),
                _DrawerTile(
                  icon: Icons.contact_phone,
                  label: 'Support',
                  onTap: () {
                    Navigator.pop(context);
                    _showAdminContact(context);
                  },
                ),
                _DrawerTile(
                  icon: Icons.info_outline,
                  label: 'About app',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.aboutApp);
                  },
                ),
                _DrawerTile(
                  icon: Icons.logout,
                  label: 'Logout',
                  isDestructive: true,
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

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _DrawerTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDestructive ? Colors.red : scheme.onSurface;

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDestructive
              ? Colors.red.withValues(alpha: 0.08)
              : (isDark
                  ? AppTheme.darkSurfaceElevated
                  : AppTheme.mitsuiLightBlue),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isDestructive ? FontWeight.w600 : FontWeight.w500,
          color: color,
        ),
      ),
      onTap: onTap,
    );
  }
}
