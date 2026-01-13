import 'package:flutter/material.dart';
import '../../../../core/utils/animations.dart';
import '../../../../core/utils/gradients.dart';

class VehicleScheduleHeader extends StatelessWidget {
  const VehicleScheduleHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return FadeSlideAnimation(
      delay: const Duration(milliseconds: 100),
      beginOffset: const Offset(0, 0.2),
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: AppGradients.primaryBlueGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.schedule,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Vehicle Schedule',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'View and manage vehicle schedules',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
