import '../../../../core/utils/result.dart';
import '../entities/leave_request.dart';

abstract class LeaveRepository {
  FutureResult<List<LeaveRequest>> getLeaveRequests({String? userId});
  FutureResult<LeaveRequest> applyLeave(Map<String, dynamic> leaveData);
  FutureResult<LeaveRequest> updateLeaveStatus(
    String leaveId,
    LeaveStatus status,
    String? adminNote,
  );
}

