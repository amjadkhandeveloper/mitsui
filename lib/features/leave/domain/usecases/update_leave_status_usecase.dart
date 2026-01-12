import '../../../../core/utils/result.dart';
import '../entities/leave_request.dart';
import '../repositories/leave_repository.dart';

class UpdateLeaveStatusUseCase {
  final LeaveRepository repository;

  UpdateLeaveStatusUseCase({required this.repository});

  FutureResult<LeaveRequest> call(
    String leaveId,
    LeaveStatus status,
    String? adminNote,
  ) async {
    return await repository.updateLeaveStatus(leaveId, status, adminNote);
  }
}

