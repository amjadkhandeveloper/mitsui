import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/login_cubit.dart';
import '../widgets/login_input_field.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/gradients.dart';
import '../../../../core/utils/animations.dart';
import '../../../../core/utils/toast.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<LoginCubit>().login(
            _usernameController.text.trim(),
            _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppGradients.primaryBlueGradient,
        ),
        child: SafeArea(
          child: BlocListener<LoginCubit, LoginState>(
            listener: (context, state) {
              if (state.user != null) {
                // Navigate to home screen on successful login
                Navigator.of(context).pushReplacementNamed(AppRoutes.home);
              }
              // Show toast for errors
              if (state.errorMessage != null && !state.isLoading) {
                Toast.showError(context, state.errorMessage!);
                // Clear error after showing toast
                context.read<LoginCubit>().clearError();

                // Navigate to home screen on successful login
                Navigator.of(context).pushReplacementNamed(AppRoutes.home);
              }
            },
            child: BlocBuilder<LoginCubit, LoginState>(
              builder: (context, state) {
                return Column(
                  children: [
                    // Top Branding Section
                    Expanded(
                      flex: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: AppGradients.primaryBlueGradient,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Logo Container with animation
                              ScaleInAnimation(
                                duration: AnimationDurations.slow,
                                delay: AnimationDurations.fast,
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.business,
                                    size: 60,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Company Name with animation
                              const FadeInAnimation(
                                duration: AnimationDurations.normal,
                                delay: Duration(milliseconds: 400),
                                child: Text(
                                  'MITSUI & CO.',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              // App Title with animation
                              const FadeInAnimation(
                                duration: AnimationDurations.normal,
                                delay: Duration(milliseconds: 600),
                                child: Text(
                                  'Fleet Management System',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Login Card Section
                    Expanded(
                      flex: 3,
                      child: FadeSlideAnimation(
                        duration: AnimationDurations.slow,
                        delay: const Duration(milliseconds: 300),
                        beginOffset: const Offset(0, 0.3),
                        child: Container(
                          margin: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(32),
                              topRight: Radius.circular(32),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Sign In Title
                                  const FadeInAnimation(
                                    delay: Duration(milliseconds: 500),
                                    child: Text(
                                      'Sign In',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  // Username Field
                                  FadeSlideAnimation(
                                    delay: const Duration(milliseconds: 600),
                                    beginOffset: const Offset(-0.2, 0),
                                    child: LoginInputField(
                                      hintText: 'User Name',
                                      prefixIcon: Icons.person_outline,
                                      controller: _usernameController,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your username';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // Password Field
                                  FadeSlideAnimation(
                                    delay: const Duration(milliseconds: 700),
                                    beginOffset: const Offset(-0.2, 0),
                                    child: LoginInputField(
                                      hintText: 'Password',
                                      prefixIcon: Icons.lock_outline,
                                      obscureText: !state.isPasswordVisible,
                                      controller: _passwordController,
                                      showVisibilityToggle: true,
                                      onToggleVisibility: () {
                                        context
                                            .read<LoginCubit>()
                                            .togglePasswordVisibility();
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your password';
                                        }
                                        if (value.length < 6) {
                                          return 'Password must be at least 6 characters';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  // Sign In Button
                                  FadeSlideAnimation(
                                    delay: const Duration(milliseconds: 800),
                                    beginOffset: const Offset(0, 0.2),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: AppGradients.buttonGradient,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppTheme.mitsuiDarkBlue
                                                .withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: ElevatedButton(
                                        onPressed: state.isLoading
                                            ? null
                                            : _handleLogin,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: state.isLoading
                                            ? const SizedBox(
                                                height: 20,
                                                width: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(
                                                    Colors.white,
                                                  ),
                                                ),
                                              )
                                            : const Text(
                                                'Sign In',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
