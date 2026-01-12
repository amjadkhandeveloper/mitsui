import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/toast.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/routes/app_routes.dart';
import '../cubit/trip_cubit.dart';
import '../widgets/trip_list_item.dart';
import '../../../login/domain/repositories/auth_repository.dart';
import '../../../login/domain/entities/user.dart';
import '../../../../core/di/injection_container.dart' as di;

class TripListScreen extends StatefulWidget {
  const TripListScreen({super.key});

  @override
  State<TripListScreen> createState() => _TripListScreenState();
}

class _TripListScreenState extends State<TripListScreen> {
  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    final authRepository = di.sl<AuthRepository>();
    final result = await authRepository.getCurrentUser();
    result.fold(
      (failure) => null,
      (user) {
        // Load trips for current user (driver) or all trips (expat)
        final driverId = user?.role == UserRole.driver ? user?.id : null;
        context.read<TripCubit>().loadTrips(driverId: driverId);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Trips'),
        backgroundColor: AppTheme.mitsuiDarkBlue,
        elevation: 0,
      ),
      body: BlocConsumer<TripCubit, TripState>(
        listener: (context, state) {
          if (state is TripError) {
            Toast.showError(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is TripLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TripsLoaded) {
            if (state.trips.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.directions_car_outlined,
                      size: 64,
                      color: Colors.grey.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No trips found',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                await _loadTrips();
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.trips.length,
                itemBuilder: (context, index) {
                  return TripListItem(
                    trip: state.trips[index],
                    index: index,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.tripDetail,
                        arguments: state.trips[index].id,
                      );
                    },
                  );
                },
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

