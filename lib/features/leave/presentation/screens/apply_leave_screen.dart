import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/animations.dart';
import '../../../../core/utils/toast.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/styled_card.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../splash/data/datasources/local_storage_data_source.dart';
import '../../../login/domain/entities/user.dart';
import '../../domain/entities/leave_type.dart';
import '../cubit/leave_cubit.dart';
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
  LeaveTypeEntity? selectedLeaveType;
  List<LeaveTypeEntity> leaveTypes = [];
  final TextEditingController _remarkController = TextEditingController();
  bool _isSubmittingLeaveRequest = false;

  @override
  void initState() {
    super.initState();
    // Load leave types when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LeaveCubit>().loadLeaveTypes();
    });
  }

  @override
  void dispose() {
    _remarkController.dispose();
    super.dispose();
  }

  bool get isValid {
    // Only validate dates and remark - times are auto-populated
    if (startDate == null ||
        endDate == null ||
        _remarkController.text.trim().length < 2) {
      return false;
    }

    // Validate that end date is not before start date (same date is allowed for single day leave)
    if (endDate!.isBefore(startDate!)) {
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    // Allowed date range: previous 1 week to next 1 month
    final now = DateTime.now();
    final minDate = now.subtract(const Duration(days: 7));
    final maxDate = now.add(const Duration(days: 30));

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Apply Leave'),
        backgroundColor: AppTheme.mitsuiDarkBlue,
        elevation: 0,
      ),
      body: BlocConsumer<LeaveCubit, LeaveState>(
        listener: (context, state) {
          if (state is LeaveSubmitted) {
            _isSubmittingLeaveRequest = false;
            Toast.showSuccess(context, state.message);
            Navigator.of(context).pop(true);
          } else if (state is LeaveError) {
            // Always show submit errors (ex: "Leave already exists...").
            // For leave-type loading errors, show only when we don't have any types yet.
            if (_isSubmittingLeaveRequest) {
              _isSubmittingLeaveRequest = false;
              Toast.showError(context, state.message);
            } else if (leaveTypes.isEmpty) {
              Toast.showError(context, 'Failed to load leave types: ${state.message}');
            }
          } else if (state is LeaveTypesLoaded) {
            if (mounted) {
              setState(() {
                leaveTypes = state.leaveTypes;
                // Always set default selection to "full day" if available, otherwise first item
                if (leaveTypes.isNotEmpty && selectedLeaveType == null) {
                  // Try to find "full day" leave type - use the exact object from the list
                  LeaveTypeEntity? fullDayType;
                  try {
                    fullDayType = leaveTypes.firstWhere(
                      (type) => type.leaveTypeName.toLowerCase().contains('full day'),
                    );
                  } catch (e) {
                    // If not found, use first item
                    fullDayType = leaveTypes.first;
                  }
                  
                  // Set selected leave type using the exact object from the list
                  selectedLeaveType = fullDayType;
                  
                  // Auto-fill times based on leave type (same logic as onChanged)
                  final leaveTypeNameLower = fullDayType.leaveTypeName.toLowerCase();
                  final baseDate = startDate ?? DateTime.now();
                  
                  if (leaveTypeNameLower.contains('full day')) {
                    // Full day: 9:00 AM to 6:00 PM
                    startTime = DateTime(baseDate.year, baseDate.month, baseDate.day, 9, 0);
                    endTime = DateTime(baseDate.year, baseDate.month, baseDate.day, 18, 0);
                  } else if (leaveTypeNameLower.contains('first half')) {
                    // First half: 9:00 AM to 1:00 PM
                    startTime = DateTime(baseDate.year, baseDate.month, baseDate.day, 9, 0);
                    endTime = DateTime(baseDate.year, baseDate.month, baseDate.day, 13, 0);
                  } else if (leaveTypeNameLower.contains('second half')) {
                    // Second half: 2:00 PM to 6:00 PM
                    startTime = DateTime(baseDate.year, baseDate.month, baseDate.day, 14, 0);
                    endTime = DateTime(baseDate.year, baseDate.month, baseDate.day, 18, 0);
                  }
                  
                }
              });
            }
          }
        },
        builder: (context, state) {
          final isSubmitting = state is LeaveSubmitting;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
              child: Column(
                children: [
                  // Leave Type Card (moved to top)
                  FadeSlideAnimation(
                    delay: const Duration(milliseconds: 100),
                    beginOffset: const Offset(0, 0.15),
                    child: StyledCard(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Leave Type',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.mitsuiDarkBlue,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Choose the type of leave you want to apply for.',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            child: (state is LeaveLoading && leaveTypes.isEmpty)
                                ? const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Text(
                                          'Loading leave types...',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : DropdownButtonFormField<LeaveTypeEntity>(
                              key: ValueKey('leave_type_${selectedLeaveType?.leaveTypeId ?? 'none'}_${leaveTypes.length}'),
                              value: selectedLeaveType,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                hintText: leaveTypes.isEmpty 
                                    ? 'No leave types available' 
                                    : 'Select Leave Type',
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                ),
                              ),
                              items: leaveTypes.isEmpty
                                  ? []
                                  : leaveTypes.map((leaveType) {
                                      return DropdownMenuItem<LeaveTypeEntity>(
                                        value: leaveType,
                                        child: Text(
                                          leaveType.leaveTypeName,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade800,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                              onChanged: leaveTypes.isEmpty
                                  ? null
                                  : (LeaveTypeEntity? value) {
                                      if (value != null) {
                                        setState(() {
                                          selectedLeaveType = value;
                                          final leaveTypeNameLower = value.leaveTypeName.toLowerCase();
                                          
                                          // Use selected start date if available, otherwise use today
                                          final baseDate = startDate ?? DateTime.now();
                                          
                                          // Auto-fill times based on leave type
                                          if (leaveTypeNameLower.contains('full day')) {
                                            // Full day: 9:00 AM to 6:00 PM
                                            startTime = DateTime(
                                              baseDate.year,
                                              baseDate.month,
                                              baseDate.day,
                                              9,
                                              0,
                                            );
                                            endTime = DateTime(
                                              baseDate.year,
                                              baseDate.month,
                                              baseDate.day,
                                              18,
                                              0,
                                            );
                                          } else if (leaveTypeNameLower.contains('first half')) {
                                            // First half: 9:00 AM to 1:00 PM
                                            startTime = DateTime(
                                              baseDate.year,
                                              baseDate.month,
                                              baseDate.day,
                                              9,
                                              0,
                                            );
                                            endTime = DateTime(
                                              baseDate.year,
                                              baseDate.month,
                                              baseDate.day,
                                              13,
                                              0,
                                            );
                                          } else if (leaveTypeNameLower.contains('second half')) {
                                            // Second half: 2:00 PM to 6:00 PM
                                            startTime = DateTime(
                                              baseDate.year,
                                              baseDate.month,
                                              baseDate.day,
                                              14,
                                              0,
                                            );
                                            endTime = DateTime(
                                              baseDate.year,
                                              baseDate.month,
                                              baseDate.day,
                                              18,
                                              0,
                                            );
                                          }
                                        });
                                      }
                                    },
                              isExpanded: true,
                              isDense: false,
                              icon: Icon(
                                Icons.arrow_drop_down,
                                color: Colors.grey.shade600,
                              ),
                              dropdownColor: Colors.white,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade800,
                              ),
                              menuMaxHeight: 250,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Leave Details Card
                  FadeSlideAnimation(
                    delay: const Duration(milliseconds: 150),
                    beginOffset: const Offset(0, 0.15),
                    child: StyledCard(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Leave Details',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.mitsuiDarkBlue,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Select the period and time for your leave.',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Leave Period Row
                          Row(
                            children: [
                              Expanded(
                                child: DateTimeInputField(
                                  label: 'Start Date*',
                                  value: startDate,
                                  isDate: true,
                                  minDate: minDate,
                                  maxDate: maxDate,
                                  onTap: (date) {
                                    setState(() {
                                      startDate = date;
                                      if (endDate != null && endDate!.isBefore(date)) {
                                        endDate = null;
                                      }
                                      // Always auto-fill times based on selected leave type when date is selected
                                      if (selectedLeaveType != null) {
                                        final leaveTypeNameLower = selectedLeaveType!.leaveTypeName.toLowerCase();
                                        if (leaveTypeNameLower.contains('full day')) {
                                          startTime = DateTime(date.year, date.month, date.day, 9, 0);
                                          endTime = DateTime(date.year, date.month, date.day, 18, 0);
                                        } else if (leaveTypeNameLower.contains('first half')) {
                                          startTime = DateTime(date.year, date.month, date.day, 9, 0);
                                          endTime = DateTime(date.year, date.month, date.day, 13, 0);
                                        } else if (leaveTypeNameLower.contains('second half')) {
                                          startTime = DateTime(date.year, date.month, date.day, 14, 0);
                                          endTime = DateTime(date.year, date.month, date.day, 18, 0);
                                        }
                                      }
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: DateTimeInputField(
                                  label: 'End Date*',
                                  value: endDate,
                                  isDate: true,
                                  minDate: minDate,
                                  maxDate: maxDate,
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
                                      // Update times if leave type is selected
                                      if (selectedLeaveType != null && startDate != null) {
                                        final leaveTypeNameLower = selectedLeaveType!.leaveTypeName.toLowerCase();
                                        // Update times based on leave type using the selected start date
                                        if (leaveTypeNameLower.contains('full day')) {
                                          startTime = DateTime(startDate!.year, startDate!.month, startDate!.day, 9, 0);
                                          endTime = DateTime(date.year, date.month, date.day, 18, 0);
                                        } else if (leaveTypeNameLower.contains('first half')) {
                                          startTime = DateTime(startDate!.year, startDate!.month, startDate!.day, 9, 0);
                                          endTime = DateTime(date.year, date.month, date.day, 13, 0);
                                        } else if (leaveTypeNameLower.contains('second half')) {
                                          startTime = DateTime(startDate!.year, startDate!.month, startDate!.day, 14, 0);
                                          endTime = DateTime(date.year, date.month, date.day, 18, 0);
                                        }
                                      }
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Leave Time Row
                          Row(
                            children: [
                              Expanded(
                                child: DateTimeInputField(
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
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: DateTimeInputField(
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
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Remark Card
                  FadeSlideAnimation(
                    delay: const Duration(milliseconds: 250),
                    beginOffset: const Offset(0, 0.15),
                    child: StyledCard(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reason',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _remarkController,
                            maxLines: 3,
                            onChanged: (value) {
                              // Trigger rebuild to update submit button state
                              setState(() {});
                            },
                            decoration: InputDecoration(
                              hintText: 'Add a short reason for your leave...',
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              contentPadding: const EdgeInsets.all(12),
                              hintStyle: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade400,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppTheme.mitsuiBlue,
                                  width: 1.2,
                                ),
                              ),
                            ),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Action Buttons
                  FadeSlideAnimation(
                    delay: const Duration(milliseconds: 300),
                    beginOffset: const Offset(0, 0.15),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: isSubmitting
                                ? null
                                : () {
                                    // Explicitly return false so caller knows we cancelled
                                    Navigator.of(context).pop(false);
                                  },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1.2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 13,
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
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              backgroundColor: AppTheme.mitsuiBlue,
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
                                : Text(
                                    'Submit',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ],
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

  Future<void> _submitLeaveRequest() async {
    if (widget.currentUser == null) {
      Toast.showError(context, 'User information not available');
      return;
    }

    if (selectedLeaveType == null) {
      Toast.showError(context, 'Please select a leave type');
      return;
    }

    if (_remarkController.text.trim().length < 2) {
      Toast.showError(context, 'Please enter at least 2 characters for the reason');
      return;
    }

    // Ensure times are set (they should be auto-populated, but check for safety)
    if (startTime == null || endTime == null) {
      Toast.showError(context, 'Please select dates to auto-populate times');
      return;
    }

    // Combine date and time into full DateTime objects as per API spec
    final fromDateTime = DateTime(
      startDate!.year,
      startDate!.month,
      startDate!.day,
      startTime!.hour,
      startTime!.minute,
    );

    final toDateTime = DateTime(
      endDate!.year,
      endDate!.month,
      endDate!.day,
      endTime!.hour,
      endTime!.minute,
    );

    if (!toDateTime.isAfter(fromDateTime)) {
      Toast.showError(
        context,
        'End date & time must be after start date & time',
      );
      return;
    }

    final diffMinutes = toDateTime.difference(fromDateTime).inMinutes;
    if (diffMinutes < 240) {
      Toast.showError(
        context,
        'Leave duration must be at least 4 hours',
      );
      return;
    }

    // Driver / user id from logged in user
    // For driver login backend sends separate driverid; prefer that, fallback to userid
    final driverIdString = widget.currentUser!.driverId?.isNotEmpty == true
        ? widget.currentUser!.driverId!
        : widget.currentUser!.id;
    final driverId = int.tryParse(driverIdString) ?? 0; // fallback to 0 if parse fails

    // Get requestedUserId (actual user ID, not driverId)
    final requestedUserIdString = widget.currentUser!.id;
    final requestedUserId = int.tryParse(requestedUserIdString) ?? 0;

    final reason = _remarkController.text.trim();

    // Get clientId from local storage (always include, default to 0 if not available)
    final localStorage = di.sl<LocalStorageDataSource>();
    final clientId = await localStorage.getClientId() ?? 0;

    // Payload as per API specification - all fields must be included
    final leaveData = {
      'leaveRequestId': 0, // always 0 for new request
      'driverId': driverId,
      'clientId': clientId, // always include clientId
      'leaveTypeId': selectedLeaveType!.leaveTypeId,
      'leaveFromDate': fromDateTime.toIso8601String(),
      'leaveToDate': toDateTime.toIso8601String(),
      'leaveReason': reason,
      'remark': reason,
      'leaveStatus': 0,
      'requestedUserId': requestedUserId, // use actual user ID
      'approveId': 0,
      'insertMode': 1, // 1 for insert
    };

    // Mark as submitting so we show API errors even if types are already loaded.
    _isSubmittingLeaveRequest = true;
    context.read<LeaveCubit>().submitLeaveRequest(leaveData);
  }

}

