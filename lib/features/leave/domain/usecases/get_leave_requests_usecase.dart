import '../../../../core/utils/result.dart';
import '../entities/leave_request.dart';
import '../repositories/leave_repository.dart';

class GetLeaveRequestsUseCase {
  final LeaveRepository repository;

  GetLeaveRequestsUseCase({required this.repository});

  FutureResult<List<LeaveRequest>> call({String? userId}) async {
    return await repository.getLeaveRequests(userId: userId);
  }
}

