import '../../domain/entities/leave_type.dart';

class LeaveTypeModel extends LeaveTypeEntity {
  const LeaveTypeModel({
    required super.leaveTypeId,
    required super.leaveTypeName,
  });

  factory LeaveTypeModel.fromJson(Map<String, dynamic> json) {
    return LeaveTypeModel(
      leaveTypeId: json['LeaveTypeId'] as int,
      leaveTypeName: json['LeaveTypeName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'LeaveTypeId': leaveTypeId,
      'LeaveTypeName': leaveTypeName,
    };
  }
}

