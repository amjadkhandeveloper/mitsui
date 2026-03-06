import '../../../../core/utils/result.dart';
import '../repositories/attendance_repository.dart';

class ApproveCheckInUseCase {
  final AttendanceRepository repository;

  ApproveCheckInUseCase({required this.repository});

  FutureResult<void> call({
    required int attendanceId,
    required int userId,
    required String remark,
  }) async {
    return await repository.approveCheckIn(
      attendanceId: attendanceId,
      userId: userId,
      remark: remark,
    );
  }
}

