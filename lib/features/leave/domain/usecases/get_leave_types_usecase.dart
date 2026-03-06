import '../../../../core/utils/result.dart';
import '../entities/leave_type.dart';
import '../repositories/leave_repository.dart';

class GetLeaveTypesUseCase {
  final LeaveRepository repository;

  GetLeaveTypesUseCase({required this.repository});

  FutureResult<List<LeaveTypeEntity>> call() async {
    return await repository.getLeaveTypes();
  }
}

