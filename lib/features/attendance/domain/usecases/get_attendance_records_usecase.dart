import '../../../../core/utils/result.dart';
import '../entities/attendance_record.dart';
import '../repositories/attendance_repository.dart';

class GetAttendanceRecordsUseCase {
  final AttendanceRepository repository;

  GetAttendanceRecordsUseCase({required this.repository});

  FutureResult<List<AttendanceRecord>> call({
    required int? driverId,
    required int? userId,
  }) async {
    return await repository.getAttendanceRecords(
      driverId: driverId,
      userId: userId,
    );
  }
}

