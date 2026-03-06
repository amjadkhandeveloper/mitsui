import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/leave_request.dart';

part 'leave_request_model.g.dart';

class LeaveStatusConverter implements JsonConverter<LeaveStatus, String> {
  const LeaveStatusConverter();

  @override
  LeaveStatus fromJson(String json) {
    switch (json.toLowerCase()) {
      case 'pending':
        return LeaveStatus.pending;
      case 'approved':
        return LeaveStatus.approved;
      case 'rejected':
        return LeaveStatus.rejected;
      default:
        return LeaveStatus.pending;
    }
  }

  @override
  String toJson(LeaveStatus object) {
    switch (object) {
      case LeaveStatus.pending:
        return 'pending';
      case LeaveStatus.approved:
        return 'approved';
      case LeaveStatus.rejected:
        return 'rejected';
    }
  }
}

class LeaveTypeConverter implements JsonConverter<LeaveType, String> {
  const LeaveTypeConverter();

  @override
  LeaveType fromJson(String json) {
    switch (json.toLowerCase()) {
      case 'half':
        return LeaveType.half;
      case 'full':
        return LeaveType.full;
      default:
        return LeaveType.full;
    }
  }

  @override
  String toJson(LeaveType object) {
    switch (object) {
      case LeaveType.half:
        return 'half';
      case LeaveType.full:
        return 'full';
    }
  }
}

@JsonSerializable(
  converters: [LeaveStatusConverter(), LeaveTypeConverter()],
)
class LeaveRequestModel extends LeaveRequest {
  const LeaveRequestModel({
    required super.id,
    required super.userId,
    required super.userName,
    required super.startDate,
    required super.endDate,
    required super.startTime,
    required super.endTime,
    super.leaveTypeId,
    super.rawLeaveDate,
    super.rawStartTime,
    super.rawEndTime,
    required super.status,
    super.leaveType = LeaveType.full,
    super.reason,
    super.remark,
    super.adminNote,
    super.documentUrl,
    required super.createdAt,
    super.updatedAt,
  });

  factory LeaveRequestModel.fromJson(Map<String, dynamic> json) =>
      _$LeaveRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$LeaveRequestModelToJson(this);

  LeaveRequest toEntity() {
    return LeaveRequest(
      id: id,
      userId: userId,
      userName: userName,
      startDate: startDate,
      endDate: endDate,
      startTime: startTime,
      endTime: endTime,
      leaveTypeId: leaveTypeId,
      rawLeaveDate: rawLeaveDate,
      rawStartTime: rawStartTime,
      rawEndTime: rawEndTime,
      status: status,
      leaveType: leaveType,
      reason: reason,
      remark: remark,
      adminNote: adminNote,
      documentUrl: documentUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

