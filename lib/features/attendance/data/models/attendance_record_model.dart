import '../../domain/entities/attendance_record.dart';
import '../../../../core/extensions/json_extensions.dart';

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
    super.attendanceId,
    super.clientName,
    super.zoneName,
    super.checkInLat,
    super.checkInLon,
    super.checkOutLat,
    super.checkOutLon,
    super.driverStatus,
  });

  factory AttendanceRecordModel.fromJson(Map<String, dynamic> json) {
    // Use extension methods to safely handle empty objects {}
    // Extension methods are available directly on Map<String, dynamic>
    
    // Map API response fields to model fields
    final attendanceId = json.getIntSafe('AttendanceId') ?? json['attendanceId'] as int?;
    final id = attendanceId?.toString() ?? json.getStringSafe('id') ?? '';
    // Backend may send: "Driver Name", "DriverName", or "driverName"
    final driverName = json.getStringSafe('DriverName') ??
        json.getStringSafe('driverName') ??
        (json['Driver Name'] != null ? json['Driver Name'].toString() : '');
    final attendanceDate = json.getStringSafe('AttendanceDate') ?? 
                           json.getStringSafe('date');
    
    // Handle CheckInTime - can be string or empty object {}
    DateTime? checkInTime;
    final checkInTimeValue = json['CheckInTime'];
    if (checkInTimeValue != null && 
        !(checkInTimeValue is Map && checkInTimeValue.isEmpty)) {
      if (checkInTimeValue is String) {
        try {
          checkInTime = DateTime.parse(checkInTimeValue);
        } catch (_) {
          checkInTime = null;
        }
      }
    }
    
    // Handle CheckOutTime - can be string or empty object {}
    DateTime? checkOutTime;
    final checkOutTimeValue = json['CheckOutTime'];
    if (checkOutTimeValue != null && 
        !(checkOutTimeValue is Map && checkOutTimeValue.isEmpty)) {
      if (checkOutTimeValue is String) {
        try {
          checkOutTime = DateTime.parse(checkOutTimeValue);
        } catch (_) {
          checkOutTime = null;
        }
      }
    }
    
    final driverId = json.getStringSafe('driverId') ?? 
                     json.getIntSafe('DriverId')?.toString();
    
    // Determine status based on check-in/check-out
    final status = (checkInTime != null) ? AttendanceStatus.present : AttendanceStatus.absent;
    
    // Handle CheckInLat, CheckInLon - can be number or empty object {}
    final checkInLat = json.getDoubleSafeOrEmptyObject('CheckInLat') ?? 
                       json.getDoubleSafe('checkInLat');
    final checkInLon = json.getDoubleSafeOrEmptyObject('CheckInLon') ?? 
                        json.getDoubleSafe('checkInLon');
    
    // Handle CheckOutLat, CheckOutLon - can be number or empty object {}
    final checkOutLat = json.getDoubleSafeOrEmptyObject('CheckOutLat') ?? 
                        json.getDoubleSafe('checkOutLat');
    final checkOutLon = json.getDoubleSafeOrEmptyObject('CheckOutLon') ?? 
                        json.getDoubleSafe('checkOutLon');
    
    return AttendanceRecordModel(
      id: id,
      driverId: driverId ?? '',
      driverName: driverName,
      date: attendanceDate != null ? DateTime.parse(attendanceDate) : DateTime.now(),
      status: status,
      checkInTime: checkInTime,
      checkOutTime: checkOutTime,
      location: json.getStringSafe('location'),
      attendanceId: attendanceId,
      clientName: json.getStringSafe('ClientName') ?? json.getStringSafe('clientName'),
      zoneName: json.getStringSafe('ZoneName') ?? json.getStringSafe('zoneName'),
      checkInLat: checkInLat,
      checkInLon: checkInLon,
      checkOutLat: checkOutLat,
      checkOutLon: checkOutLon,
      driverStatus: json.getStringSafe('Driver Status') ?? json.getStringSafe('driverStatus'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driverId': driverId,
      'driverName': driverName,
      'date': date.toIso8601String(),
      'status': status == AttendanceStatus.present ? 'present' : 'absent',
      'checkInTime': checkInTime?.toIso8601String(),
      'checkOutTime': checkOutTime?.toIso8601String(),
      'location': location,
      'attendanceId': attendanceId,
      'clientName': clientName,
      'zoneName': zoneName,
      'checkInLat': checkInLat,
      'checkInLon': checkInLon,
      'checkOutLat': checkOutLat,
      'checkOutLon': checkOutLon,
      'driverStatus': driverStatus,
    };
  }

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
      attendanceId: attendanceId,
      clientName: clientName,
      zoneName: zoneName,
      checkInLat: checkInLat,
      checkInLon: checkInLon,
      checkOutLat: checkOutLat,
      checkOutLon: checkOutLon,
      driverStatus: driverStatus,
    );
  }
}

