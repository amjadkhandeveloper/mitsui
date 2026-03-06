import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/animations.dart';
import '../../../../core/widgets/styled_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/trip_detail.dart';

class TripListItem extends StatelessWidget {
  final TripDetail trip;
  final int index;
  final VoidCallback onTap;
  final bool isExpatUser;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onAccept; // For drivers
  final VoidCallback? onRejectDriver; // For drivers
  final VoidCallback? onCancel; // For expat cancel

  const TripListItem({
    super.key,
    required this.trip,
    required this.index,
    required this.onTap,
    this.isExpatUser = false,
    this.onApprove,
    this.onReject,
    this.onAccept,
    this.onRejectDriver,
    this.onCancel,
  });

  Color _getStatusColor() {
    // Cancelled: by enum or by numeric tripStatus (3 = Trip Cancelled) — always red
    if (trip.status == TripDetailStatus.cancelled || trip.tripStatus == 3) {
      return Colors.red;
    }
    switch (trip.status) {
      case TripDetailStatus.scheduled:
        return AppTheme.mitsuiBlue;
      case TripDetailStatus.started:
        return Colors.orange;
      case TripDetailStatus.completed:
        return Colors.green;
      case TripDetailStatus.cancelled:
        return Colors.red;
    }
  }

  String _getStatusText() {
    switch (trip.status) {
      case TripDetailStatus.scheduled:
        return 'Scheduled';
      case TripDetailStatus.started:
        return 'Started';
      case TripDetailStatus.completed:
        return 'Completed';
      case TripDetailStatus.cancelled:
        return 'Cancelled';
    }
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

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd-MMM-yyyy');
    final timeFormat = DateFormat('hh:mm a');

    return FadeSlideAnimation(
      delay: Duration(milliseconds: 200 + (index * 50)),
      beginOffset: const Offset(0, 0.1),
      child: StyledCard(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row with Vehicle Info and compact status + trip type badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vehicle Icon with gradient background
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color.fromARGB(255, 169, 173, 178).withOpacity(0.2),
                        AppTheme.mitsuiDarkBlue.withOpacity(0.3),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.directions_car_rounded,
                    color: AppTheme.mitsuiDarkBlue,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),
                // Title + status stacked vertically
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.vehicleName.isNotEmpty ? trip.vehicleName : 'Vehicle',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dateFormat.format(trip.scheduleStart),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Trip type badge in top-right corner (uses route / tripType)
                    if (trip.tripType != null && trip.tripType!.isNotEmpty)
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: trip.status == TripDetailStatus.cancelled
                              ? Colors.red.shade50
                              : Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: trip.status == TripDetailStatus.cancelled
                                ? Colors.red.shade200
                                : Colors.blue.shade200,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          trip.tripType!.toUpperCase(),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: trip.status == TripDetailStatus.cancelled
                                ? Colors.red.shade700
                                : Colors.blue.shade700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    const SizedBox(height: 4),
                    // Compact status badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _getStatusColor().withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getStatusColor().withOpacity(0.4),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        trip.tripStatus != null
                            ? TripStatus.fromValue(trip.tripStatus)?.displayName ??
                                _getStatusText()
                            : _getStatusText(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _getStatusColor(),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Start & End Time row
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 14,
                          color: Colors.grey.shade700,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Start Time',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                timeFormat.format(trip.scheduleStart),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.event_rounded,
                          size: 14,
                          color: Colors.grey.shade700,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'End Time',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                trip.scheduleEnd != null
                                    ? timeFormat.format(trip.scheduleEnd!)
                                    : '-',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // When expat is logged in, show driver info; when driver is logged in, show expat info
            if (isExpatUser
                ? (trip.driverName != null ||
                    (trip.driverMobileNo != null && trip.driverMobileNo!.isNotEmpty))
                : (trip.expatName != null ||
                    (trip.mobileNo != null && trip.mobileNo!.isNotEmpty))) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.person_outline_rounded,
                    size: 14,
                    color: Colors.black54,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      isExpatUser
                          // Expat login → show driver name + driver mobile
                          ? (trip.driverMobileNo != null && trip.driverMobileNo!.isNotEmpty
                              ? '${trip.driverName ?? 'Driver'} (${trip.driverMobileNo})'
                              : (trip.driverName ?? 'Driver'))
                          // Driver login → show expat name + expat mobile
                          : (trip.mobileNo != null && trip.mobileNo!.isNotEmpty
                              ? '${trip.expatName ?? 'Expat'} (${trip.mobileNo})'
                              : (trip.expatName ?? 'Expat')),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            // Location row
            if (trip.location != null && trip.location!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: Colors.black54,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      trip.location!,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade800,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            // Doc preview for adhoc trips with PDF (FilePath)
            if (trip.filePath != null && trip.filePath!.trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => _openDocPreview(context, trip.filePath!),
                icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                label: const Text('Doc preview'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.mitsuiDarkBlue,
                  side: BorderSide(color: AppTheme.mitsuiBlue),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
            // Cancel button for Expat users on scheduled trips (not started)
            // Hide button if trip is already cancelled
            if (isExpatUser &&
                trip.status == TripDetailStatus.scheduled &&
                trip.status != TripDetailStatus.cancelled &&
                trip.tripStatus != 3 && // 3 = TripStatus.tripCancelled
                trip.actualStart == null &&
                trip.actualEnd == null &&
                onCancel != null) ...[
              const SizedBox(height: 12),
              Divider(
                height: 1,
                thickness: 1,
                color: Colors.grey.shade200,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                  child: OutlinedButton.icon(
                  onPressed: onCancel,
                  icon: const Icon(Icons.cancel_outlined, size: 20),
                  label: const Text(
                    'Cancel Trip',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade700,
                    side: BorderSide(color: Colors.red.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
            // Action Buttons for Expat Users (Approve/Reject)
            // Show when tripStatus is 1 (Trip Requested) or 2 (Trip Scheduled)
            // AND trip type is 'Adhoc'
            // Also ensure callbacks are provided
            if (isExpatUser &&
                trip.shouldShowAcceptRejectButtons &&
                (trip.route?.toLowerCase() == 'adhoc') &&
                onApprove != null &&
                onReject != null) ...[
              const SizedBox(height: 20),
              Divider(
                height: 1,
                thickness: 1,
                color: Colors.grey.shade200,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      context: context,
                      label: 'Reject',
                      icon: Icons.close_rounded,
                      color: Colors.red,
                      onPressed: onReject,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      context: context,
                      label: 'Approve',
                      icon: Icons.check_circle_outline_rounded,
                      color: Colors.green,
                      onPressed: onApprove,
                    ),
                  ),
                ],
              ),
            ],
            // Action Buttons for Drivers (Accept/Reject)
            // Show when tripStatus is 1 (Trip Requested) or 2 (Trip Scheduled)
            if (!isExpatUser && trip.shouldShowAcceptRejectButtons && 
                onAccept != null && onRejectDriver != null) ...[
              const SizedBox(height: 20),
              Divider(
                height: 1,
                thickness: 1,
                color: Colors.grey.shade200,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      context: context,
                      label: 'Reject',
                      icon: Icons.close_rounded,
                      color: Colors.red,
                      onPressed: onRejectDriver,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      context: context,
                      label: 'Accept',
                      icon: Icons.check_circle_outline_rounded,
                      color: Colors.green,
                      onPressed: onAccept,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // _buildDetailRow removed in favour of compact layout

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color color,
    VoidCallback? onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

