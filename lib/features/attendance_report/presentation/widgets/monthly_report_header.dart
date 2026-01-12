import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/animations.dart';
import '../../../../core/utils/gradients.dart';
import '../../../../core/widgets/styled_card.dart';
import '../../../attendance/domain/entities/driver.dart';

class MonthlyReportHeader extends StatelessWidget {
  final List<Driver> drivers;
  final Driver? selectedDriver;
  final DateTime selectedMonth;
  final Function(Driver?) onDriverSelected;
  final Function(DateTime) onMonthSelected;

  const MonthlyReportHeader({
    super.key,
    required this.drivers,
    this.selectedDriver,
    required this.selectedMonth,
    required this.onDriverSelected,
    required this.onMonthSelected,
  });

  @override
  Widget build(BuildContext context) {
    final monthFormat = DateFormat('MMMM yyyy');
    final monthText = monthFormat.format(selectedMonth);

    return FadeSlideAnimation(
      delay: const Duration(milliseconds: 100),
      beginOffset: const Offset(0, 0.2),
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.bar_chart,
                    color: Colors.blue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Monthly Attendance Report',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Driver Filter
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Driver',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                StyledCard(
                  padding: EdgeInsets.zero,
                  margin: EdgeInsets.zero,
                  child: DropdownButtonFormField<Driver>(
                    value: selectedDriver,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    items: [
                      const DropdownMenuItem<Driver>(
                        value: null,
                        child: Text('All Drivers'),
                      ),
                      ...drivers.map((driver) {
                        return DropdownMenuItem<Driver>(
                          value: driver,
                          child: Text(driver.name),
                        );
                      }),
                    ],
                    onChanged: onDriverSelected,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down),
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Month Filter
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Month',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                StyledCard(
                  padding: EdgeInsets.zero,
                  margin: EdgeInsets.zero,
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedMonth,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                        initialDatePickerMode: DatePickerMode.year,
                      );
                      if (picked != null) {
                        onMonthSelected(picked);
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              monthText,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.black87,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

