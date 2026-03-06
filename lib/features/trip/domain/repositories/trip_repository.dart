import '../../../../core/utils/result.dart';
import '../entities/trip_detail.dart';

abstract class TripRepository {
  FutureResult<List<TripDetail>> getTrips({
    String? userId,
    String? driverId,
    String? status,
  });
  FutureResult<TripDetail> getTripDetail(String tripId);
  FutureResult<TripDetail> startTrip(String tripId, int startOdometer);
  FutureResult<TripDetail> endTrip(String tripId, int endOdometer);
  FutureResult<void> splitTrip(String tripId, TripDetail originalTrip);
  FutureResult<String> updateVehicleApproveStatus({
    required String tripRequestId,
    required int approvedStatus, // 1 for approve, 0 for reject
    required String approvedBy, // user ID of expat
  });
  FutureResult<String> cancelTrip({
    required String tripId,
    required String userId,
    required String remarks,
  });
}

