import '../../../../core/utils/result.dart';
import '../entities/trip.dart';
import '../repositories/vehicle_schedule_repository.dart';

class GetTripsUseCase {
  final VehicleScheduleRepository repository;

  GetTripsUseCase({required this.repository});

  FutureResult<List<Trip>> call({
    DateTime? date,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await repository.getTrips(
      date: date,
      startDate: startDate,
      endDate: endDate,
    );
  }
}

