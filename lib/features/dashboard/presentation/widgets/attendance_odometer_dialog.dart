import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import 'odometer_wheel_picker.dart';

class AttendanceOdometerDialog {
  AttendanceOdometerDialog._();

  static Future<double?> show(
    BuildContext context, {
    required bool isCheckIn,
  }) {
    double selectedValue = 0;
    String? errorText;

    return showDialog<double>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                  const SizedBox(height: 12),
                  OdometerWheelPicker(
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
}
