import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/toast.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../login/domain/entities/user.dart';
import '../../../splash/data/datasources/local_storage_data_source.dart';
import '../cubit/attendance_cubit.dart';
import '../widgets/todays_attendance_card.dart';
import '../widgets/driver_dropdown.dart';
import '../widgets/attendance_calendar.dart';
import '../../domain/entities/attendance_record.dart';
import '../../domain/entities/driver.dart';

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
    // Always load attendance directly for both expat and driver users
    _loadAttendance();
  }

  Future<void> _loadAttendance({int? driverId}) async {
    try {
      // Get driverId and userId from local storage
      final localStorage = di.sl<LocalStorageDataSource>();
      final useridString = await localStorage.getUserId();
      final driverIdString = await localStorage.getDriverId();
      
      int? userId;
      int? finalDriverId = driverId;
      
      // Parse userId
      if (useridString != null && useridString.isNotEmpty) {
        userId = int.tryParse(useridString);
      } else if (widget.currentUser?.id != null) {
        userId = int.tryParse(widget.currentUser!.id);
      }
      
      // Parse driverId if not provided
      if (finalDriverId == null && driverIdString != null && driverIdString.isNotEmpty) {
        finalDriverId = int.tryParse(driverIdString);
      } else if (finalDriverId == null && widget.currentUser?.driverId != null) {
        finalDriverId = int.tryParse(widget.currentUser!.driverId!);
      }
      
      // For driver login: use driverId, userId = 0
      // For expat login: use userId, driverId from selected driver or 0
      if (widget.currentUser?.role == UserRole.expat) {
        // Expat login: userId is the expat's id, driverId is from selected driver
        context.read<AttendanceCubit>().loadAttendanceRecords(
          driverId: finalDriverId,
          userId: userId ?? 0,
        );
      } else {
        // Driver login: driverId is the driver's id, userId = 0
        context.read<AttendanceCubit>().loadAttendanceRecords(
          driverId: finalDriverId ?? 0,
          userId: 0,
        );
      }
    } catch (e) {
      if (mounted) {
        Toast.showError(context, 'Failed to load attendance: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Attendance Sheet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => _loadAttendance(),
          ),
        ],
      ),
      body: BlocConsumer<AttendanceCubit, AttendanceState>(
        listener: (context, state) {
          if (state is AttendanceError) {
            Toast.showError(context, state.message);
          } else if (state is CheckInApproved) {
            Toast.showSuccess(context, 'Check-in approved successfully');
            // Reload attendance records - preserve selected driver if expat
            if (widget.currentUser?.role == UserRole.expat) {
              final currentState = context.read<AttendanceCubit>().state;
              if (currentState is AttendanceLoaded && currentState.selectedDriver != null) {
                final driverId = int.tryParse(currentState.selectedDriver!.id);
                _loadAttendance(driverId: driverId);
              } else {
                _loadAttendance();
              }
            } else {
              _loadAttendance();
            }
          } else if (state is CheckOutApproved) {
            Toast.showSuccess(context, 'Check-out approved successfully');
            // Reload attendance records - preserve selected driver if expat
            if (widget.currentUser?.role == UserRole.expat) {
              final currentState = context.read<AttendanceCubit>().state;
              if (currentState is AttendanceLoaded && currentState.selectedDriver != null) {
                final driverId = int.tryParse(currentState.selectedDriver!.id);
                _loadAttendance(driverId: driverId);
              } else {
                _loadAttendance();
              }
            } else {
              _loadAttendance();
            }
          }
        },
        builder: (context, state) {
          if (state is AttendanceLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // For both expat and driver users, show a simple attendance list
          if (state is AttendanceLoaded) {
            if (state.records.isEmpty) {
              return const Center(
                child: Text('No attendance records found'),
              );
            }
            return _buildAttendanceListView(context, state);
          }

          return const Center(child: Text('No data available'));
        },
      ),
    );
  }

  Widget _buildAttendanceListView(
      BuildContext context, AttendanceLoaded state) {
    return RefreshIndicator(
      onRefresh: () => _loadAttendance(),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 80),
        itemCount: state.records.length,
        itemBuilder: (context, index) {
          final record = state.records[index];
          // Show full attendance details (including check-in/out and approval buttons)
          // directly in the list item instead of using a bottom sheet.
          return _buildSelectedDayDetails(context, record);
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
        // Only show dropdown when no driver is selected
        if (state.selectedDriver == null)
          DriverDropdown(
            drivers: state.drivers,
            selectedDriver: state.selectedDriver,
            onDriverSelected: (driver) async {
              context.read<AttendanceCubit>().selectDriver(driver);
              // Load attendance for selected driver
              if (driver?.id != null) {
                final driverId = int.tryParse(driver!.id);
                await _loadAttendance(driverId: driverId);
              }
            },
          ),
        // Show selected driver info and change button when driver is selected
        if (state.selectedDriver != null)
          BlocBuilder<AttendanceCubit, AttendanceState>(
            builder: (context, currentState) {
              if (currentState is AttendanceLoaded && currentState.selectedDriver != null) {
                return _buildSelectedDriverInfo(context, currentState.selectedDriver!);
              }
              return _buildSelectedDriverInfo(context, state.selectedDriver!);
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

  Widget _buildExpatViewWithAttendance(BuildContext context, AttendanceLoaded state) {
    return Column(
      children: [
        TodaysAttendanceCard(
          onTap: () {
            // Navigate to today's attendance detail
          },
        ),
        // Show selected driver info if available
        if (state.selectedDriver != null)
          _buildSelectedDriverInfo(context, state.selectedDriver!),
        Expanded(
          child: _buildAttendanceCalendarView(context, state),
        ),
      ],
    );
  }

  Widget _buildSelectedDriverInfo(BuildContext context, Driver driver) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.shade200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.person,
            color: Colors.blue.shade700,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              driver.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade900,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () {
              // Clear selection and reload drivers to show dropdown again
              context.read<AttendanceCubit>().selectDriver(null);
              context.read<AttendanceCubit>().loadDrivers();
            },
            icon: Icon(
              Icons.change_circle,
              size: 16,
              color: Colors.blue.shade700,
            ),
            label: Text(
              'Change',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue.shade700,
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
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
              _loadAttendance();
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
    // Use the record's own date for display
    final date = DateTime(record.date.year, record.date.month, record.date.day);
    final isPresent = record.status == AttendanceStatus.present;
    final isExpat = widget.currentUser?.role == UserRole.expat;
    
    // For expat (user) login:
    // - If CheckOutTime is empty -> show Check-in approval
    // - If CheckOutTime is not empty -> show Check-out approval

    // Check if check-in needs approval (checkInTime exists but checkOutTime is null)
    final needsCheckInApproval = isExpat && 
        record.checkInTime != null && 
        record.checkOutTime == null &&
        record.attendanceId != null;
    
    // Check if check-out needs approval (checkOutTime exists)
    final needsCheckOutApproval = isExpat && 
        record.checkOutTime != null &&
        record.attendanceId != null;

    // Disable check-in approval when driver status is "checkin" or "checkin approval" (case insensitive)
    final disableCheckInApproval = _shouldDisableCheckInApproval(record);
    // Disable check-out approval when driver status is "checkout" or "checkout approval" (case insensitive)
    final disableCheckOutApproval = _shouldDisableCheckOutApproval(record);
    
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
          // Header row: Present/Absent pill (left) | Date (right)
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
                '${date.day}-${_getMonthAbbr(date.month)}-${date.year}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          // Driver name (for both driver and expat views)
          if (record.driverName.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  size: 16,
                  color: Colors.black54,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    record.driverName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          if (isPresent && record.checkInTime != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.login, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Check In: ${_formatTime(record.checkInTime!)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
            if (needsCheckInApproval) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: disableCheckInApproval ? null : () => _handleApproveCheckIn(context, record),
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('Check-in Approval'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: disableCheckInApproval ? Colors.grey : Colors.green,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade400,
                    disabledForegroundColor: Colors.white70,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
            ],
          ],
          if (isPresent && record.checkOutTime != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.logout, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Check Out: ${_formatTime(record.checkOutTime!)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
            if (needsCheckOutApproval) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: disableCheckOutApproval ? null : () => _handleApproveCheckOut(context, record),
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('Check-out Approval'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: disableCheckOutApproval ? Colors.grey : Colors.blue,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade400,
                    disabledForegroundColor: Colors.white70,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
            ],
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
  
  /// Disable check-in approval when driver status is "checkin approval" or
  /// "checkin approved" (case insensitive).
  bool _shouldDisableCheckInApproval(AttendanceRecord record) {
    final s = (record.driverStatus ?? '').trim().toLowerCase();
    return s == 'checkin approval' || s == 'checkin approved';
  }

  /// Disable check-out approval when driver status is "checkout approval" or
  /// "checkout approved" (case insensitive).
  bool _shouldDisableCheckOutApproval(AttendanceRecord record) {
    final s = (record.driverStatus ?? '').trim().toLowerCase();
    return s == 'checkout approval' || s == 'checkout approved';
  }

  Future<void> _handleApproveCheckIn(BuildContext context, AttendanceRecord record) async {
    if (record.attendanceId == null) return;
    
    try {
      // Ask for remark before approval
      final remark = await _showApprovalRemarkDialog(
        context,
        title: 'Check-in Approval',
      );
      // If user cancelled the dialog, do nothing.
      if (remark == null) {
        return;
      }
      if (remark.trim().isEmpty) {
        Toast.showError(context, 'Please enter a remark for approval.');
        return;
      }

      final localStorage = di.sl<LocalStorageDataSource>();
      final useridString = await localStorage.getUserId();
      final userId = useridString != null ? int.tryParse(useridString) : null;
      
      if (userId == null) {
        Toast.showError(context, 'User ID not found. Please login again.');
        return;
      }
      
      context.read<AttendanceCubit>().approveCheckIn(
        attendanceId: record.attendanceId!,
        userId: userId,
        remark: remark.trim(),
      );
    } catch (e) {
      Toast.showError(context, 'Failed to approve check-in: $e');
    }
  }
  
  Future<void> _handleApproveCheckOut(BuildContext context, AttendanceRecord record) async {
    if (record.attendanceId == null) return;
    
    try {
      // Ask for remark before approval
      final remark = await _showApprovalRemarkDialog(
        context,
        title: 'Check-out Approval',
      );
      // If user cancelled the dialog, do nothing.
      if (remark == null) {
        return;
      }
      if (remark.trim().isEmpty) {
        Toast.showError(context, 'Please enter a remark for approval.');
        return;
      }

      final localStorage = di.sl<LocalStorageDataSource>();
      final useridString = await localStorage.getUserId();
      final userId = useridString != null ? int.tryParse(useridString) : null;
      
      if (userId == null) {
        Toast.showError(context, 'User ID not found. Please login again.');
        return;
      }
      
      context.read<AttendanceCubit>().approveCheckOut(
        attendanceId: record.attendanceId!,
        userId: userId,
        remark: remark.trim(),
      );
    } catch (e) {
      Toast.showError(context, 'Failed to approve check-out: $e');
    }
  }

  Future<String?> _showApprovalRemarkDialog(
    BuildContext context, {
    required String title,
  }) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            maxLines: 3,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Remark *',
              hintText: 'Enter remark',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, null),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, controller.text);
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
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

