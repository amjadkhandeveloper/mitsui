import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/toast.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/styled_card.dart';
import '../../../../core/utils/animations.dart';
import '../cubit/trip_cubit.dart';
import '../../../splash/data/datasources/local_storage_data_source.dart';
import '../../../login/domain/repositories/auth_repository.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../widgets/trip_info_row.dart';
import '../widgets/odometer_input_field.dart';
import '../../domain/entities/trip_detail.dart';

class TripDetailScreen extends StatefulWidget {
  final String tripId;

  const TripDetailScreen({
    super.key,
    required this.tripId,
  });

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  int? tripStartOdometer;
  int? tripEndOdometer;
  bool _isExpatUser = false;
  final TextEditingController startOdometerController = TextEditingController();
  final TextEditingController endOdometerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkUserRole();
    context.read<TripCubit>().loadTripDetail(widget.tripId);
  }

  Future<void> _checkUserRole() async {
    try {
      final localStorage = di.sl<LocalStorageDataSource>();
      final role = await localStorage.getUserRole();
      if (mounted) {
        setState(() {
          _isExpatUser = role == 'expat';
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    startOdometerController.dispose();
    endOdometerController.dispose();
    super.dispose();
  }

  static Future<void> _openDocPreview(BuildContext context, String filePath) async {
    // If API already returns a full URL, use it directly; otherwise prefix base URL.
    final String url;
    if (filePath.toLowerCase().startsWith('http')) {
      url = filePath.trim();
    } else {
      final path = filePath.startsWith('/') ? filePath : '/$filePath';
      url = (ApiConstants.tripDocumentBaseUrl + path).trim();
    }

    final uri = Uri.parse(url);
    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open document')),
        );
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open document')),
      );
    }
  }

  Future<void> _handleCancelTrip(BuildContext context) async {
    try {
      final remarksController = TextEditingController();

      // Get user ID from local storage
      final localStorage = di.sl<LocalStorageDataSource>();
      String? userId = await localStorage.getUserId();

      // Fallback: if userid is missing, try to recover from AuthRepository.getCurrentUser
      if (userId == null || userId.isEmpty) {
        try {
          final authRepo = di.sl<AuthRepository>();
          final result = await authRepo.getCurrentUser();
          result.fold(
            (_) {},
            (user) {
              if (user != null) {
                userId = user.id;
              }
            },
          );
        } catch (_) {
          // ignore
        }
      }

      if (userId == null || userId!.isEmpty) {
        Toast.showError(context, 'User ID not found. Please login again.');
        return;
      }

      // Confirm cancellation
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Cancel Trip',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Are you sure you want to cancel this trip?'),
              const SizedBox(height: 12),
              const Text(
                'Remarks (optional)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: remarksController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'Enter remarks',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Yes, Cancel'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        final remarks = remarksController.text.trim();
        context.read<TripCubit>().cancelTrip(
              widget.tripId,
              userId!,
              remarks: remarks.isNotEmpty ? remarks : 'Cancelled by user',
            );
      }
    } catch (e) {
      Toast.showError(context, 'Failed to cancel trip: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Trip'),
        backgroundColor: AppTheme.mitsuiDarkBlue,
        elevation: 0,
      ),
      body: BlocConsumer<TripCubit, TripState>(
        listener: (context, state) {
          if (state is TripStarted) {
            Toast.showSuccess(context, 'Trip started successfully');
            startOdometerController.text = state.trip.tripStartOdometer?.toString() ?? '';
            setState(() {
              tripStartOdometer = state.trip.tripStartOdometer;
            });
          } else if (state is TripEnded) {
            Toast.showSuccess(context, 'Trip ended successfully');
            endOdometerController.text = state.trip.tripEndOdometer?.toString() ?? '';
            setState(() {
              tripEndOdometer = state.trip.tripEndOdometer;
            });
          } else if (state is TripActionSuccess) {
            // Used for approve/reject/cancel actions
            Toast.showSuccess(context, state.message);
            Navigator.pop(context);
          } else if (state is TripError) {
            Toast.showError(context, state.message);
          } else if (state is TripDetailLoaded) {
            // Update odometer values from loaded trip
            if (state.trip.tripStartOdometer != null) {
              startOdometerController.text = state.trip.tripStartOdometer.toString();
              tripStartOdometer = state.trip.tripStartOdometer;
            }
            if (state.trip.tripEndOdometer != null) {
              endOdometerController.text = state.trip.tripEndOdometer.toString();
              tripEndOdometer = state.trip.tripEndOdometer;
            }
          }
        },
        builder: (context, state) {
          if (state is TripLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TripDetailLoaded || state is TripStarted || state is TripEnded) {
            final trip = state is TripDetailLoaded
                ? state.trip
                : state is TripStarted
                    ? state.trip
                    : (state as TripEnded).trip;

            final dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm:ss');
            final canStartTrip = trip.status == TripDetailStatus.scheduled;
            final canEndTrip = trip.status == TripDetailStatus.started;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Trip Details Card
                  FadeSlideAnimation(
                    delay: const Duration(milliseconds: 100),
                    beginOffset: const Offset(0, 0.2),
                    child: StyledCard(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppTheme.mitsuiLightBlue,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.directions_car,
                                  color: AppTheme.mitsuiBlue,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Trip Details',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          TripInfoRow(
                            label: 'Vehicle ID',
                            value: trip.vehicleId,
                          ),
                          TripInfoRow(
                            label: 'Route',
                            value: trip.route ?? 'NA',
                          ),
                          TripInfoRow(
                            label: 'Customer',
                            value: trip.customer ?? 'NA',
                          ),
                          TripInfoRow(
                            label: 'Location',
                            value: trip.location ?? 'NA',
                          ),
                          TripInfoRow(
                            label: 'Pickup/Drop',
                            value: trip.pickupDrop ?? 'NA',
                          ),
                          TripInfoRow(
                            label: 'Schedule Start',
                            value: dateTimeFormat.format(trip.scheduleStart),
                          ),
                          TripInfoRow(
                            label: 'Actual Start',
                            value: trip.actualStart != null
                                ? dateTimeFormat.format(trip.actualStart!)
                                : '01/01/0001 00:00:00',
                          ),
                          // When expat is logged in, show driver info; when driver is logged in, show expat info
                          if (_isExpatUser) ...[
                            if (trip.driverName != null && trip.driverName!.isNotEmpty)
                              TripInfoRow(
                                label: 'Driver Name',
                                value: trip.driverName!,
                              ),
                            if (trip.driverMobileNo != null && trip.driverMobileNo!.isNotEmpty)
                              TripInfoRow(
                                label: 'Driver Mobile No',
                                value: trip.driverMobileNo!,
                              ),
                          ] else ...[
                            if (trip.expatName != null && trip.expatName!.isNotEmpty)
                              TripInfoRow(
                                label: 'Expat Name',
                                value: trip.expatName!,
                              ),
                            if (trip.mobileNo != null && trip.mobileNo!.isNotEmpty)
                              TripInfoRow(
                                label: 'Mobile No',
                                value: trip.mobileNo!,
                              ),
                          ],
                          // Doc preview for adhoc trips with PDF (FilePath)
                          if (trip.filePath != null && trip.filePath!.trim().isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const Icon(Icons.picture_as_pdf_outlined, size: 20, color: AppTheme.mitsuiDarkBlue),
                                const SizedBox(width: 8),
                                OutlinedButton.icon(
                                  onPressed: () => _openDocPreview(context, trip.filePath!),
                                  icon: const Icon(Icons.open_in_new, size: 16),
                                  label: const Text('Doc preview'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppTheme.mitsuiDarkBlue,
                                    side: const BorderSide(color: AppTheme.mitsuiBlue),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  // Odometer Readings Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FadeSlideAnimation(
                          delay: const Duration(milliseconds: 200),
                          beginOffset: const Offset(0, 0.2),
                          child: const Text(
                            'Odometer Readings',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        FadeSlideAnimation(
                          delay: const Duration(milliseconds: 250),
                          beginOffset: const Offset(0, 0.2),
                          child: OdometerInputField(
                            label: 'Trip Start Odometer',
                            value: trip.tripStartOdometer,
                            enabled: canStartTrip,
                            onChanged: (value) {
                              setState(() {
                                tripStartOdometer = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        FadeSlideAnimation(
                          delay: const Duration(milliseconds: 300),
                          beginOffset: const Offset(0, 0.2),
                          child: OdometerInputField(
                            label: 'Trip End Odometer',
                            value: trip.tripEndOdometer,
                            enabled: canEndTrip,
                            onChanged: (value) {
                              setState(() {
                                tripEndOdometer = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Action Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: FadeSlideAnimation(
                      delay: const Duration(milliseconds: 400),
                      beginOffset: const Offset(0, 0.2),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: (state is TripSubmitting || !canStartTrip || tripStartOdometer == null)
                                  ? null
                                  : () {
                                      context.read<TripCubit>().startTrip(
                                            widget.tripId,
                                            tripStartOdometer!,
                                          );
                                    },
                              icon: const Icon(Icons.play_arrow, color: Colors.white),
                              label: const Text(
                                'Start Trip',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade600,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: (state is TripSubmitting || !canEndTrip || tripEndOdometer == null)
                                  ? null
                                  : () {
                                      context.read<TripCubit>().endTrip(
                                            widget.tripId,
                                            tripEndOdometer!,
                                          );
                                    },
                              icon: const Icon(Icons.stop, color: Colors.white),
                              label: const Text(
                                'End Trip',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: canEndTrip
                                    ? Colors.grey.shade600
                                    : Colors.grey.shade300,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Cancel Trip (for expat to cancel scheduled trips)
                  // Hide button if trip is already cancelled
                  if (trip.status == TripDetailStatus.scheduled &&
                      trip.status != TripDetailStatus.cancelled &&
                      trip.tripStatus != 3 && // 3 = TripStatus.tripCancelled
                      trip.actualStart == null &&
                      trip.actualEnd == null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: FadeSlideAnimation(
                        delay: const Duration(milliseconds: 450),
                        beginOffset: const Offset(0, 0.2),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: state is TripSubmitting
                                ? null
                                : () {
                                    _handleCancelTrip(context);
                                  },
                            icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                            label: const Text(
                              'Cancel Trip',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.red.shade300),
                              foregroundColor: Colors.red.shade700,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 32),
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
}

