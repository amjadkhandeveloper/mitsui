import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Standard gradient utilities for the app
class AppGradients {
  /// Primary blue gradient for backgrounds
  static LinearGradient get primaryBlueGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppTheme.mitsuiBlue,
          AppTheme.mitsuiDarkBlue,
        ],
      );

  /// Subtle blue gradient for cards
  static LinearGradient get subtleBlueGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppTheme.mitsuiBlue.withOpacity(0.9),
          AppTheme.mitsuiBlue,
        ],
      );

  /// Light blue gradient for backgrounds
  static LinearGradient get lightBlueGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppTheme.mitsuiLightBlue,
          Colors.white,
        ],
      );

  /// Button gradient
  static LinearGradient get buttonGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppTheme.mitsuiDarkBlue,
          AppTheme.mitsuiBlue,
        ],
      );

  /// Card shadow gradient
  static LinearGradient get cardShadowGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.black.withOpacity(0.05),
          Colors.black.withOpacity(0.1),
        ],
      );
}
