import 'package:flutter/material.dart';
import '../../../../core/utils/animations.dart';

enum QuickActionType {
  checkIn,
  applyLeave,
}

enum AttendanceActionStyle {
  checkIn,
  checkOut,
  standbyIn,
  standbyOut,
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
  /// Explicit attendance style. When null, style is inferred from [checkInLabel].
  final AttendanceActionStyle? attendanceStyle;
  final EdgeInsetsGeometry margin;
  final int animationDelayMs;

  const QuickActionButton({
    super.key,
    required this.type,
    required this.onTap,
    this.checkInLabel,
    this.leaveActionLabel,
    this.enabled = true,
    this.attendanceStyle,
    this.margin = const EdgeInsets.symmetric(horizontal: 4),
    this.animationDelayMs = 300,
  });

  AttendanceActionStyle get _resolvedAttendanceStyle {
    if (attendanceStyle != null) return attendanceStyle!;
    final label = (checkInLabel ?? '').toLowerCase();
    if (label.contains('standby out')) return AttendanceActionStyle.standbyOut;
    if (label.contains('standby in')) return AttendanceActionStyle.standbyIn;
    if (label.contains('check out')) return AttendanceActionStyle.checkOut;
    return AttendanceActionStyle.checkIn;
  }

  Color _backgroundColor() {
    if (!enabled) return Colors.grey.shade400;
    switch (_resolvedAttendanceStyle) {
      case AttendanceActionStyle.checkIn:
        return Colors.green;
      case AttendanceActionStyle.checkOut:
      case AttendanceActionStyle.standbyOut:
        return Colors.red;
      case AttendanceActionStyle.standbyIn:
        return Colors.amber.shade700;
    }
  }

  IconData _icon() {
    switch (_resolvedAttendanceStyle) {
      case AttendanceActionStyle.checkIn:
      case AttendanceActionStyle.standbyIn:
        return Icons.login;
      case AttendanceActionStyle.checkOut:
      case AttendanceActionStyle.standbyOut:
        return Icons.logout;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCheckIn = type == QuickActionType.checkIn;

    return FadeSlideAnimation(
      delay: Duration(milliseconds: animationDelayMs),
      beginOffset: const Offset(-0.2, 0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            margin: margin,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              color: isCheckIn
                  ? _backgroundColor()
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
                  isCheckIn ? _icon() : Icons.calendar_today,
                  color: isCheckIn
                      ? Colors.white
                      : Theme.of(context).colorScheme.primary,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    isCheckIn
                        ? (checkInLabel ?? 'Check In')
                        : (leaveActionLabel ?? 'Apply Leave'),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isCheckIn
                          ? Colors.white
                          : Theme.of(context).colorScheme.primary,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
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
