import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/attendance_record.dart';
import '../../domain/entities/driver.dart';
import '../../domain/usecases/get_attendance_records_usecase.dart';
import '../../domain/usecases/get_drivers_usecase.dart';
import '../../domain/usecases/approve_check_in_usecase.dart';
import '../../domain/usecases/approve_check_out_usecase.dart';

part 'attendance_state.dart';

class AttendanceCubit extends Cubit<AttendanceState> {
  final GetAttendanceRecordsUseCase getAttendanceRecordsUseCase;
  final GetDriversUseCase getDriversUseCase;
  final ApproveCheckInUseCase approveCheckInUseCase;
  final ApproveCheckOutUseCase approveCheckOutUseCase;

  AttendanceCubit({
    required this.getAttendanceRecordsUseCase,
    required this.getDriversUseCase,
    required this.approveCheckInUseCase,
    required this.approveCheckOutUseCase,
  }) : super(AttendanceInitial());

  Future<void> loadDrivers() async {
    emit(AttendanceLoading());
    final result = await getDriversUseCase();
    result.fold(
      (failure) => emit(AttendanceError(failure.message)),
      (drivers) => emit(DriversLoaded(drivers: drivers)),
    );
  }

  Future<void> loadAttendanceRecords({
    required int? driverId,
    required int? userId,
  }) async {
    // Preserve selectedDriver from current state
    Driver? selectedDriver;
    if (state is DriversLoaded) {
      selectedDriver = (state as DriversLoaded).selectedDriver;
    } else if (state is AttendanceLoaded) {
      selectedDriver = (state as AttendanceLoaded).selectedDriver;
    }
    
    emit(AttendanceLoading());
    final result = await getAttendanceRecordsUseCase(
      driverId: driverId,
      userId: userId,
    );
    result.fold(
      (failure) => emit(AttendanceError(failure.message)),
      (records) => emit(AttendanceLoaded(
        records: records,
        selectedDriver: selectedDriver,
      )),
    );
  }

  Future<void> approveCheckIn({
    required int attendanceId,
    required int userId,
    required String remark,
  }) async {
    final result = await approveCheckInUseCase(
      attendanceId: attendanceId,
      userId: userId,
      remark: remark,
    );
    result.fold(
      (failure) => emit(AttendanceError(failure.message)),
      (_) => emit(CheckInApproved(attendanceId: attendanceId)),
    );
  }

  Future<void> approveCheckOut({
    required int attendanceId,
    required int userId,
    required String remark,
  }) async {
    final result = await approveCheckOutUseCase(
      attendanceId: attendanceId,
      userId: userId,
      remark: remark,
    );
    result.fold(
      (failure) => emit(AttendanceError(failure.message)),
      (_) => emit(CheckOutApproved(attendanceId: attendanceId)),
    );
  }

  void selectDriver(Driver? driver) {
    if (state is AttendanceLoaded) {
      final currentState = state as AttendanceLoaded;
      emit(AttendanceLoaded(
        records: currentState.records,
        selectedDriver: driver,
      ));
    } else if (state is DriversLoaded) {
      final currentState = state as DriversLoaded;
      emit(DriversLoaded(
        drivers: currentState.drivers,
        selectedDriver: driver,
      ));
    }
  }
}

