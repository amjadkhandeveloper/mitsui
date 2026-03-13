import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/toast.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../splash/data/datasources/local_storage_data_source.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isSubmitting = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final newPwd = _passwordController.text.trim();
    if (newPwd.length < 6 || newPwd.length > 24) {
      Toast.showError(
        context,
        'Password must be between 6 and 24 characters long.',
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final localStorage = di.sl<LocalStorageDataSource>();
      final userIdStr = await localStorage.getUserId();
      final driverIdStr = await localStorage.getDriverId();

      final userId = int.tryParse(userIdStr ?? '') ?? 0;
      final driverId = int.tryParse(driverIdStr ?? '') ?? 0;

      if (userId == 0 && driverId == 0) {
        if (mounted) {
          Toast.showError(
            context,
            'User information not found. Please login again.',
          );
        }
        setState(() {
          _isSubmitting = false;
        });
        return;
      }

      final dio = di.sl<Dio>();
      final response = await dio.post(
        ApiConstants.resetPassword,
        data: {
          'userid': userId,
          'driverid': driverId,
          'newPassword': newPwd,
        },
      );

      int? status;
      String? message;
      final data = response.data;
      if (data is Map<String, dynamic>) {
        status = data['status'] is int
            ? data['status'] as int
            : int.tryParse(data['status'].toString());
        message = data['message']?.toString();
      }

      if (response.statusCode == 200 && status == 200) {
        if (mounted) {
          Toast.showSuccess(
            context,
            message ?? 'Password reset successfully.',
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          Toast.showError(
            context,
            message ?? 'Failed to reset password.',
          );
        }
        setState(() {
          _isSubmitting = false;
        });
      }
    } catch (e) {
      if (mounted) {
        Toast.showError(
          context,
          'Failed to reset password: $e',
        );
      }
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Reset password'),
        backgroundColor: AppTheme.mitsuiDarkBlue,
        elevation: 0,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const Text(
                  'Enter your new password',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  maxLength: 24,
                  decoration: InputDecoration(
                    labelText: 'New password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a new password';
                    }
                    if (value.length < 6 || value.length > 24) {
                      return 'Password must be 6–24 characters long';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  maxLength: 24,
                  decoration: InputDecoration(
                    labelText: 'Confirm password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.mitsuiDarkBlue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isSubmitting ? null : _onSubmit,
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Reset password',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

