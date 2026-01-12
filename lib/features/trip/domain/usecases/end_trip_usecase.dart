import '../../../../core/utils/result.dart';
import '../entities/trip_detail.dart';
import '../repositories/trip_repository.dart';

class EndTripUseCase {
  final TripRepository repository;

  EndTripUseCase({required this.repository});

  FutureResult<TripDetail> call(String tripId, int endOdometer) async {
    return await repository.endTrip(tripId, endOdometer);
  }
}

