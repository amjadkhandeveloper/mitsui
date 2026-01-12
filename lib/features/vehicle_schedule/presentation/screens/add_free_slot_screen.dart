import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/toast.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../leave/presentation/widgets/date_time_input_field.dart';
import '../cubit/vehicle_schedule_cubit.dart';
import '../widgets/add_free_slot_header.dart';
import '../widgets/time_input_field.dart';
import '../../../login/domain/repositories/auth_repository.dart';
import '../../../../core/di/injection_container.dart' as di;

class AddFreeSlotScreen extends StatefulWidget {
  const AddFreeSlotScreen({super.key});

  @override
  State<AddFreeSlotScreen> createState() => _AddFreeSlotScreenState();
}

class _AddFreeSlotScreenState extends State<AddFreeSlotScreen> {
  DateTime? startDate;
  DateTime? endDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  String? vehicleId;
  String? vehicleName;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final authRepository = di.sl<AuthRepository>();
    final result = await authRepository.getCurrentUser();
    result.fold(
      (failure) => null,
      (user) {
        // You can set default vehicle here if needed
      },
    );
  }

  bool get isValid {
    return startDate != null &&
        endDate != null &&
        startTime != null &&
        endTime != null &&
        endDate!.isAfter(startDate!) &&
        (endDate!.isAfter(startDate!) ||
            (endDate == startDate && endTime!.hour > startTime!.hour) ||
            (endDate == startDate &&
                endTime!.hour == startTime!.hour &&
                endTime!.minute > startTime!.minute));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Add New Free Slot'),
        backgroundColor: AppTheme.mitsuiDarkBlue,
        elevation: 0,
      ),
      body: BlocConsumer<VehicleScheduleCubit, VehicleScheduleState>(
        listener: (context, state) {
          if (state is VehicleScheduleFreeSlotCreated) {
            Toast.showSuccess(context, 'Free slot created successfully');
            Navigator.of(context).pop();
          } else if (state is VehicleScheduleError) {
            Toast.showError(context, state.message);
          }
        },
        builder: (context, state) {
          final isSubmitting = state is VehicleScheduleSubmitting;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AddFreeSlotHeader(),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Start Date Field
                      DateTimeInputField(
                        label: 'Start Date*',
                        value: startDate,
                        isDate: true,
                        onTap: (date) {
                          setState(() {
                            startDate = date;
                            if (endDate != null && endDate!.isBefore(date)) {
                              endDate = null;
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // Start Time Field
                      TimeInputField(
                        label: 'Start Time*',
                        value: startTime,
                        onTap: (time) {
                          setState(() {
                            startTime = time;
                            if (endTime != null &&
                                endDate == startDate &&
                                (time.hour > endTime!.hour ||
                                    (time.hour == endTime!.hour &&
                                        time.minute >= endTime!.minute))) {
                              endTime = null;
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // End Date Field
                      DateTimeInputField(
                        label: 'End Date*',
                        value: endDate,
                        isDate: true,
                        onTap: (date) {
                          if (startDate != null && date.isBefore(startDate!)) {
                            Toast.showError(
                              context,
                              'End date must be after start date',
                            );
                            return;
                          }
                          setState(() {
                            endDate = date;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // End Time Field
                      TimeInputField(
                        label: 'End Time*',
                        value: endTime,
                        onTap: (time) {
                          if (startTime != null &&
                              endDate == startDate &&
                              (time.hour < startTime!.hour ||
                                  (time.hour == startTime!.hour &&
                                      time.minute <= startTime!.minute))) {
                            Toast.showError(
                              context,
                              'End time must be after start time',
                            );
                            return;
                          }
                          setState(() {
                            endTime = time;
                          });
                        },
                      ),
                      const SizedBox(height: 32),
                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: isSubmitting
                                  ? null
                                  : () {
                                      Navigator.of(context).pop();
                                    },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                side: BorderSide(
                                  color: Colors.grey.shade300,
                                  width: 1.5,
                                ),
                                backgroundColor: Colors.grey.shade200,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isSubmitting || !isValid
                                  ? null
                                  : () {
                                      _submitFreeSlot();
                                    },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: Colors.green.shade600,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: isSubmitting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : const Text(
                                      'Save',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
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

  void _submitFreeSlot() {
    if (startDate == null ||
        endDate == null ||
        startTime == null ||
        endTime == null) {
      Toast.showError(context, 'Please fill all required fields');
      return;
    }

    // Combine date and time
    final startDateTime = DateTime(
      startDate!.year,
      startDate!.month,
      startDate!.day,
      startTime!.hour,
      startTime!.minute,
    );

    final endDateTime = DateTime(
      endDate!.year,
      endDate!.month,
      endDate!.day,
      endTime!.hour,
      endTime!.minute,
    );

    if (endDateTime.isBefore(startDateTime) ||
        endDateTime.isAtSameMomentAs(startDateTime)) {
      Toast.showError(
        context,
        'End date/time must be after start date/time',
      );
      return;
    }

    final slotData = {
      'vehicle_id': vehicleId ?? 'default',
      'vehicle_name': vehicleName ?? 'Vehicle',
      'date': startDate!.toIso8601String(),
      'start_time': startDateTime.toIso8601String(),
      'end_time': endDateTime.toIso8601String(),
    };

    context.read<VehicleScheduleCubit>().createFreeSlot(slotData);
  }
}
