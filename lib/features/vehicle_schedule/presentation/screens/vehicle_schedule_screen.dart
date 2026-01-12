import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/toast.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/routes/app_routes.dart';
import '../cubit/vehicle_schedule_cubit.dart';
import '../widgets/vehicle_schedule_header.dart';
import '../widgets/schedule_calendar.dart';
import '../widgets/trip_card.dart';

class VehicleScheduleScreen extends StatefulWidget {
  const VehicleScheduleScreen({super.key});

  @override
  State<VehicleScheduleScreen> createState() => _VehicleScheduleScreenState();
}

class _VehicleScheduleScreenState extends State<VehicleScheduleScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  final Set<DateTime> _markedDates = {};

  @override
  void initState() {
    super.initState();
    // Load trips for today
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VehicleScheduleCubit>().selectDate(_selectedDay);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Vehicle Schedule'),
        backgroundColor: AppTheme.mitsuiDarkBlue,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.addFreeSlot);
            },
            tooltip: 'Add Free Slot',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.addFreeSlot);
        },
        backgroundColor: AppTheme.mitsuiBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Free Slot',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: BlocConsumer<VehicleScheduleCubit, VehicleScheduleState>(
        listener: (context, state) {
          if (state is VehicleScheduleError) {
            Toast.showError(context, state.message);
          } else if (state is VehicleScheduleFreeSlotCreated) {
            Toast.showSuccess(context, 'Free slot created successfully');
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const VehicleScheduleHeader(),
                ScheduleCalendar(
                  selectedDate: _selectedDay,
                  focusedDay: _focusedDay,
                  markedDates: _markedDates,
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                    context.read<VehicleScheduleCubit>().selectDate(selectedDay);
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Upcoming Trips',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (state is VehicleScheduleLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (state is VehicleScheduleLoaded)
                        state.trips.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(32.0),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.event_busy,
                                        size: 64,
                                        color: Colors.grey.withOpacity(0.5),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No trips scheduled for this date',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey.withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: state.trips.length,
                                itemBuilder: (context, index) {
                                  return TripCard(
                                    trip: state.trips[index],
                                    index: index,
                                    onStatusUpdate: (trip, status) {
                                      context
                                          .read<VehicleScheduleCubit>()
                                          .updateStatus(trip.id, status);
                                    },
                                  );
                                },
                              )
                      else
                        const SizedBox.shrink(),
                      const SizedBox(height: 100), // Space for FAB
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

