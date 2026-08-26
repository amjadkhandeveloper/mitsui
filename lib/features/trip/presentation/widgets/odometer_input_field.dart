import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/styled_card.dart';

class OdometerInputField extends StatelessWidget {
  final String label;
  final int? value;
  final Function(int) onChanged;
  final bool enabled;

  const OdometerInputField({
    super.key,
    required this.label,
    this.value,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
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
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        StyledCard(
          padding: EdgeInsets.zero,
          margin: EdgeInsets.zero,
          child: TextField(
            enabled: enabled,
            controller: TextEditingController(
              text: value?.toString() ?? '',
            )..selection = TextSelection.fromPosition(
                TextPosition(offset: value?.toString().length ?? 0),
              ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: InputDecoration(
              hintText: label,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: chipBg,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onChanged: (text) {
              if (text.isNotEmpty) {
                final odometer = int.tryParse(text);
                if (odometer != null) {
                  onChanged(odometer);
                }
              }
            },
          ),
        ),
      ],
    );
  }
}
