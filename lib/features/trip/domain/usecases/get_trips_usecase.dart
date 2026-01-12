import '../../../../core/utils/result.dart';
import '../entities/trip_detail.dart';
import '../repositories/trip_repository.dart';

class GetTripDetailsUseCase {
  final TripRepository repository;

  GetTripDetailsUseCase({required this.repository});

  FutureResult<List<TripDetail>> call({String? driverId, String? status}) async {
    return await repository.getTrips(driverId: driverId, status: status);
  }
}

