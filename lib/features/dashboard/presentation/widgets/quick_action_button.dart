import 'package:flutter/material.dart';
import '../../../../core/utils/animations.dart';

enum QuickActionType {
  checkIn,
  applyLeave,
}

class QuickActionButton extends StatelessWidget {
  final QuickActionType type;
  final VoidCallback onTap;
  /// When type is [QuickActionType.checkIn], use this label if set (e.g. 'Check Out').
  final String? checkInLabel;
  /// When type is [QuickActionType.applyLeave], use this label if set (e.g. 'My Leave' for driver).
  final String? leaveActionLabel;
  /// Whether the button is active/clickable. When false, it is shown in a disabled style.
  final bool enabled;

  const QuickActionButton({
    super.key,
    required this.type,
    required this.onTap,
    this.checkInLabel,
    this.leaveActionLabel,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isCheckIn = type == QuickActionType.checkIn;
    final isCheckoutMode =
        isCheckIn && (checkInLabel ?? '').toLowerCase() == 'check out';

    return FadeSlideAnimation(
      delay: Duration(milliseconds: isCheckIn ? 300 : 400),
      beginOffset: const Offset(-0.2, 0),
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          margin: EdgeInsets.only(
            right: isCheckIn ? 8 : 0,
            left: isCheckIn ? 0 : 8,
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: isCheckIn
                ? (enabled
                    ? (isCheckoutMode ? Colors.orange : Colors.green)
                    : Colors.grey.shade400)
                : Colors.white,
            border: isCheckIn
                ? null
                : Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isCheckIn
                    ? (isCheckoutMode ? Icons.logout : Icons.login)
                    : Icons.calendar_today,
                color: isCheckIn
                    ? Colors.white
                    : Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  isCheckIn
                      ? (checkInLabel ?? 'Check In')
                      : (leaveActionLabel ?? 'Apply Leave'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isCheckIn
                        ? Colors.white
                        : Theme.of(context).colorScheme.primary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
