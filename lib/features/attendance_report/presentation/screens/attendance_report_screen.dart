import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/toast.dart';
import '../../../../core/theme/app_theme.dart';
import '../cubit/attendance_report_cubit.dart';
// MonthlyReportHeader and StatisticCard are no longer used after
// simplifying the attendance report UI.
import '../widgets/daily_record_card.dart';
import '../../../attendance/domain/usecases/get_drivers_usecase.dart';
import '../../../attendance/domain/entities/driver.dart';
import '../../../../core/di/injection_container.dart' as di;

class AttendanceReportScreen extends StatefulWidget {
  const AttendanceReportScreen({super.key});

  @override
  State<AttendanceReportScreen> createState() => _AttendanceReportScreenState();
}

class _AttendanceReportScreenState extends State<AttendanceReportScreen> {
  List<Driver> drivers = [];
  Driver? selectedDriver;
  DateTime selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadDrivers();
    _loadReport();
  }

  Future<void> _loadDrivers() async {
    final useCase = di.sl<GetDriversUseCase>();
    final result = await useCase();
    result.fold(
      (failure) => null,
      (driversList) {
        setState(() {
          drivers = driversList;
        });
      },
    );
  }

  void _loadReport() {
    context.read<AttendanceReportCubit>().loadReport(
          driverId: selectedDriver?.id,
          month: selectedMonth.month,
          year: selectedMonth.year,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Attendance Report'),
        backgroundColor: AppTheme.mitsuiDarkBlue,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadReport();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: BlocConsumer<AttendanceReportCubit, AttendanceReportState>(
        listener: (context, state) {
          if (state is AttendanceReportError) {
            Toast.showError(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is AttendanceReportLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AttendanceReportLoaded) {
            final report = state.report;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: AppTheme.mitsuiBlue,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Daily Attendance Records',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${report.dailyRecords.length} records',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (report.dailyRecords.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.event_busy,
                              size: 64,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No records found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...report.dailyRecords.map((record) {
                      return DailyRecordCard(
                        record: record,
                        index: report.dailyRecords.indexOf(record),
                      );
                    }),
                  const SizedBox(height: 80),
                ],
              ),
            );
          }

          return const Center(
            child: Text('No data available'),
          );
        },
      ),
    );
  }

  // _formatDuration no longer used since summary statistics were removed.
}

