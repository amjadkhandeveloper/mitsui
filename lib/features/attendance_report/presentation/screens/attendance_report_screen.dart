import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/toast.dart';
import '../../../../core/theme/app_theme.dart';
import '../cubit/attendance_report_cubit.dart';
import '../widgets/monthly_report_header.dart';
import '../widgets/statistic_card.dart';
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MonthlyReportHeader(
                    drivers: drivers,
                    selectedDriver: selectedDriver,
                    selectedMonth: selectedMonth,
                    onDriverSelected: (driver) {
                      setState(() {
                        selectedDriver = driver;
                      });
                      context.read<AttendanceReportCubit>().loadReport(
                            driverId: driver?.id,
                            month: selectedMonth.month,
                            year: selectedMonth.year,
                          );
                    },
                    onMonthSelected: (month) {
                      setState(() {
                        selectedMonth = month;
                      });
                      context.read<AttendanceReportCubit>().loadReport(
                            driverId: selectedDriver?.id,
                            month: month.month,
                            year: month.year,
                          );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Summary Statistics
                        const Text(
                          'Summary Statistics',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.85,
                          children: [
                            StatisticCard(
                              icon: Icons.calendar_today,
                              iconColor: Colors.blue,
                              value: report.totalDays.toString(),
                              label: 'Total Days',
                            ),
                            StatisticCard(
                              icon: Icons.check_circle,
                              iconColor: Colors.green,
                              value: report.presentDays.toString(),
                              label: 'Present',
                            ),
                            StatisticCard(
                              icon: Icons.cancel,
                              iconColor: Colors.red,
                              value: report.absentDays.toString(),
                              label: 'Absent',
                            ),
                            StatisticCard(
                              icon: Icons.event_busy,
                              iconColor: Colors.orange,
                              value: report.leaveDays.toString(),
                              label: 'Leave',
                            ),
                            StatisticCard(
                              icon: Icons.trending_up,
                              iconColor: Colors.blue,
                              value: '${report.attendanceRate.toStringAsFixed(1)}%',
                              label: 'Attendance Rate',
                            ),
                            StatisticCard(
                              icon: Icons.access_time,
                              iconColor: Colors.green,
                              value: _formatDuration(report.totalHours),
                              label: 'Total Hours',
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Daily Attendance Records
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
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
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

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }
}

