import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'core/di/injection_container.dart' as di;
import 'core/navigation/app_navigator.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/presentation/cubit/splash_cubit.dart';
import 'features/splash/data/datasources/local_storage_data_source.dart';
import 'utils/app_globals.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock device orientation to portrait mode only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Local notifications: configure per-platform
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  AndroidNotificationChannel? androidChannel;

  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    if (Platform.isAndroid) {
      androidChannel = const AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'Used for important notifications.',
        importance: Importance.high,
      );
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidChannel);
    }

    const androidInit = AndroidInitializationSettings('ic_mitsui_logo');
    final iosInit = Platform.isIOS
        ? const DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          )
        : null;
    final initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );
    await flutterLocalNotificationsPlugin.initialize(initSettings);
  }

  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await _setupFirebaseMessaging();
  } catch (e, stack) {
    debugPrint('Firebase setup failed (app will continue): $e\n$stack');
  }

  // Initialize dependency injection
  await di.init();

  _setupNotificationTapHandling();

  // Foreground messages: show local notification (Android only).
  try {
    final notificationChannel = androidChannel;
    if (!kIsWeb && Platform.isAndroid && notificationChannel != null) {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final notification = message.notification;
        final android = message.notification?.android;
        if (notification != null && android != null) {
          final bigTextStyle = BigTextStyleInformation(
            notification.body ?? '',
            contentTitle: notification.title,
            htmlFormatBigText: false,
            htmlFormatContentTitle: false,
          );
          flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                notificationChannel.id,
                notificationChannel.name,
                channelDescription: notificationChannel.description,
                icon: android.smallIcon ?? 'ic_mitsui_logo',
                importance: Importance.high,
                priority: Priority.high,
                styleInformation: bigTextStyle,
              ),
            ),
          );
        }
      });
    }
  } catch (e) {
    debugPrint('FCM foreground listener setup failed: $e');
  }

  runApp(const MyApp());
}

Future<void> _setupFirebaseMessaging() async {
  // Token fetch must not block app launch when Google Play Services / FIS is down.
  try {
    final token = await FirebaseMessaging.instance
        .getToken()
        .timeout(const Duration(seconds: 10));
    Global.fcmToken = token;
    if (Global.fcmToken != null && Global.fcmToken!.trim().isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', Global.fcmToken!.trim());
      await prefs.remove('last_registered_fcm_token');
      debugPrint('FCM Token: ${Global.fcmToken}');
    } else {
      debugPrint('FCM Token: <empty>');
    }
  } catch (e) {
    debugPrint('FCM Token: unavailable ($e)');
    Global.fcmToken = null;
  }

  FirebaseMessaging.instance.onTokenRefresh.listen((t) {
    Global.fcmToken = t;
    SharedPreferences.getInstance().then((p) async {
      if (Global.fcmToken != null && Global.fcmToken!.trim().isNotEmpty) {
        await p.setString('fcm_token', Global.fcmToken!.trim());
        await p.remove('last_registered_fcm_token');
      }
    });
    debugPrint('FCM Token Refreshed: ${Global.fcmToken}');
  });

  try {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  } catch (e) {
    debugPrint('FCM permission setup failed: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mitsui',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      navigatorKey: rootNavigatorKey,
      onGenerateRoute: AppRoutes.generateRoute,
      initialRoute: AppRoutes.splash,
      builder: (context, child) {
        return BlocProvider<SplashCubit>(
          create: (_) => di.sl<SplashCubit>(),
          child: SafeArea(
            top: false,
            left: false,
            right: false,
            bottom: true,
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}

void _setupNotificationTapHandling() {
  try {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      final localStorage = di.sl<LocalStorageDataSource>();
      final loggedIn = await localStorage.isLoggedIn();
      if (!loggedIn) return;

      final nav = rootNavigatorKey.currentState;
      if (nav == null) return;

      nav.pushNamedAndRemoveUntil(AppRoutes.dashboard, (route) => false);
    });

    FirebaseMessaging.instance.getInitialMessage().then((message) async {
      if (message == null) return;
      final localStorage = di.sl<LocalStorageDataSource>();
      final loggedIn = await localStorage.isLoggedIn();
      if (!loggedIn) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final nav = rootNavigatorKey.currentState;
        if (nav == null) return;
        nav.pushNamedAndRemoveUntil(AppRoutes.dashboard, (route) => false);
      });
    });
  } catch (e) {
    debugPrint('FCM notification tap handling setup failed: $e');
  }
}
