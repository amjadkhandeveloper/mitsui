import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import 'odometer_wheel_picker.dart';

class AttendanceOdometerDialog {
  AttendanceOdometerDialog._();

  static Future<double?> show(
    BuildContext context, {
    required bool isCheckIn,
    double initialValue = 0,
    double minimumValue = 0,
  }) {
    double selectedValue = initialValue > 0 ? initialValue : 0;
    String? errorText;

    return showDialog<double>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            final hasMinimum = minimumValue > 0;
            final minimumLabel = _formatOdometer(minimumValue);

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(isCheckIn ? 'Check In' : 'Check Out'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    isCheckIn
                        ? 'Select the current odometer reading to check in.'
                        : 'Select the current odometer reading to check out.',
                  ),
                  if (hasMinimum) ...[
                    const SizedBox(height: 8),
                    Text(
                      isCheckIn
                          ? 'Minimum allowed: $minimumLabel km (last check-out reading).'
                          : 'Minimum allowed: $minimumLabel km (check-in reading).',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  OdometerWheelPicker(
                    initialValue: initialValue,
                    onChanged: (value) {
                      setState(() {
                        selectedValue = value;
                        errorText = null;
                      });
                    },
                  ),
                  if (errorText != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      errorText!,
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedValue <= 0) {
                      setState(
                        () => errorText = 'Please select a valid odometer value',
                      );
                      return;
                    }

                    if (hasMinimum &&
                        !_isOdometerAtLeast(selectedValue, minimumValue)) {
                      setState(
                        () => errorText = isCheckIn
                            ? 'Check-in odometer must be at least $minimumLabel km.'
                            : 'Check-out odometer must be at least $minimumLabel km.',
                      );
                      return;
                    }

                    Navigator.pop(dialogContext, selectedValue);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.mitsuiDarkBlue,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(isCheckIn ? 'Check In' : 'Check Out'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static bool _isOdometerAtLeast(double value, double minimum) {
    final roundedValue = (value * 10).round() / 10;
    final roundedMinimum = (minimum * 10).round() / 10;
    return roundedValue + 0.0001 >= roundedMinimum;
  }

  static String _formatOdometer(double value) {
    final rounded = (value * 10).round() / 10;
    if (rounded == rounded.roundToDouble()) {
      return rounded.toStringAsFixed(0);
    }
    return rounded.toStringAsFixed(1);
  }
}
