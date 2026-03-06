import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginInputField extends StatelessWidget {
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final VoidCallback? onToggleVisibility;
  final bool showVisibilityToggle;
  final List<TextInputFormatter>? inputFormatters;

  const LoginInputField({
    super.key,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
    required this.controller,
    this.validator,
    this.onToggleVisibility,
    this.showVisibilityToggle = false,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(prefixIcon, color: Theme.of(context).colorScheme.primary),
        suffixIcon: showVisibilityToggle
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: onToggleVisibility,
              )
            : null,
      ),
    );
  }
}

