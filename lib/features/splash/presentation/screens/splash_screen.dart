import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/splash_cubit.dart';
import '../widgets/splash_loading_indicator.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/utils/gradients.dart';
import '../../domain/entities/app_init_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _splashTimeout;

  @override
  void initState() {
    super.initState();
    _splashTimeout = Timer(const Duration(seconds: 15), () {
      if (!mounted) return;
      context.read<SplashCubit>().handleTimeout();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<SplashCubit>().initializeApp();
      }
    });
  }

  @override
  void dispose() {
    _splashTimeout?.cancel();
    super.dispose();
  }

  void _handleNavigation(AppInitStatus status) {
    if (!mounted) return;
    _splashTimeout?.cancel();

    switch (status) {
      case AppInitStatus.showIntroduction:
        Navigator.of(context).pushReplacementNamed(AppRoutes.introduction);
        break;
      case AppInitStatus.authenticated:
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
        break;
      case AppInitStatus.unauthenticated:
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
        break;
      case AppInitStatus.error:
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<SplashCubit, SplashState>(
        listener: (context, state) {
          if (state.initStatus == AppInitStatus.showIntroduction ||
              state.initStatus == AppInitStatus.authenticated ||
              state.initStatus == AppInitStatus.unauthenticated ||
              state.initStatus == AppInitStatus.error) {
            _handleNavigation(state.initStatus);
          }
        },
        child: BlocBuilder<SplashCubit, SplashState>(
          builder: (context, state) {
            return Container(
              decoration: BoxDecoration(
                gradient: AppGradients.primaryBlueGradient,
              ),
              child: SplashLoadingIndicator(show: state.isLoading),
            );
          },
        ),
      ),
    );
  }
}
