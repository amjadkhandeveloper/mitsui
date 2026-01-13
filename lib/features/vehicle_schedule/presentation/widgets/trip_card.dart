import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/animations.dart';
import '../../../../core/widgets/styled_card.dart';
import '../../domain/entities/trip.dart';

class TripCard extends StatelessWidget {
  final Trip trip;
  final int index;

  const TripCard({
    super.key,
    required this.trip,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final timeFormat = DateFormat('hh:mma');

    return FadeSlideAnimation(
      delay: Duration(milliseconds: 300 + (index * 50)),
      beginOffset: const Offset(0, 0.1),
      child: StyledCard(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.directions_car,
                    color: Colors.black54,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Trip Schedule',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Date: ${dateFormat.format(trip.date)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Start Time',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          timeFormat.format(trip.startTime),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'End Time',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          timeFormat.format(trip.endTime),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildStatusBadge(trip.status),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(TripStatus status) {
    Color backgroundColor;
    Color textColor;
    IconData icon;
    String statusText;

    switch (status) {
      case TripStatus.pending:
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade700;
        icon = Icons.access_time;
        statusText = 'Assigned';
        break;
      case TripStatus.accepted:
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade700;
        icon = Icons.check_circle;
        statusText = 'Accepted';
        break;
      case TripStatus.rejected:
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade700;
        icon = Icons.cancel;
        statusText = 'Rejected';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: textColor,
          ),
          const SizedBox(width: 6),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

