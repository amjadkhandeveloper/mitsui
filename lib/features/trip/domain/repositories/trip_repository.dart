import '../../../../core/utils/result.dart';
import '../entities/trip_detail.dart';

abstract class TripRepository {
  FutureResult<List<TripDetail>> getTrips({String? driverId, String? status});
  FutureResult<TripDetail> getTripDetail(String tripId);
  FutureResult<TripDetail> startTrip(String tripId, int startOdometer);
  FutureResult<TripDetail> endTrip(String tripId, int endOdometer);
}

