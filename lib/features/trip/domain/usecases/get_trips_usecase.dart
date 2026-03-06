import '../../../../core/utils/result.dart';
import '../entities/trip_detail.dart';
import '../repositories/trip_repository.dart';

class GetTripDetailsUseCase {
  final TripRepository repository;

  GetTripDetailsUseCase({required this.repository});

  FutureResult<List<TripDetail>> call({
    String? userId,
    String? driverId,
    String? status,
  }) async {
    return await repository.getTrips(
      userId: userId,
      driverId: driverId,
      status: status,
    );
  }
}

