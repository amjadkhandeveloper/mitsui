import '../../../../core/utils/result.dart';
import '../entities/trip.dart';
import '../entities/free_slot.dart';

abstract class VehicleScheduleRepository {
  FutureResult<List<Trip>> getTrips({
    DateTime? date,
    DateTime? startDate,
    DateTime? endDate,
  });
  FutureResult<Trip> updateTripStatus(String tripId, TripStatus status);
  FutureResult<FreeSlot> createFreeSlot(Map<String, dynamic> slotData);
  FutureResult<List<FreeSlot>> getFreeSlots({DateTime? date});
}

