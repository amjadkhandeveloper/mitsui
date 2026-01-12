import 'package:equatable/equatable.dart';

class FreeSlot extends Equatable {
  final String id;
  final String vehicleId;
  final String vehicleName;
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;
  final String? notes;
  final DateTime createdAt;

  const FreeSlot({
    required this.id,
    required this.vehicleId,
    required this.vehicleName,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.notes,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        vehicleId,
        vehicleName,
        date,
        startTime,
        endTime,
        notes,
        createdAt,
      ];
}

