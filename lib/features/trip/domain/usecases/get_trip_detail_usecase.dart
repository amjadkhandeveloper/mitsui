import '../../../../core/utils/result.dart';
import '../entities/trip_detail.dart';
import '../repositories/trip_repository.dart';

class GetTripDetailUseCase {
  final TripRepository repository;

  GetTripDetailUseCase({required this.repository});

  FutureResult<TripDetail> call(String tripId) async {
    return await repository.getTripDetail(tripId);
  }
}

