import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/splash_cubit.dart';
import '../widgets/splash_logo.dart';
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
  @override
  void initState() {
    super.initState();
    // Start initialization after a brief delay to show logo animation
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        context.read<SplashCubit>().initializeApp();
      }
    });
  }

  void _handleNavigation(AppInitStatus status) {
    if (!mounted) return;

    switch (status) {
      case AppInitStatus.showIntroduction:
        // Navigate to Introduction Screen
        Navigator.of(context).pushReplacementNamed(AppRoutes.introduction);
        break;
      case AppInitStatus.authenticated:
        // Navigate to Home Screen
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
        break;
      case AppInitStatus.unauthenticated:
        // Navigate to Login Screen
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
        break;
      case AppInitStatus.error:
        // Navigate to Login Screen on error (fallback)
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
          // Handle navigation when initialization completes
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
              child: Stack(
                children: [
                  // Logo Section
                  Center(
                    child: SplashLogo(
                      onAnimationComplete: () {
                        context.read<SplashCubit>().showLogo();
                      },
                    ),
                  ),
                  // Loading Indicator (shown if initialization takes time)
                  SplashLoadingIndicator(
                    show: state.isLoading && state.isLogoVisible,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
