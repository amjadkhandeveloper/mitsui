import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/attendance_record.dart';
import '../../domain/entities/driver.dart';
import '../../domain/usecases/get_attendance_records_usecase.dart';
import '../../domain/usecases/get_drivers_usecase.dart';

part 'attendance_state.dart';

class AttendanceCubit extends Cubit<AttendanceState> {
  final GetAttendanceRecordsUseCase getAttendanceRecordsUseCase;
  final GetDriversUseCase getDriversUseCase;

  AttendanceCubit({
    required this.getAttendanceRecordsUseCase,
    required this.getDriversUseCase,
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
    String? driverId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    emit(AttendanceLoading());
    final result = await getAttendanceRecordsUseCase(
      driverId: driverId,
      startDate: startDate,
      endDate: endDate,
    );
    result.fold(
      (failure) => emit(AttendanceError(failure.message)),
      (records) => emit(AttendanceLoaded(records: records)),
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

