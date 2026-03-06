import '../../../../core/utils/result.dart';
import '../entities/leave_request.dart';
import '../repositories/leave_repository.dart';

class UpdateLeaveStatusUseCase {
  final LeaveRepository repository;

  UpdateLeaveStatusUseCase({required this.repository});

  FutureResult<String> call({
    required LeaveRequest request,
    required LeaveStatus status,
    required String currentUserId,
    String? remark,
    int? clientId,
  }) async {
    return await repository.updateLeaveStatus(
      request: request,
      status: status,
      currentUserId: currentUserId,
      remark: remark,
      clientId: clientId,
    );
  }
}

