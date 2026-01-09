import 'package:flutter/material.dart';
import '../../../../core/utils/animations.dart';

enum QuickActionType {
  checkIn,
  applyLeave,
}

class QuickActionButton extends StatelessWidget {
  final QuickActionType type;
  final VoidCallback onTap;

  const QuickActionButton({
    super.key,
    required this.type,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCheckIn = type == QuickActionType.checkIn;

    return FadeSlideAnimation(
      delay: Duration(milliseconds: isCheckIn ? 300 : 400),
      beginOffset: const Offset(-0.2, 0),
      child: Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            margin: EdgeInsets.only(
              right: isCheckIn ? 8 : 0,
              left: isCheckIn ? 0 : 8,
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: isCheckIn ? Colors.green : Colors.white,
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isCheckIn ? Icons.login : Icons.calendar_today,
                  color: isCheckIn
                      ? Colors.white
                      : Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  isCheckIn ? 'Check In' : 'Apply Leave',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isCheckIn
                        ? Colors.white
                        : Theme.of(context).colorScheme.primary,
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
