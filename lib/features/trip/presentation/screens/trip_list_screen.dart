import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/toast.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/routes/app_routes.dart';
import '../cubit/trip_cubit.dart';
import '../widgets/trip_list_item.dart';
import '../widgets/horizontal_date_calendar.dart';
import '../../domain/entities/trip_detail.dart';
import '../../../splash/data/datasources/local_storage_data_source.dart';
import '../../../login/domain/repositories/auth_repository.dart';
import '../../../login/domain/entities/user.dart';
import '../../../../core/di/injection_container.dart' as di;

class TripListScreen extends StatefulWidget {
  const TripListScreen({super.key});

  @override
  State<TripListScreen> createState() => _TripListScreenState();
}

class _TripListScreenState extends State<TripListScreen> {
  bool _isExpatUser = false;
  DateTime? _selectedDate;
  List<TripDetail> _allTrips = [];
  List<TripDetail> _filteredTrips = [];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _checkUserRole();
    _loadTrips();
  }

  Future<void> _checkUserRole() async {
    try {
      final localStorage = di.sl<LocalStorageDataSource>();
      final role = await localStorage.getUserRole();
      
      // Check if role string is 'expat'
      if (role == 'expat') {
        if (mounted) {
          setState(() {
            _isExpatUser = true;
          });
        }
        return;
      }
      
      // Also check roleid from SharedPreferences (RoleId: 4 = expat)
      final sharedPrefs = di.sl<SharedPreferences>();
      final roleIdString = sharedPrefs.getString('roleid');
      if (roleIdString == '4') {
        if (mounted) {
          setState(() {
            _isExpatUser = true;
          });
        }
        return;
      }
      
      // Fallback: Check user_data JSON for role
      try {
        final userDataJson = sharedPrefs.getString('user_data');
        if (userDataJson != null) {
          final userData = jsonDecode(userDataJson) as Map<String, dynamic>;
          final storedRole = userData['role']?.toString().toLowerCase();
          if (storedRole == 'expat') {
            if (mounted) {
              setState(() {
                _isExpatUser = true;
              });
            }
            return;
          }
        }
      } catch (_) {
        // Ignore JSON parsing errors
      }
      
      // Fallback: Check AuthRepository for current user role
      try {
        final authRepo = di.sl<AuthRepository>();
        final result = await authRepo.getCurrentUser();
        result.fold(
          (_) {},
          (user) {
            if (user != null && user.role == UserRole.expat) {
              if (mounted) {
                setState(() {
                  _isExpatUser = true;
                });
              }
            }
          },
        );
        return;
      } catch (_) {
        // Ignore errors
      }
      
      if (mounted) {
        setState(() {
          _isExpatUser = false;
        });
      }
    } catch (e) {
      // Default to driver if error
      if (mounted) {
        setState(() {
          _isExpatUser = false;
        });
      }
    }
  }

  Future<void> _loadTrips() async {
    try {
      // Get IDs from local storage
      final localStorage = di.sl<LocalStorageDataSource>();
      String? backendUserId = await localStorage.getUserId();   // userid from API
      String? backendDriverId = await localStorage.getDriverId(); // driverid from API (for driver login)
      bool isExpat = false;

      // Determine role from stored values (expat vs driver)
      try {
        final sharedPrefs = di.sl<SharedPreferences>();
        final roleIdString = sharedPrefs.getString('roleid');
        if (roleIdString == '4') {
          isExpat = true;
        } else if (roleIdString == '7') {
          isExpat = false;
        } else {
          final storedRole = sharedPrefs.getString('role');
          if (storedRole == 'expat') {
            isExpat = true;
          }
        }
      } catch (_) {
        // Default handled below (driver)
      }

      // Fallback: if both ids missing, try to recover from AuthRepository.getCurrentUser
      if ((backendUserId == null || backendUserId.isEmpty) &&
          (backendDriverId == null || backendDriverId.isEmpty)) {
        try {
          final authRepo = di.sl<AuthRepository>();
          final result = await authRepo.getCurrentUser();
          result.fold(
            (_) {},
            (user) {
              if (user != null) {
                // For expat, use user.id as userid; for driver, use driverId when available
                if (user.role == UserRole.expat) {
                  backendUserId = user.id;
                } else {
                  backendDriverId = user.driverId ?? user.id;
                }
              }
            },
          );
        } catch (_) {
          // ignore, will handle below if still null/empty
        }
      }

      if ((isExpat && backendUserId != null && backendUserId!.isNotEmpty) ||
          (!isExpat && backendDriverId != null && backendDriverId!.isNotEmpty)) {
        // For TripDetails API we must send both user_id and driver_id:
        // - If expat:  user_id = userid, driver_id = "0"
        // - If driver: user_id = "0",   driver_id = driverid
        if (isExpat) {
          context.read<TripCubit>().loadTrips(
                userId: backendUserId,
                driverId: null,
              );
        } else {
          context.read<TripCubit>().loadTrips(
                userId: null,
                driverId: backendDriverId,
              );
        }
      } else {
        // If no valid ID found, show error
        if (mounted) {
          Toast.showError(context, 'User / Driver ID not found. Please login again.');
        }
      }
    } catch (e) {
      if (mounted) {
        Toast.showError(context, 'Failed to load trips: $e');
      }
    }
  }

  Future<void> _handleCancelTrip(BuildContext context, String tripId) async {
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
        if (mounted) {
          Toast.showError(context, 'User ID not found. Please login again.');
        }
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

      if (confirmed == true && mounted && userId != null) {
        final remarks = remarksController.text.trim();
        await context.read<TripCubit>().cancelTrip(
              tripId,
              userId!,
              remarks: remarks.isNotEmpty ? remarks : 'Cancelled from list',
            );
        // Reload trips after cancellation
        await _loadTrips();
      }
    } catch (e) {
      if (mounted) {
        Toast.showError(context, 'Failed to cancel trip: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Trips'),
        backgroundColor: AppTheme.mitsuiDarkBlue,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadTrips(),
            tooltip: 'Refresh trips',
          ),
        ],
      ),
      body: BlocConsumer<TripCubit, TripState>(
        listener: (context, state) {
          if (state is TripError) {
            Toast.showError(context, state.message);
          } else if (state is TripActionSuccess) {
            // Show success toast on approve/reject
            Toast.showSuccess(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is TripLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TripsLoaded) {
            // Update trips list and filter by selected date
            _allTrips = state.trips;
            _filterTripsByDate();

            if (_filteredTrips.isEmpty) {
              return Column(
                children: [
                  HorizontalDateCalendar(
                    selectedDate: _selectedDate,
                    onDateSelected: (date) {
                      setState(() {
                        _selectedDate = date;
                      });
                      _filterTripsByDate();
                    },
                    availableDates: _getAvailableDates(),
                  ),
                  // No trips for this date: keep list area empty
                  const Expanded(
                    child: SizedBox.shrink(),
                  ),
                ],
              );
            }

            return Column(
              children: [
                HorizontalDateCalendar(
                  selectedDate: _selectedDate,
                  onDateSelected: (date) {
                    setState(() {
                      _selectedDate = date;
                    });
                    _filterTripsByDate();
                  },
                  availableDates: _getAvailableDates(),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await _loadTrips();
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                      itemCount: _filteredTrips.length,
                      itemBuilder: (context, index) {
                        final trip = _filteredTrips[index];
                        final canCancel = _isExpatUser &&
                            trip.status == TripDetailStatus.scheduled &&
                            trip.actualStart == null &&
                            trip.actualEnd == null;

                        return TripListItem(
                          trip: trip,
                          index: index,
                          isExpatUser: _isExpatUser,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.tripDetail,
                              arguments: trip.id,
                            );
                          },
                          // All approve / reject actions moved to Vehicle Schedule screen.
                          onApprove: null,
                          onReject: null,
                          onAccept: null,
                          onRejectDriver: null,
                          onCancel: canCancel ? () => _handleCancelTrip(context, trip.id) : null,
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          }

          return const Center(
            child: Text('No data available'),
          );
        },
      ),
    );
  }

  Future<void> _handleApproveTrip(BuildContext context, String tripId) async {
    try {
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
        if (mounted) {
          Toast.showError(context, 'User ID not found. Please login again.');
        }
        return;
      }

      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Approve Trip',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text('Are you sure you want to approve this trip?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Approve'),
            ),
          ],
        ),
      );

      if (confirmed == true && mounted && userId != null) {
        // Call approve trip action with user ID
        await context.read<TripCubit>().approveTrip(tripId, userId!);
        // Reload trips after approval
        await _loadTrips();
      }
    } catch (e) {
      if (mounted) {
        Toast.showError(context, 'Failed to approve trip: $e');
      }
    }
  }

  Future<void> _handleRejectTrip(BuildContext context, String tripId) async {
    try {
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
        if (mounted) {
          Toast.showError(context, 'User ID not found. Please login again.');
        }
        return;
      }

      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Reject Trip',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text('Are you sure you want to reject this trip?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Reject'),
            ),
          ],
        ),
      );

      if (confirmed == true && mounted && userId != null) {
        // Call reject trip action with user ID
        await context.read<TripCubit>().rejectTrip(tripId, userId!);
        // Reload trips after rejection
        await _loadTrips();
      }
    } catch (e) {
      if (mounted) {
        Toast.showError(context, 'Failed to reject trip: $e');
      }
    }
  }

  Future<void> _handleAcceptTrip(BuildContext context, String tripId) async {
    try {
      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Accept Trip',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text('Are you sure you want to accept this trip?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Accept'),
            ),
          ],
        ),
      );

      if (confirmed == true && mounted) {
        // TODO: Implement driver accept trip API when available
        // For now, just reload trips
        await Future.delayed(const Duration(milliseconds: 500));
        await _loadTrips();
        if (mounted) {
          Toast.showSuccess(context, 'Trip accepted successfully');
        }
      }
    } catch (e) {
      if (mounted) {
        Toast.showError(context, 'Failed to accept trip: $e');
      }
    }
  }

  Future<void> _handleRejectTripDriver(BuildContext context, String tripId) async {
    try {
      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Reject Trip',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text('Are you sure you want to reject this trip?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Reject'),
            ),
          ],
        ),
      );

      if (confirmed == true && mounted) {
        // TODO: Implement driver reject trip API when available
        // For now, just reload trips
        await Future.delayed(const Duration(milliseconds: 500));
        await _loadTrips();
        if (mounted) {
          Toast.showSuccess(context, 'Trip rejected');
        }
      }
    } catch (e) {
      if (mounted) {
        Toast.showError(context, 'Failed to reject trip: $e');
      }
    }
  }

  void _filterTripsByDate() {
    if (_selectedDate == null) {
      _filteredTrips = _allTrips;
      return;
    }

    final selectedDateOnly = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
    );

    _filteredTrips = _allTrips.where((trip) {
      // Check if trip's schedule start date matches selected date
      final tripDate = DateTime(
        trip.scheduleStart.year,
        trip.scheduleStart.month,
        trip.scheduleStart.day,
      );
      return tripDate.isAtSameMomentAs(selectedDateOnly);
    }).toList();
  }

  List<DateTime> _getAvailableDates() {
    // Extract unique dates from trips
    final dates = <DateTime>{};
    for (final trip in _allTrips) {
      final tripDate = DateTime(
        trip.scheduleStart.year,
        trip.scheduleStart.month,
        trip.scheduleStart.day,
      );
      dates.add(tripDate);
    }
    return dates.toList()..sort();
  }
}

