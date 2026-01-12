// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_record_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AttendanceRecordModel _$AttendanceRecordModelFromJson(
        Map<String, dynamic> json) =>
    AttendanceRecordModel(
      id: json['id'] as String,
      driverId: json['driverId'] as String,
      driverName: json['driverName'] as String,
      date: DateTime.parse(json['date'] as String),
      status:
          const AttendanceStatusConverter().fromJson(json['status'] as String),
      checkInTime: json['checkInTime'] == null
          ? null
          : DateTime.parse(json['checkInTime'] as String),
      checkOutTime: json['checkOutTime'] == null
          ? null
          : DateTime.parse(json['checkOutTime'] as String),
      location: json['location'] as String?,
    );

Map<String, dynamic> _$AttendanceRecordModelToJson(
        AttendanceRecordModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'driverId': instance.driverId,
      'driverName': instance.driverName,
      'date': instance.date.toIso8601String(),
      'status': const AttendanceStatusConverter().toJson(instance.status),
      'checkInTime': instance.checkInTime?.toIso8601String(),
      'checkOutTime': instance.checkOutTime?.toIso8601String(),
      'location': instance.location,
    };
