import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  // 1 = expat (user), 2 = driver (default: expat)
  int _selectedRoleId = 1;

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
            _selectedRoleId,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 700 || screenWidth < 360;
    
    // Responsive sizing
    final logoSize = isSmallScreen ? 70.0 : 100.0;
    final companyNameFontSize = isSmallScreen ? 16.0 : 20.0;
    final appTitleFontSize = isSmallScreen ? 14.0 : 16.0;
    final signInTitleFontSize = isSmallScreen ? 20.0 : 24.0;
    final cardPadding = isSmallScreen ? 16.0 : 24.0;
    final cardMargin = isSmallScreen ? 8.0 : 16.0;
    final spacingSmall = isSmallScreen ? 8.0 : 16.0;
    final spacingLarge = isSmallScreen ? 24.0 : 32.0;
    final topSectionHeight = isSmallScreen ? screenHeight * 0.25 : screenHeight * 0.30;
    
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
              }
            },
            child: BlocBuilder<LoginCubit, LoginState>(
              builder: (context, state) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: screenHeight - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          // Top Branding Section - Fixed height
                          Container(
                            height: topSectionHeight,
                            decoration: BoxDecoration(
                              gradient: AppGradients.primaryBlueGradient,
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Logo Container with animation (full logo for login)
                                  ScaleInAnimation(
                                    duration: AnimationDurations.slow,
                                    delay: AnimationDurations.fast,
                                    child: SizedBox(
                                      width: 104,
                                      height: 86,
                                      child: Image.asset(
                                        'assets/images/ic_mitsui_logo_tran.png',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: spacingSmall),
                                  // Company Name with animation
                                  FadeInAnimation(
                                    duration: AnimationDurations.normal,
                                    delay: const Duration(milliseconds: 400),
                                    child: Text(
                                      'MITSUI & CO. INDIA PVT LTD',
                                      style: TextStyle(
                                        fontSize: companyNameFontSize,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  // App Title with animation
                                  FadeInAnimation(
                                    duration: AnimationDurations.normal,
                                    delay: const Duration(milliseconds: 600),
                                    child: Text(
                                      'Mitsui FleetPulse',
                                      style: TextStyle(
                                        fontSize: appTitleFontSize,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Login Card Section - Flexible
                          Flexible(
                            child: FadeSlideAnimation(
                              duration: AnimationDurations.slow,
                              delay: const Duration(milliseconds: 300),
                              beginOffset: const Offset(0, 0.3),
                              child: Container(
                                margin: EdgeInsets.all(cardMargin),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(32),
                                    topRight: Radius.circular(32),
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(cardPadding),
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        // Sign In Title
                                        FadeInAnimation(
                                          delay: const Duration(milliseconds: 500),
                                          child: Text(
                                            'Sign In',
                                            style: TextStyle(
                                              fontSize: signInTitleFontSize,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        SizedBox(height: spacingLarge),
                                        // Username Field
                                        FadeSlideAnimation(
                                          delay: const Duration(milliseconds: 600),
                                          beginOffset: const Offset(-0.2, 0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Username',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.grey.shade700,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              LoginInputField(
                                                hintText: 'Enter your username',
                                                prefixIcon: Icons.person_outline,
                                                controller: _usernameController,
                                                validator: (value) {
                                                  if (value == null || value.isEmpty) {
                                                    return 'Please enter your username';
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: spacingSmall),
                                        // Password Field
                                        FadeSlideAnimation(
                                          delay: const Duration(milliseconds: 700),
                                          beginOffset: const Offset(-0.2, 0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Password',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.grey.shade700,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              LoginInputField(
                                                hintText: 'Enter your password',
                                                prefixIcon: Icons.lock_outline,
                                                obscureText: !state.isPasswordVisible,
                                                controller: _passwordController,
                                                showVisibilityToggle: true,
                                                onToggleVisibility: () {
                                                  context
                                                      .read<LoginCubit>()
                                                      .togglePasswordVisibility();
                                                },
                                                inputFormatters: [
                                                  FilteringTextInputFormatter.deny(RegExp(r'\s')),
                                                ],
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
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: spacingSmall),
                                        // Role selection: Expat or Driver
                                        FadeSlideAnimation(
                                          delay: const Duration(milliseconds: 750),
                                          beginOffset: const Offset(-0.2, 0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Login as',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.grey.shade700,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: ChoiceChip(
                                                      label: const Text('User'),
                                                      selected: _selectedRoleId == 1,
                                                      onSelected: (selected) {
                                                        if (selected) {
                                                          setState(() {
                                                            _selectedRoleId = 1;
                                                          });
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: ChoiceChip(
                                                      label: const Text('Driver'),
                                                      selected: _selectedRoleId == 2,
                                                      onSelected: (selected) {
                                                        if (selected) {
                                                          setState(() {
                                                            _selectedRoleId = 2;
                                                          });
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: spacingLarge),
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
                                                padding: EdgeInsets.symmetric(
                                                    vertical: isSmallScreen ? 14 : 16),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                              child: state.isLoading
                                                  ? SizedBox(
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
                                                  : Text(
                                                      'Sign In',
                                                      style: TextStyle(
                                                        fontSize: isSmallScreen ? 14 : 16,
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
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
