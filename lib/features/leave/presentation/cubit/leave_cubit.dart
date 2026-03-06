import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/leave_request.dart';
import '../../domain/entities/leave_type.dart';
import '../../domain/usecases/get_leave_requests_usecase.dart';
import '../../domain/usecases/apply_leave_usecase.dart';
import '../../domain/usecases/update_leave_status_usecase.dart';
import '../../domain/usecases/get_leave_types_usecase.dart';

part 'leave_state.dart';

class LeaveCubit extends Cubit<LeaveState> {
  final GetLeaveRequestsUseCase getLeaveRequestsUseCase;
  final ApplyLeaveUseCase applyLeaveUseCase;
  final UpdateLeaveStatusUseCase updateLeaveStatusUseCase;
  final GetLeaveTypesUseCase getLeaveTypesUseCase;

  LeaveCubit({
    required this.getLeaveRequestsUseCase,
    required this.applyLeaveUseCase,
    required this.updateLeaveStatusUseCase,
    required this.getLeaveTypesUseCase,
  }) : super(LeaveInitial());

  Future<void> loadLeaveRequests({String? userId, String? driverId}) async {
    emit(LeaveLoading());
    final result = await getLeaveRequestsUseCase(userId: userId, driverId: driverId);
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
      (message) {
        emit(LeaveSubmitted(message: message));
        // Reload leave requests after submission
        // Get userId from driverId if available, or from leaveData
        final driverId = leaveData['driverId']?.toString();
        final userId = leaveData['userId']?.toString() ?? leaveData['user_id']?.toString();
        loadLeaveRequests(userId: userId, driverId: driverId);
      },
    );
  }

  Future<void> updateStatus(
    LeaveRequest request,
    LeaveStatus status,
    String? remark,
    String currentUserId, {
    int? clientId,
  }) async {
    emit(LeaveLoading());
    final result = await updateLeaveStatusUseCase(
      request: request,
      status: status,
      currentUserId: currentUserId,
      remark: remark,
      clientId: clientId,
    );
    result.fold(
      (failure) => emit(LeaveError(failure.message)),
      (message) {
        emit(LeaveStatusUpdated(message: message));
        // Note: Reload should be called from UI with proper userId/driverId
        // This method is called from UI which should pass the parameters
      },
    );
  }

  void resetToInitial() {
    emit(LeaveInitial());
  }

  Future<void> loadLeaveTypes() async {
    // Don't emit LeaveLoading here to avoid conflicts with other states
    // Just load the types directly
    final result = await getLeaveTypesUseCase();
    result.fold(
      (failure) => emit(LeaveError(failure.message)),
      (leaveTypes) => emit(LeaveTypesLoaded(leaveTypes: leaveTypes)),
    );
  }
}

