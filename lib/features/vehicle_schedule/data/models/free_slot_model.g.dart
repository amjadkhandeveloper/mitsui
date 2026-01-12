// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'free_slot_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FreeSlotModel _$FreeSlotModelFromJson(Map<String, dynamic> json) =>
    FreeSlotModel(
      id: json['id'] as String,
      vehicleId: json['vehicleId'] as String,
      vehicleName: json['vehicleName'] as String,
      date: DateTime.parse(json['date'] as String),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$FreeSlotModelToJson(FreeSlotModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'vehicleId': instance.vehicleId,
      'vehicleName': instance.vehicleName,
      'date': instance.date.toIso8601String(),
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime.toIso8601String(),
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
    };
