import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/toast.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../login/domain/entities/user.dart';
import '../../domain/entities/leave_request.dart';
import '../cubit/leave_cubit.dart';
import '../widgets/leave_request_item.dart';
import '../../../../core/routes/app_routes.dart';

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
  @override
  void initState() {
    super.initState();
    final cubit = context.read<LeaveCubit>();
    // Load leave requests - for admin/expat show all, for driver show only their own
    final userId = widget.currentUser?.role == UserRole.expat
        ? null
        : widget.currentUser?.id;
    cubit.loadLeaveRequests(userId: userId);
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
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.applyLeave,
                arguments: widget.currentUser,
              );
            },
            tooltip: 'Apply Leave',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(
            context,
            AppRoutes.applyLeave,
            arguments: widget.currentUser,
          );
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
            Toast.showSuccess(context, 'Leave status updated successfully');
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
                        fontSize: 16,
                        color: Colors.grey.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the + button to apply for leave',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                final userId = widget.currentUser?.role == UserRole.expat
                    ? null
                    : widget.currentUser?.id;
                context.read<LeaveCubit>().loadLeaveRequests(userId: userId);
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.requests.length,
                itemBuilder: (context, index) {
                  return LeaveRequestItem(
                    request: state.requests[index],
                    index: index,
                    isAdmin: isAdmin,
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

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isRejecting ? 'Reject Leave Request' : 'Approve Leave Request'),
        content: Column(
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
              const Text('Reason (optional):'),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'Enter rejection reason...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<LeaveCubit>().updateStatus(
                    request.id,
                    status,
                    controller.text.isEmpty ? null : controller.text,
                  );
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isRejecting ? Colors.red : Colors.green,
            ),
            child: Text(isRejecting ? 'Reject' : 'Approve'),
          ),
        ],
      ),
    );
  }
}

