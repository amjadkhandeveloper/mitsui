import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/toast.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../splash/data/datasources/local_storage_data_source.dart';
import '../../../login/domain/repositories/auth_repository.dart';
import '../../../login/domain/entities/user.dart';
import '../../domain/entities/leave_request.dart';
import '../../domain/entities/leave_type.dart';
import '../../domain/usecases/get_leave_types_usecase.dart';
import '../cubit/leave_cubit.dart';
import '../widgets/leave_request_item.dart';
import 'apply_leave_screen.dart';

class LeaveListScreen extends StatefulWidget {
  final User? currentUser;

  const LeaveListScreen({
    super.key,
    this.currentUser,
  });

  @override
  State<LeaveListScreen> createState() => _LeaveListScreenState();
}

class _LeaveListScreenState extends State<LeaveListScreen> {
  // Map LeaveTypeId -> LeaveTypeName from master API
  Map<int, String> _leaveTypeMap = {};
  String? _storedUserId;
  String? _storedDriverId;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final cubit = context.read<LeaveCubit>();

    // Resolve ids from local storage (and fall back to AuthRepository if needed)
    String? storedUserId;
    String? storedDriverId;
    String? storedRole;
    try {
      final localStorage = di.sl<LocalStorageDataSource>();
      storedUserId = await localStorage.getUserId();
      storedDriverId = await localStorage.getDriverId();
      storedRole = await localStorage.getUserRole();

      if (storedUserId == null || storedUserId.isEmpty) {
        final authRepo = di.sl<AuthRepository>();
        final result = await authRepo.getCurrentUser();
        result.fold(
          (_) {},
          (user) {
            if (user != null) {
              storedUserId = user.id;
              storedDriverId = user.driverId;
            }
          },
        );
      }
    } catch (_) {
      // ignore, handled below
    }

    try {
      final getLeaveTypesUseCase = di.sl<GetLeaveTypesUseCase>();
      final result = await getLeaveTypesUseCase();
      result.fold(
        (failure) {
          // We can continue without types; UI will fall back to Half/Full
        },
        (types) {
          setState(() {
            _leaveTypeMap = {
              for (final LeaveTypeEntity t in types) t.leaveTypeId: t.leaveTypeName,
            };
          });
        },
      );
    } catch (_) {
      // Ignore errors here; leave list can still load
    }

    // Always load leave requests after (or in parallel with) types.
    // Driver: both driverId and userId should be the driver's ID from login
    // Expat:  driverId = 0, userId = expat's user ID from login
    final roleLower = (storedRole ?? widget.currentUser?.role.name ?? '').toLowerCase();
    final isDriver = roleLower.contains('driver');
    
    // For driver: use driverId for both driverId and userId
    // For expat: use userId for userId, and 0 for driverId
    String? finalUserId;
    String? finalDriverId;
    
    if (isDriver) {
      // Driver login: use driverId for both
      finalDriverId = (storedDriverId != null && storedDriverId!.isNotEmpty)
          ? storedDriverId
          : (widget.currentUser?.driverId);
      finalUserId = finalDriverId; // Same value for both
    } else {
      // Expat login: use userId for userId, 0 for driverId
      finalUserId = (storedUserId != null && storedUserId!.isNotEmpty)
          ? storedUserId
          : (widget.currentUser?.id);
      finalDriverId = '0';
    }
    
    // Store values for refresh
    _storedUserId = finalUserId;
    _storedDriverId = finalDriverId;

