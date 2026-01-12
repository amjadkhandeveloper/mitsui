import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/toast.dart';
import '../../../login/domain/entities/user.dart';
import '../cubit/attendance_cubit.dart';
import '../widgets/todays_attendance_card.dart';
import '../widgets/driver_dropdown.dart';
import '../widgets/attendance_list_item.dart';

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
  @override
  void initState() {
    super.initState();
    final cubit = context.read<AttendanceCubit>();
    
    // Load drivers if user is expat
    if (widget.currentUser?.role == UserRole.expat) {
      cubit.loadDrivers();
    } else {
      // Load attendance for driver directly
      cubit.loadAttendanceRecords(
        driverId: widget.currentUser?.id,
      );
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
            return _buildAttendanceListView(context, state);
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
            context.read<AttendanceCubit>().loadAttendanceRecords(
                  driverId: driver?.id,
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
                return _buildAttendanceListView(context, state);
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

  Widget _buildAttendanceListView(BuildContext context, AttendanceLoaded state) {
    if (state.records.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: Colors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No attendance records found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // List Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 100,
                child: Text(
                  'Date',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Name',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 60,
                child: Text(
                  'Present',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        // Attendance List
        Expanded(
          child: ListView.builder(
            itemCount: state.records.length,
            itemBuilder: (context, index) {
              return AttendanceListItem(
                record: state.records[index],
                index: index,
              );
            },
          ),
        ),
      ],
    );
  }
}

