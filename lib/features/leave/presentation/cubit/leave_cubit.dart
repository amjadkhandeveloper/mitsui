import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/leave_request.dart';
import '../../domain/usecases/get_leave_requests_usecase.dart';
import '../../domain/usecases/apply_leave_usecase.dart';
import '../../domain/usecases/update_leave_status_usecase.dart';

part 'leave_state.dart';

class LeaveCubit extends Cubit<LeaveState> {
  final GetLeaveRequestsUseCase getLeaveRequestsUseCase;
  final ApplyLeaveUseCase applyLeaveUseCase;
  final UpdateLeaveStatusUseCase updateLeaveStatusUseCase;

  LeaveCubit({
    required this.getLeaveRequestsUseCase,
    required this.applyLeaveUseCase,
    required this.updateLeaveStatusUseCase,
  }) : super(LeaveInitial());

  Future<void> loadLeaveRequests({String? userId}) async {
    emit(LeaveLoading());
    final result = await getLeaveRequestsUseCase(userId: userId);
    result.fold(
      (failure) => emit(LeaveError(failure.message)),
      (requests) => emit(LeaveLoaded(requests: requests)),
    );
  }

  Future<void> submitLeaveRequest(Map<String, dynamic> leaveData) async {
    emit(LeaveSubmitting());
    final result = await applyLeaveUseCase(leaveData);
    result.fold(
      (failure) => emit(LeaveError(failure.message)),
      (request) {
        emit(LeaveSubmitted(request: request));
        // Reload leave requests after submission
        loadLeaveRequests(userId: leaveData['user_id'] as String?);
      },
    );
  }

  Future<void> updateStatus(
    String leaveId,
    LeaveStatus status,
    String? adminNote,
  ) async {
    emit(LeaveLoading());
    final result = await updateLeaveStatusUseCase(leaveId, status, adminNote);
    result.fold(
      (failure) => emit(LeaveError(failure.message)),
      (request) {
        emit(LeaveStatusUpdated(request: request));
        // Reload leave requests after status update
        loadLeaveRequests();
      },
    );
  }

  void resetToInitial() {
    emit(LeaveInitial());
  }
}

