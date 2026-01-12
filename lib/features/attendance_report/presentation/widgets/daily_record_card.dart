import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/animations.dart';
import '../../../../core/widgets/styled_card.dart';
import '../../domain/entities/attendance_report.dart';
import '../../../attendance/domain/entities/attendance_record.dart';

class DailyRecordCard extends StatelessWidget {
  final DailyAttendanceRecord record;
  final int index;

  const DailyRecordCard({
    super.key,
    required this.record,
    required this.index,
  });

  String _formatDuration(Duration? duration) {
    if (duration == null) return '0h 0m';
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd-MMM-yyyy');
    final timeFormat = DateFormat('hh:mm a');
    final isPresent = record.status == AttendanceStatus.present;

    return FadeSlideAnimation(
      delay: Duration(milliseconds: 300 + (index * 50)),
      beginOffset: const Offset(0, 0.1),
      child: StyledCard(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateFormat.format(record.date),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isPresent
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPresent ? Icons.check_circle : Icons.cancel,
                        size: 16,
                        color: isPresent
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isPresent ? 'Present' : 'Absent',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isPresent
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (isPresent && record.checkInTime != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailCard(
                      icon: Icons.login,
                      iconColor: Colors.green,
                      label: 'Check In',
                      value: timeFormat.format(record.checkInTime!),
                      backgroundColor: Colors.green.shade50,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildDetailCard(
                      icon: Icons.logout,
                      iconColor: Colors.orange,
                      label: 'Check Out',
                      value: record.checkOutTime != null
                          ? timeFormat.format(record.checkOutTime!)
                          : '--',
                      backgroundColor: Colors.orange.shade50,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailCard(
                      icon: Icons.access_time,
                      iconColor: Colors.blue,
                      label: 'Total Hours',
                      value: _formatDuration(record.totalHours),
                      backgroundColor: Colors.blue.shade50,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildDetailCard(
                      icon: Icons.alarm,
                      iconColor: Colors.orange,
                      label: 'Overtime',
                      value: _formatDuration(record.overtime),
                      backgroundColor: Colors.orange.shade50,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}

