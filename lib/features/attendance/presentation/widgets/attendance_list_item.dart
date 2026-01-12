import 'package:flutter/material.dart';
import '../../../../core/utils/animations.dart';
import '../../domain/entities/attendance_record.dart';
import 'package:intl/intl.dart';

class AttendanceListItem extends StatelessWidget {
  final AttendanceRecord record;
  final int index;

  const AttendanceListItem({
    super.key,
    required this.record,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final isPresent = record.status == AttendanceStatus.present;
    final dateFormat = DateFormat('dd-MMM-yyyy');
    final formattedDate = dateFormat.format(record.date);

    return FadeSlideAnimation(
      delay: Duration(milliseconds: 400 + (index * 50)),
      beginOffset: const Offset(0, 0.1),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.withOpacity(0.2),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // Date Column
            SizedBox(
              width: 100,
              child: Text(
                formattedDate,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Name Column
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isPresent ? Colors.green : Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      record.driverName,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Present Column
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isPresent ? Colors.green : Colors.red,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPresent ? Icons.check : Icons.close,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

