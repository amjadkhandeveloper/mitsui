import '../../../../core/utils/result.dart';
import '../entities/trip_detail.dart';
import '../repositories/trip_repository.dart';

class StartTripUseCase {
  final TripRepository repository;

  StartTripUseCase({required this.repository});

  FutureResult<TripDetail> call(String tripId, int startOdometer) async {
    return await repository.startTrip(tripId, startOdometer);
  }
}

