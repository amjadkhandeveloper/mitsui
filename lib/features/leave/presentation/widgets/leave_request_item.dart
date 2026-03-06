import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/animations.dart';
import '../../../../core/widgets/styled_card.dart';
import '../../domain/entities/leave_request.dart';

class LeaveRequestItem extends StatelessWidget {
  final LeaveRequest request;
  final int index;
  final bool isAdmin;
  final Function(LeaveRequest, LeaveStatus)? onStatusUpdate;
  final String? leaveTypeLabel;

  const LeaveRequestItem({
    super.key,
    required this.request,
    required this.index,
    this.isAdmin = false,
    this.onStatusUpdate,
    this.leaveTypeLabel,
  });

  Color _getStatusColor() {
    switch (request.status) {
      case LeaveStatus.approved:
        return Colors.green;
      case LeaveStatus.rejected:
        return Colors.red;
      case LeaveStatus.pending:
        return Colors.orange;
    }
  }

  String _getStatusText() {
    switch (request.status) {
      case LeaveStatus.approved:
        return 'Approved';
      case LeaveStatus.rejected:
        return 'Rejected';
      case LeaveStatus.pending:
        return 'Pending';
    }
  }

  IconData _getStatusIcon() {
    switch (request.status) {
      case LeaveStatus.approved:
        return Icons.check_circle;
      case LeaveStatus.rejected:
        return Icons.cancel;
      case LeaveStatus.pending:
        return Icons.pending;
    }
  }

  /// Format a single DateTime as date + time.
  String _formatDateTime(DateTime dt) {
    final f = DateFormat('dd MMM yyyy, hh:mm a');
    return f.format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return FadeSlideAnimation(
      delay: Duration(milliseconds: 200 + (index * 50)),
      beginOffset: const Offset(0, 0.1),
      child: StyledCard(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Driver name (left) | Status (right)
            Row(
              children: [
                Expanded(
                  child: Text(
                    request.userName,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getStatusColor().withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getStatusIcon(),
                        size: 16,
                        color: _getStatusColor(),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _getStatusText(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _getStatusColor(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // From Date + Leave type (right side)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.schedule, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        const Text(
                          'From Date',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                            const SizedBox(height: 2),
                            Text(
                              _formatDateTime(request.startDate),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: request.leaveType == LeaveType.half
                              ? Colors.orange.shade100
                              : Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          leaveTypeLabel ??
                              (request.leaveType == LeaveType.half
                                  ? 'Half Day'
                                  : 'Full Day'),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: request.leaveType == LeaveType.half
                                ? Colors.orange.shade700
                                : Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // To Date
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.schedule, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'To Date',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatDateTime(request.endDate),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Reason (if present)
            if (request.reason != null && request.reason!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reason',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          request.reason!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            // Remark with icon (if present)
            if (request.remark != null && request.remark!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.comment_outlined, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Remark',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          request.remark!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            // Document with icon (if present)
            if (request.documentUrl != null && request.documentUrl!.isNotEmpty) ...[
              const SizedBox(height: 8),
              InkWell(
                onTap: () {
                  // Optionally open URL in browser or in-app
                  // launchUrl(Uri.parse(request.documentUrl!));
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.attach_file, size: 16, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Document',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      Icon(Icons.open_in_new, size: 14, color: Theme.of(context).colorScheme.primary),
                    ],
                  ),
                ),
              ),
            ],
            if (isAdmin && request.status == LeaveStatus.pending) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        onStatusUpdate?.call(request, LeaveStatus.approved);
                      },
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text(
                        'Approve',
                        style: TextStyle(fontSize: 12),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green.shade700,
                        side: BorderSide(color: Colors.green.shade300),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        onStatusUpdate?.call(request, LeaveStatus.rejected);
                      },
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text(
                        'Reject',
                        style: TextStyle(fontSize: 12),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red.shade700,
                        side: BorderSide(color: Colors.red.shade300),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
