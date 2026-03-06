import '../../../../core/utils/result.dart';
import '../entities/trip.dart';
import '../repositories/vehicle_schedule_repository.dart';

class GetTripsUseCase {
  final VehicleScheduleRepository repository;

  GetTripsUseCase({required this.repository});

  FutureResult<List<Trip>> call({
    String? userId,
    String? driverId,
    DateTime? date,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await repository.getTrips(
      userId: userId,
      driverId: driverId,
      date: date,
      startDate: startDate,
      endDate: endDate,
    );
  }
}

