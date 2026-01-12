import '../../../../core/utils/result.dart';
import '../entities/driver.dart';
import '../repositories/attendance_repository.dart';

class GetDriversUseCase {
  final AttendanceRepository repository;

  GetDriversUseCase({required this.repository});

  FutureResult<List<Driver>> call() async {
    return await repository.getDrivers();
  }
}

