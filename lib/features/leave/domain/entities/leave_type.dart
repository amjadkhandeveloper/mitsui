import 'package:equatable/equatable.dart';

class LeaveTypeEntity extends Equatable {
  final int leaveTypeId;
  final String leaveTypeName;

  const LeaveTypeEntity({
    required this.leaveTypeId,
    required this.leaveTypeName,
  });

  @override
  List<Object> get props => [leaveTypeId, leaveTypeName];
}

