import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/attendance_record.dart';

part 'attendance_record_model.g.dart';

class AttendanceStatusConverter implements JsonConverter<AttendanceStatus, String> {
  const AttendanceStatusConverter();

  @override
  AttendanceStatus fromJson(String json) {
    switch (json.toLowerCase()) {
      case 'present':
        return AttendanceStatus.present;
      case 'absent':
        return AttendanceStatus.absent;
      default:
        return AttendanceStatus.absent;
    }
  }

  @override
  String toJson(AttendanceStatus object) {
    switch (object) {
      case AttendanceStatus.present:
        return 'present';
      case AttendanceStatus.absent:
        return 'absent';
    }
  }
}

@JsonSerializable(
  converters: [AttendanceStatusConverter()],
)
class AttendanceRecordModel extends AttendanceRecord {
  const AttendanceRecordModel({
    required super.id,
    required super.driverId,
    required super.driverName,
    required super.date,
    required super.status,
    super.checkInTime,
    super.checkOutTime,
    super.location,
  });

  factory AttendanceRecordModel.fromJson(Map<String, dynamic> json) =>
      _$AttendanceRecordModelFromJson(json);

  Map<String, dynamic> toJson() => _$AttendanceRecordModelToJson(this);

  AttendanceRecord toEntity() {
    return AttendanceRecord(
      id: id,
      driverId: driverId,
      driverName: driverName,
      date: date,
      status: status,
      checkInTime: checkInTime,
      checkOutTime: checkOutTime,
      location: location,
    );
  }
}

