import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../core/utils/animations.dart';
import '../../../../core/widgets/styled_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/attendance_record.dart';

class AttendanceCalendar extends StatefulWidget {
  final DateTime selectedDate;
  final DateTime focusedDay;
  final Function(DateTime, DateTime) onDaySelected;
  final Map<DateTime, AttendanceStatus> attendanceMap;
  final Function(DateTime) onMonthChanged;

  const AttendanceCalendar({
    super.key,
    required this.selectedDate,
    required this.focusedDay,
    required this.onDaySelected,
    required this.attendanceMap,
    required this.onMonthChanged,
  });

  @override
  State<AttendanceCalendar> createState() => _AttendanceCalendarState();
}

class _AttendanceCalendarState extends State<AttendanceCalendar> {
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.focusedDay;
  }

  @override
  void didUpdateWidget(AttendanceCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusedDay != oldWidget.focusedDay) {
      _focusedDay = widget.focusedDay;
    }
  }

  void _onPreviousMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1);
    });
    widget.onMonthChanged(_focusedDay);
  }

  void _onNextMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1);
    });
    widget.onMonthChanged(_focusedDay);
  }

  AttendanceStatus? _getAttendanceStatus(DateTime day) {
    // Normalize date to remove time component for comparison
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return widget.attendanceMap[normalizedDay];
  }

  @override
  Widget build(BuildContext context) {
    return FadeSlideAnimation(
      delay: const Duration(milliseconds: 200),
      beginOffset: const Offset(0, 0.2),
      child: StyledCard(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            // Calendar Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _onPreviousMonth,
                ),
                Text(
                  '${_getMonthName(_focusedDay.month)} ${_focusedDay.year}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _onNextMonth,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Calendar
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              onPageChanged: (focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                });
                widget.onMonthChanged(focusedDay);
              },
              selectedDayPredicate: (day) {
                return isSameDay(widget.selectedDate, day);
              },
              calendarFormat: CalendarFormat.month,
              startingDayOfWeek: StartingDayOfWeek.sunday,
              headerVisible: false,
              daysOfWeekVisible: true,
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                selectedDecoration: BoxDecoration(
                  color: AppTheme.mitsuiBlue,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.green.shade400,
                  shape: BoxShape.circle,
                ),
                defaultTextStyle: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
                weekendTextStyle: TextStyle(
                  fontSize: 14,
                  color: Colors.red.shade700,
                ),
                selectedTextStyle: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                todayTextStyle: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                markerDecoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 1,
                markerSize: 6,
                markerMargin: const EdgeInsets.symmetric(horizontal: 0.5),
              ),
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                weekendStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
              onDaySelected: widget.onDaySelected,
              eventLoader: (day) {
                final status = _getAttendanceStatus(day);
                return status != null ? [status] : [];
              },
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  final status = _getAttendanceStatus(day);
                  final isSelected = isSameDay(widget.selectedDate, day);
                  final isToday = isSameDay(DateTime.now(), day);

                  return Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? AppTheme.mitsuiBlue
                          : isToday
                              ? Colors.green.shade400
                              : null,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Date number
                        Center(
                          child: Text(
                            '${day.day}',
                            style: TextStyle(
                              fontSize: 14,
                              color: isSelected || isToday
                                  ? Colors.white
                                  : Colors.black87,
                              fontWeight: isSelected || isToday
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        // Attendance indicator (small dot at bottom)
                        if (status != null && !isSelected && !isToday)
                          Positioned(
                            bottom: 2,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: status == AttendanceStatus.present
                                    ? Colors.green
                                    : Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
                selectedBuilder: (context, day, focusedDay) {
                  return Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.mitsuiBlue,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
                todayBuilder: (context, day, focusedDay) {
                  final status = _getAttendanceStatus(day);
                  return Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade400,
                      shape: BoxShape.circle,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Center(
                          child: Text(
                            '${day.day}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (status != null)
                          Positioned(
                            bottom: 2,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: status == AttendanceStatus.present
                                    ? Colors.green.shade800
                                    : Colors.red.shade800,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(Colors.green, 'Present'),
                const SizedBox(width: 24),
                _buildLegendItem(Colors.red, 'Absent'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }
}

