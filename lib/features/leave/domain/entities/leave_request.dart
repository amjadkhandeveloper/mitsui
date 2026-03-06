import 'package:equatable/equatable.dart';

enum LeaveStatus { pending, approved, rejected }

enum LeaveType { half, full }

class LeaveRequest extends Equatable {
  final String id;
  final String userId;
  final String userName;
  // Parsed date/time values used for logic & formatting
  final DateTime startDate;
  final DateTime endDate;
  final DateTime startTime;
  final DateTime endTime;
  // Leave type mapping (from LeaveTypeId in API)
  final int? leaveTypeId;
  // Raw values from API (for leave list display without conversion)
  final String? rawLeaveDate;
  final String? rawStartTime;
  final String? rawEndTime;
  final LeaveStatus status;
  final LeaveType leaveType;
  final String? reason;
  final String? remark;
  final String? adminNote;
  /// Document/attachment URL if provided by API (e.g. Document, DocumentUrl).
  final String? documentUrl;
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
    this.leaveTypeId,
    this.rawLeaveDate,
    this.rawStartTime,
    this.rawEndTime,
    required this.status,
    this.leaveType = LeaveType.full,
    this.reason,
    this.remark,
    this.adminNote,
    this.documentUrl,
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
        leaveTypeId,
        rawLeaveDate,
        rawStartTime,
        rawEndTime,
        status,
        leaveType,
        reason,
        remark,
        adminNote,
        documentUrl,
        createdAt,
        updatedAt,
      ];
}

