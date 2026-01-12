import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/animations.dart';
import '../../../../core/utils/toast.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../login/domain/entities/user.dart';
import '../cubit/leave_cubit.dart';
import '../widgets/leave_application_header.dart';
import '../widgets/date_time_input_field.dart';

class ApplyLeaveScreen extends StatefulWidget {
  final User? currentUser;

  const ApplyLeaveScreen({
    super.key,
    this.currentUser,
  });

  @override
  State<ApplyLeaveScreen> createState() => _ApplyLeaveScreenState();
}

class _ApplyLeaveScreenState extends State<ApplyLeaveScreen> {
  DateTime? startDate;
  DateTime? endDate;
  DateTime? startTime;
  DateTime? endTime;

  bool get isValid {
    return startDate != null &&
        endDate != null &&
        startTime != null &&
        endTime != null &&
        endDate!.isAfter(startDate!) &&
        endTime!.isAfter(startTime!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Apply Leave'),
        backgroundColor: AppTheme.mitsuiDarkBlue,
        elevation: 0,
      ),
      body: BlocConsumer<LeaveCubit, LeaveState>(
        listener: (context, state) {
          if (state is LeaveSubmitted) {
            Toast.showSuccess(context, 'Leave request submitted successfully');
            Navigator.of(context).pop();
          } else if (state is LeaveError) {
            Toast.showError(context, state.message);
          }
        },
        builder: (context, state) {
          final isSubmitting = state is LeaveSubmitting;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const LeaveApplicationHeader(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Leave Period Section
                      FadeSlideAnimation(
                        delay: const Duration(milliseconds: 200),
                        beginOffset: const Offset(0, 0.2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Leave Period',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            const SizedBox(height: 12),
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
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Leave Time Section
                      FadeSlideAnimation(
                        delay: const Duration(milliseconds: 300),
                        beginOffset: const Offset(0, 0.2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Leave Time',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            const SizedBox(height: 12),
                            DateTimeInputField(
                              label: 'Start Time*',
                              value: startTime,
                              isDate: false,
                              onTap: (time) {
                                setState(() {
                                  startTime = time;
                                  if (endTime != null && endTime!.isBefore(time)) {
                                    endTime = null;
                                  }
                                });
                              },
                            ),
                            DateTimeInputField(
                              label: 'End Time*',
                              value: endTime,
                              isDate: false,
                              onTap: (time) {
                                if (startTime != null && time.isBefore(startTime!)) {
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
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Action Buttons
                      FadeSlideAnimation(
                        delay: const Duration(milliseconds: 400),
                        beginOffset: const Offset(0, 0.2),
                        child: Row(
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
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade700,
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
                                        _submitLeaveRequest();
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
                                              AlwaysStoppedAnimation<Color>(Colors.white),
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

  void _submitLeaveRequest() {
    if (widget.currentUser == null) {
      Toast.showError(context, 'User information not available');
      return;
    }

    final leaveData = {
      'user_id': widget.currentUser!.id,
      'user_name': widget.currentUser!.name ?? widget.currentUser!.username,
      'start_date': startDate!.toIso8601String(),
      'end_date': endDate!.toIso8601String(),
      'start_time': startTime!.toIso8601String(),
      'end_time': endTime!.toIso8601String(),
    };

    context.read<LeaveCubit>().submitLeaveRequest(leaveData);
  }
}

