import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/toast.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/styled_card.dart';
import '../../../../core/utils/animations.dart';
import '../cubit/trip_cubit.dart';
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
  final TextEditingController startOdometerController = TextEditingController();
  final TextEditingController endOdometerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<TripCubit>().loadTripDetail(widget.tripId);
  }

  @override
  void dispose() {
    startOdometerController.dispose();
    endOdometerController.dispose();
    super.dispose();
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

