import 'package:equatable/equatable.dart';

enum LeaveStatus { pending, approved, rejected }

class LeaveRequest extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime startTime;
  final DateTime endTime;
  final LeaveStatus status;
  final String? reason;
  final String? adminNote;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const LeaveRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.reason,
    this.adminNote,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        userName,
        startDate,
        endDate,
        startTime,
        endTime,
        status,
        reason,
        adminNote,
        createdAt,
        updatedAt,
      ];
}

