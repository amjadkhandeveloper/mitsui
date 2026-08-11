import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/styled_card.dart';

class TimeInputField extends StatelessWidget {
  final String label;
  final TimeOfDay? value;
  final Function(TimeOfDay) onTap;
  final String? errorText;

  const TimeInputField({
    super.key,
    required this.label,
    this.value,
    required this.onTap,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final hourText = value != null
        ? value!.hour.toString().padLeft(2, '0')
        : 'HH';
    final minuteText = value != null
        ? value!.minute.toString().padLeft(2, '0')
        : 'MM';
    final scheme = Theme.of(context).colorScheme;
    final muted = AppTheme.mutedTextColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chipBg =
        isDark ? AppTheme.darkSurfaceElevated : Colors.grey.shade100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        StyledCard(
          padding: EdgeInsets.zero,
          margin: EdgeInsets.zero,
          child: InkWell(
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: value ?? TimeOfDay.now(),
              );
              if (time != null) {
                onTap(time);
              }
            },
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: chipBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          hourText,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: value != null
                                ? scheme.onSurface
                                : muted,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    ':',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: muted,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: chipBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          minuteText,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: value != null
                                ? scheme.onSurface
                                : muted,
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
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: TextStyle(
              fontSize: 14,
              color: Colors.red.shade700,
            ),
          ),
        ],
      ],
    );
  }
}

