import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection_container.dart' as di;
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/presentation/cubit/splash_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock device orientation to portrait mode only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize dependency injection
  await di.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mitsui',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
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
