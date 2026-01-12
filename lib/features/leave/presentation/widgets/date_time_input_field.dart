import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/styled_card.dart';

class DateTimeInputField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final bool isDate;
  final Function(DateTime) onTap;
  final String? errorText;

  const DateTimeInputField({
    super.key,
    required this.label,
    this.value,
    required this.isDate,
    required this.onTap,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final icon = isDate ? Icons.calendar_today : Icons.access_time;
    final format = isDate ? DateFormat('dd-MMM-yyyy') : DateFormat('hh:mm a');
    final displayText = value != null ? format.format(value!) : null;

    return StyledCard(
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () async {
          DateTime? picked;
          if (isDate) {
            picked = await showDatePicker(
              context: context,
              initialDate: value ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
          } else {
            final time = await showTimePicker(
              context: context,
              initialTime: value != null
                  ? TimeOfDay.fromDateTime(value!)
                  : TimeOfDay.now(),
            );
            if (time != null) {
              final now = DateTime.now();
              picked = DateTime(
                now.year,
                now.month,
                now.day,
                time.hour,
                time.minute,
              );
            }
          }
          if (picked != null) {
            onTap(picked);
          }
        },
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayText ?? label,
                      style: TextStyle(
                        fontSize: 16,
                        color: displayText != null
                            ? Theme.of(context).colorScheme.onSurface
                            : Colors.grey.shade600,
                        fontWeight: displayText != null
                            ? FontWeight.w500
                            : FontWeight.normal,
                      ),
                    ),
                    if (errorText != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        errorText!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

