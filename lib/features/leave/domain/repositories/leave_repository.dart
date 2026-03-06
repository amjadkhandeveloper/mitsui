import '../../../../core/utils/result.dart';
import '../entities/leave_request.dart';
import '../entities/leave_type.dart';

abstract class LeaveRepository {
  FutureResult<List<LeaveRequest>> getLeaveRequests({String? userId, String? driverId});
  FutureResult<String> applyLeave(Map<String, dynamic> leaveData);
  FutureResult<String> updateLeaveStatus({
    required LeaveRequest request,
    required LeaveStatus status,
    required String currentUserId,
    String? remark,
    int? clientId,
  });
  FutureResult<List<LeaveTypeEntity>> getLeaveTypes();
}

