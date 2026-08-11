import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../utils/app_globals.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = AppTheme.mutedTextColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('About App'),
        backgroundColor: AppTheme.mitsuiDarkBlue,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderColor(context)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Image.asset(
                    'assets/images/ic_mitsui_logo_tran.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                ApiConstants.appName,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Version ${ApiConstants.appVersion}',
                style: TextStyle(
                  fontSize: 14,
                  color: muted,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Release date: ${ApiConstants.releaseDate}',
                style: TextStyle(
                  fontSize: 14,
                  color: muted,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.elevatedSurface(context),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.borderColor(context)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.notifications_active_outlined,
                          size: 18,
                          color: scheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'FCM Token',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: scheme.onSurface,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          tooltip: 'Copy',
                          onPressed: (Global.fcmToken == null ||
                                  Global.fcmToken!.isEmpty)
                              ? null
                              : () async {
                                  await Clipboard.setData(
                                    ClipboardData(text: Global.fcmToken!),
                                  );
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('FCM token copied'),
                                    ),
                                  );
                                },
                          icon: const Icon(Icons.copy, size: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      (Global.fcmToken == null || Global.fcmToken!.isEmpty)
                          ? 'Token not available yet. Open app and allow notifications.'
                          : Global.fcmToken!,
                      style: TextStyle(
                        fontSize: 14,
                        color: muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
