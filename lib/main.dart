import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'core/di/injection_container.dart' as di;
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

  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final androidChannel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'Used for important notifications.',
    importance: Importance.high,
  );
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(androidChannel);

  final androidInit = AndroidInitializationSettings('ic_mitsui_logo');
  final initSettings = InitializationSettings(android: androidInit);
  await flutterLocalNotificationsPlugin.initialize(settings: initSettings);

  // Token can be retrieved even if notification permission is denied (esp. Android).
  final token = await FirebaseMessaging.instance.getToken();
  Global.fcmToken = token;
  if (Global.fcmToken != null && Global.fcmToken!.trim().isNotEmpty) {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token', Global.fcmToken!.trim());
    await prefs.remove('last_registered_fcm_token');
    debugPrint('FCM Token: ${Global.fcmToken}');
  } else {
    debugPrint('FCM Token: <empty>');
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

  // Initialize dependency injection
  await di.init();

  _setupNotificationTapHandling();

  // Foreground messages: show local notification.
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final notification = message.notification;
    final android = message.notification?.android;
    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            androidChannel.id,
            androidChannel.name,
            channelDescription: androidChannel.description,
            icon: android.smallIcon ?? 'ic_mitsui_logo',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mitsui',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      navigatorKey: navigatorKey,
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
            child: Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        );
      },
    );
  }
}

void _setupNotificationTapHandling() {
  // Called lazily once app is running, but kept here for clarity in case you want
  // to extend navigation based on message data.
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
    final localStorage = di.sl<LocalStorageDataSource>();
    final loggedIn = await localStorage.isLoggedIn();
    if (!loggedIn) return;

    final nav = MyApp.navigatorKey.currentState;
    if (nav == null) return;

    // Default: open dashboard entry point.
    nav.pushNamedAndRemoveUntil(AppRoutes.dashboard, (route) => false);
  });

  // If the app was terminated and opened via a notification tap.
  FirebaseMessaging.instance.getInitialMessage().then((message) async {
    if (message == null) return;
    final localStorage = di.sl<LocalStorageDataSource>();
    final loggedIn = await localStorage.isLoggedIn();
    if (!loggedIn) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final nav = MyApp.navigatorKey.currentState;
      if (nav == null) return;
      nav.pushNamedAndRemoveUntil(AppRoutes.dashboard, (route) => false);
    });
  });
}
