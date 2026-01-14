import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/toast.dart';
import '../../../login/domain/entities/user.dart';
import '../cubit/attendance_cubit.dart';
import '../widgets/todays_attendance_card.dart';
import '../widgets/driver_dropdown.dart';
import '../widgets/attendance_calendar.dart';
import '../../domain/entities/attendance_record.dart';

class AttendanceScreen extends StatefulWidget {
  final User? currentUser;

  const AttendanceScreen({
    super.key,
    this.currentUser,
  });

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    final cubit = context.read<AttendanceCubit>();
    
    // Load drivers if user is expat
    if (widget.currentUser?.role == UserRole.expat) {
      cubit.loadDrivers();
    } else {
      // Load attendance for driver directly
      _loadAttendanceForMonth(_focusedDay);
    }
  }

  void _loadAttendanceForMonth(DateTime month) {
    final startDate = DateTime(month.year, month.month, 1);
    final endDate = DateTime(month.year, month.month + 1, 0);
    
    context.read<AttendanceCubit>().loadAttendanceRecords(
      driverId: widget.currentUser?.role == UserRole.driver 
          ? widget.currentUser?.id 
          : null,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Attendance Sheet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              // Navigate to statistics screen
            },
          ),
        ],
      ),
      body: BlocConsumer<AttendanceCubit, AttendanceState>(
        listener: (context, state) {
          if (state is AttendanceError) {
            Toast.showError(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is AttendanceLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is DriversLoaded) {
            return _buildExpatView(context, state);
          }

          if (state is AttendanceLoaded) {
            return _buildAttendanceCalendarView(context, state);
          }

          return const Center(
            child: Text('No data available'),
          );
        },
      ),
    );
  }

  Widget _buildExpatView(BuildContext context, DriversLoaded state) {
    return Column(
      children: [
        TodaysAttendanceCard(
          onTap: () {
            // Navigate to today's attendance detail
          },
        ),
        DriverDropdown(
          drivers: state.drivers,
          selectedDriver: state.selectedDriver,
          onDriverSelected: (driver) {
            context.read<AttendanceCubit>().selectDriver(driver);
            // Load attendance for selected driver and current month
            final startDate = DateTime(_focusedDay.year, _focusedDay.month, 1);
            final endDate = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
            context.read<AttendanceCubit>().loadAttendanceRecords(
              driverId: driver?.id,
              startDate: startDate,
              endDate: endDate,
            );
          },
        ),
        Expanded(
          child: BlocBuilder<AttendanceCubit, AttendanceState>(
            builder: (context, state) {
              if (state is AttendanceLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is AttendanceLoaded) {
                return _buildAttendanceCalendarView(context, state);
              }
              return const Center(
                child: Text('Select a driver to view attendance'),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceCalendarView(BuildContext context, AttendanceLoaded state) {
    // Create a map of dates to attendance status
    final Map<DateTime, AttendanceStatus> attendanceMap = {};
    for (var record in state.records) {
      final normalizedDate = DateTime(
        record.date.year,
        record.date.month,
        record.date.day,
      );
      attendanceMap[normalizedDate] = record.status;
    }

    // Get selected day's attendance record
    AttendanceRecord? selectedRecord;
    final normalizedSelected = DateTime(
      _selectedDay.year,
      _selectedDay.month,
      _selectedDay.day,
    );
    try {
      selectedRecord = state.records.firstWhere(
        (record) {
          final normalizedDate = DateTime(
            record.date.year,
            record.date.month,
            record.date.day,
          );
          return normalizedDate == normalizedSelected;
        },
      );
    } catch (e) {
      selectedRecord = null;
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          AttendanceCalendar(
            selectedDate: _selectedDay,
            focusedDay: _focusedDay,
            attendanceMap: attendanceMap,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onMonthChanged: (month) {
              setState(() {
                _focusedDay = month;
              });
              _loadAttendanceForMonth(month);
            },
          ),
          // Selected Day Details
          if (selectedRecord != null)
            _buildSelectedDayDetails(context, selectedRecord),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSelectedDayDetails(BuildContext context, AttendanceRecord record) {
    final dateFormat = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
    final isPresent = record.status == AttendanceStatus.present;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPresent ? Colors.green.shade200 : Colors.red.shade200,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isPresent ? Colors.green.shade100 : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPresent ? Icons.check_circle : Icons.cancel,
                      size: 16,
                      color: isPresent ? Colors.green.shade700 : Colors.red.shade700,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isPresent ? 'Present' : 'Absent',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isPresent ? Colors.green.shade700 : Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                '${dateFormat.day}-${_getMonthAbbr(dateFormat.month)}-${dateFormat.year}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          if (isPresent && record.checkInTime != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.login, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  'Check In: ${_formatTime(record.checkInTime!)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ],
          if (isPresent && record.checkOutTime != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.logout, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  'Check Out: ${_formatTime(record.checkOutTime!)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ],
          if (record.location != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    record.location!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String _getMonthAbbr(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}

