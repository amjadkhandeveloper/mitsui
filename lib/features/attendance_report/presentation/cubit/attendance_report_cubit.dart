import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/attendance_report.dart';
import '../../domain/usecases/get_attendance_report_usecase.dart';
import '../../../attendance/domain/entities/driver.dart';

part 'attendance_report_state.dart';

class AttendanceReportCubit extends Cubit<AttendanceReportState> {
  final GetAttendanceReportUseCase getAttendanceReportUseCase;

  AttendanceReportCubit({
    required this.getAttendanceReportUseCase,
  }) : super(AttendanceReportInitial());

  Future<void> loadReport({
    String? driverId,
    int? month,
    int? year,
  }) async {
    emit(AttendanceReportLoading());
    final result = await getAttendanceReportUseCase(
      driverId: driverId,
      month: month,
      year: year,
    );
    result.fold(
      (failure) => emit(AttendanceReportError(failure.message)),
      (report) => emit(AttendanceReportLoaded(report: report)),
    );
  }

  void selectDriver(Driver? driver) {
    if (state is AttendanceReportLoaded) {
      final currentState = state as AttendanceReportLoaded;
      emit(AttendanceReportLoaded(
        report: currentState.report,
        selectedDriver: driver,
      ));
    }
  }

  void selectMonth(int month, int year) {
    if (state is AttendanceReportLoaded) {
      final currentState = state as AttendanceReportLoaded;
      emit(AttendanceReportLoaded(
        report: currentState.report,
        selectedMonth: month,
        selectedYear: year,
      ));
    }
  }
}

