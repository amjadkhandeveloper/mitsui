import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/free_slot.dart';

part 'free_slot_model.g.dart';

@JsonSerializable()
class FreeSlotModel extends FreeSlot {
  const FreeSlotModel({
    required super.id,
    required super.vehicleId,
    required super.vehicleName,
    required super.date,
    required super.startTime,
    required super.endTime,
    super.notes,
    required super.createdAt,
  });

  factory FreeSlotModel.fromJson(Map<String, dynamic> json) =>
      _$FreeSlotModelFromJson(json);

  Map<String, dynamic> toJson() => _$FreeSlotModelToJson(this);

  FreeSlot toEntity() {
    return FreeSlot(
      id: id,
      vehicleId: vehicleId,
      vehicleName: vehicleName,
      date: date,
      startTime: startTime,
      endTime: endTime,
      notes: notes,
      createdAt: createdAt,
    );
  }
}

