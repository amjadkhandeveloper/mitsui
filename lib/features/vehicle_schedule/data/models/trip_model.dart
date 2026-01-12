import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/trip.dart';

part 'trip_model.g.dart';

class TripStatusConverter implements JsonConverter<TripStatus, String> {
  const TripStatusConverter();

  @override
  TripStatus fromJson(String json) {
    switch (json.toLowerCase()) {
      case 'pending':
        return TripStatus.pending;
      case 'accepted':
        return TripStatus.accepted;
      case 'rejected':
        return TripStatus.rejected;
      default:
        return TripStatus.pending;
    }
  }

  @override
  String toJson(TripStatus object) {
    switch (object) {
      case TripStatus.pending:
        return 'pending';
      case TripStatus.accepted:
        return 'accepted';
      case TripStatus.rejected:
        return 'rejected';
    }
  }
}

@JsonSerializable(
  converters: [TripStatusConverter()],
)
class TripModel extends Trip {
  const TripModel({
    required super.id,
    required super.vehicleId,
    required super.vehicleName,
    required super.date,
    required super.startTime,
    required super.endTime,
    required super.status,
    super.driverId,
    super.driverName,
    super.destination,
    super.purpose,
    required super.createdAt,
    super.updatedAt,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) =>
      _$TripModelFromJson(json);

  Map<String, dynamic> toJson() => _$TripModelToJson(this);

  Trip toEntity() {
    return Trip(
      id: id,
      vehicleId: vehicleId,
      vehicleName: vehicleName,
      date: date,
      startTime: startTime,
      endTime: endTime,
      status: status,
      driverId: driverId,
      driverName: driverName,
      destination: destination,
      purpose: purpose,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

