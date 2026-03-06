// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LeaveRequestModel _$LeaveRequestModelFromJson(Map<String, dynamic> json) =>
    LeaveRequestModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      leaveTypeId: (json['leaveTypeId'] as num?)?.toInt(),
      rawLeaveDate: json['rawLeaveDate'] as String?,
      rawStartTime: json['rawStartTime'] as String?,
      rawEndTime: json['rawEndTime'] as String?,
      status: const LeaveStatusConverter().fromJson(json['status'] as String),
      leaveType: json['leaveType'] == null
          ? LeaveType.full
          : const LeaveTypeConverter().fromJson(json['leaveType'] as String),
      reason: json['reason'] as String?,
      remark: json['remark'] as String?,
      adminNote: json['adminNote'] as String?,
      documentUrl: json['documentUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$LeaveRequestModelToJson(LeaveRequestModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'userName': instance.userName,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime.toIso8601String(),
      'leaveTypeId': instance.leaveTypeId,
      'rawLeaveDate': instance.rawLeaveDate,
      'rawStartTime': instance.rawStartTime,
      'rawEndTime': instance.rawEndTime,
      'status': const LeaveStatusConverter().toJson(instance.status),
      'leaveType': const LeaveTypeConverter().toJson(instance.leaveType),
      'reason': instance.reason,
      'remark': instance.remark,
      'adminNote': instance.adminNote,
      'documentUrl': instance.documentUrl,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