    // Load with determined values
    cubit.loadLeaveRequests(
      userId: finalUserId ?? '0',
      driverId: finalDriverId ?? '0',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.currentUser?.role == UserRole.expat;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Leave Requests'),
        backgroundColor: AppTheme.mitsuiDarkBlue,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final cubit = context.read<LeaveCubit>();
              cubit.loadLeaveRequests(
                userId: _storedUserId ?? '0',
                driverId: _storedDriverId ?? '0',
              );
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      // Only drivers can apply leave; hide FAB for expat/admin
      floatingActionButton: isAdmin
          ? null
          : FloatingActionButton.extended(
              onPressed: () async {
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) => di.sl<LeaveCubit>(),
                      child: ApplyLeaveScreen(
                        currentUser: widget.currentUser,
                      ),
                    ),
                  ),
                );

                // If a leave was submitted, reload the list
                if (result == true && mounted) {
                  final cubit = context.read<LeaveCubit>();
                  cubit.loadLeaveRequests(
                    userId: _storedUserId ?? '0',
                    driverId: _storedDriverId ?? '0',
                  );
                }
              },
              backgroundColor: AppTheme.mitsuiBlue,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Apply Leave',
                style: TextStyle(color: Colors.white),
              ),
            ),
      body: BlocConsumer<LeaveCubit, LeaveState>(
        listener: (context, state) {
          if (state is LeaveStatusUpdated) {
            // Show success message from API
            Toast.showSuccess(context, state.message);
            // Reload leave requests after status update with same parameters
            final cubit = context.read<LeaveCubit>();
            cubit.loadLeaveRequests(
              userId: _storedUserId ?? '0',
              driverId: _storedDriverId ?? '0',
            );
          } else if (state is LeaveError) {
            Toast.showError(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is LeaveLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is LeaveLoaded) {
            if (state.requests.isEmpty) {
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
                      'No leave requests found',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Use the floating button to apply for leave',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                // Reload with same parameters as initial load
                final cubit = context.read<LeaveCubit>();
                cubit.loadLeaveRequests(
                  userId: _storedUserId ?? '0',
                  driverId: _storedDriverId ?? '0',
                );
              },
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                itemCount: state.requests.length,
                itemBuilder: (context, index) {
                  final req = state.requests[index];
                  final typeLabel = req.leaveTypeId != null
                      ? _leaveTypeMap[req.leaveTypeId!]
                      : null;
                  return LeaveRequestItem(
                    request: req,
                    index: index,
                    isAdmin: isAdmin,
                    leaveTypeLabel: typeLabel,
                    onStatusUpdate: (request, status) {
                      _showStatusUpdateDialog(context, request, status);
                    },
                  );
                },
              ),
            );
          }

          return const Center(
            child: Text('No data available'),
          );
        },
      ),
    );
  }

  void _showStatusUpdateDialog(
    BuildContext context,
    LeaveRequest request,
    LeaveStatus status,
  ) {
    final controller = TextEditingController();
    final isRejecting = status == LeaveStatus.rejected;
    final formKey = GlobalKey<FormState>();
    String? errorMessage;
    // Store reference to the original context that has access to LeaveCubit
    final parentContext = context;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogStateContext, setState) => AlertDialog(
          title: Text(isRejecting ? 'Reject Leave' : 'Approve Leave Request'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Leave Request by ${request.userName}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${request.startDate.day}-${request.startDate.month}-${request.startDate.year} to ${request.endDate.day}-${request.endDate.month}-${request.endDate.year}',
                  ),
                  if (isRejecting) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text(
                          'Reason',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '*',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: 'Enter rejection reason...',
                        border: const OutlineInputBorder(),
                        errorText: errorMessage,
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (isRejecting && (value == null || value.trim().isEmpty)) {
                          return 'Rejection reason is required';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        if (errorMessage != null && value.trim().isNotEmpty) {
                          setState(() {
                            errorMessage = null;
                          });
                        }
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (isRejecting) {
                  // Validate remark for rejection
                  if (controller.text.trim().isEmpty) {
                    setState(() {
                      errorMessage = 'Rejection reason is required';
                    });
                    return;
                  }
                }

                // Validate form
                if (formKey.currentState?.validate() ?? false) {
                  final currentUser = widget.currentUser;
                  final currentUserId = currentUser?.id ?? '';
                  
                  // Get clientId from local storage
                  final localStorage = di.sl<LocalStorageDataSource>();
                  final clientId = await localStorage.getClientId();
                  
                  if (!mounted) return;
                  
                  // For approval, pass null (will use original request reason)
                  // For rejection, pass the entered remark
                  final remarkText = isRejecting 
                      ? controller.text.trim() 
                      : null;
                  
                  // Use parentContext which has access to LeaveCubit provider
                  parentContext.read<LeaveCubit>().updateStatus(
                        request,
                        status,
                        remarkText,
                        currentUserId,
                        clientId: clientId,
                      );
                  Navigator.pop(dialogContext);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isRejecting ? Colors.red : Colors.green,
              ),
              child: Text(isRejecting ? 'Reject' : 'Approve'),
            ),
          ],
        ),
      ),
    );
  }
}

