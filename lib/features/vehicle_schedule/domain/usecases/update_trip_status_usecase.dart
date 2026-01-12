import '../../../../core/utils/result.dart';
import '../entities/trip.dart';
import '../repositories/vehicle_schedule_repository.dart';

class UpdateTripStatusUseCase {
  final VehicleScheduleRepository repository;

  UpdateTripStatusUseCase({required this.repository});

  FutureResult<Trip> call(String tripId, TripStatus status) async {
    return await repository.updateTripStatus(tripId, status);
  }
}

