import '../../../../core/utils/result.dart';
import '../entities/leave_request.dart';
import '../repositories/leave_repository.dart';

class ApplyLeaveUseCase {
  final LeaveRepository repository;

  ApplyLeaveUseCase({required this.repository});

  FutureResult<LeaveRequest> call(Map<String, dynamic> leaveData) async {
    return await repository.applyLeave(leaveData);
  }
}

