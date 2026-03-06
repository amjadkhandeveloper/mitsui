import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';

class HorizontalDateCalendar extends StatefulWidget {
  final DateTime? selectedDate;
  final Function(DateTime) onDateSelected;
  final List<DateTime>? availableDates;

  const HorizontalDateCalendar({
    super.key,
    this.selectedDate,
    required this.onDateSelected,
    this.availableDates,
  });

  @override
  State<HorizontalDateCalendar> createState() => _HorizontalDateCalendarState();
}

class _HorizontalDateCalendarState extends State<HorizontalDateCalendar> {
  late DateTime _selectedDate;
  late ScrollController _scrollController;
  final int _daysToShow = 30; // Show 30 days

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate ?? DateTime.now();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDate();
    });
  }

  @override
  void didUpdateWidget(HorizontalDateCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != oldWidget.selectedDate && widget.selectedDate != null) {
      _selectedDate = widget.selectedDate!;
      _scrollToSelectedDate();
    }
  }

  void _scrollToSelectedDate() {
    final today = DateTime.now();
    final daysDifference = _selectedDate.difference(
      DateTime(today.year, today.month, today.day),
    ).inDays;
    
    if (daysDifference >= 0 && daysDifference < _daysToShow) {
      final itemWidth = 70.0; // Approximate width of each date item
      final scrollPosition = daysDifference * itemWidth;
      _scrollController.animateTo(
        scrollPosition,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool _isDateAvailable(DateTime date) {
    if (widget.availableDates == null) return true;
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return widget.availableDates!.any((availableDate) {
      final normalizedAvailable = DateTime(
        availableDate.year,
        availableDate.month,
        availableDate.day,
      );
      return normalizedDate.isAtSameMomentAs(normalizedAvailable);
    });
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final startDate = DateTime(today.year, today.month, today.day);
    
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        itemCount: _daysToShow,
        itemBuilder: (context, index) {
          final date = startDate.add(Duration(days: index));
          final isSelected = _selectedDate.year == date.year &&
              _selectedDate.month == date.month &&
              _selectedDate.day == date.day;
          final isToday = date.year == today.year &&
              date.month == today.month &&
              date.day == today.day;
          final isAvailable = _isDateAvailable(date);

          return GestureDetector(
            onTap: () {
              if (isAvailable) {
                setState(() {
                  _selectedDate = date;
                });
                widget.onDateSelected(date);
              }
            },
            child: Container(
              width: 70,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.mitsuiBlue
                    : isToday
                        ? AppTheme.mitsuiLightBlue
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: isToday && !isSelected
                    ? Border.all(color: AppTheme.mitsuiBlue, width: 1.5)
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('EEE').format(date),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : isToday
                              ? AppTheme.mitsuiBlue
                              : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : isToday
                              ? AppTheme.mitsuiBlue
                              : isAvailable
                                  ? Colors.black87
                                  : Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('MMM').format(date),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Colors.white.withOpacity(0.9)
                          : isToday
                              ? AppTheme.mitsuiBlue
                              : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

