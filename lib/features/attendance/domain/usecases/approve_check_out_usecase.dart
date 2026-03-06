import '../../../../core/utils/result.dart';
import '../repositories/attendance_repository.dart';

class ApproveCheckOutUseCase {
  final AttendanceRepository repository;

  ApproveCheckOutUseCase({required this.repository});

  FutureResult<void> call({
    required int attendanceId,
    required int userId,
    required String remark,
  }) async {
    return await repository.approveCheckOut(
      attendanceId: attendanceId,
      userId: userId,
      remark: remark,
    );
  }
}

