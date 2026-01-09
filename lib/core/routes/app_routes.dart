import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/splash/presentation/cubit/splash_cubit.dart';
import '../../features/login/presentation/screens/login_screen.dart';
import '../../features/login/presentation/cubit/login_cubit.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/dashboard/presentation/cubit/dashboard_cubit.dart';
import '../di/injection_container.dart' as di;

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String dashboard = '/dashboard';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<SplashCubit>(
            create: (_) => di.sl<SplashCubit>(),
            child: const SplashScreen(),
          ),
        );
      case home:
      case dashboard:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<DashboardCubit>(
            create: (_) => di.sl<DashboardCubit>(),
            child: const DashboardScreen(),
          ),
        );
      case login:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<LoginCubit>(
            create: (_) => di.sl<LoginCubit>(),
            child: const LoginScreen(),
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
