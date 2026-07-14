class DashboardSummary {
  final int? checkStatus;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final double odometerIn;
  final double odometerOut;

  const DashboardSummary({
    this.checkStatus,
    this.checkInTime,
    this.checkOutTime,
    this.odometerIn = 0,
    this.odometerOut = 0,
  });

  /// Prefill picker: use IN when OUT is 0, otherwise OUT.
  double get referenceOdometer => odometerOut <= 0 ? odometerIn : odometerOut;

  /// Next check-in must not be below the last completed check-out.
  double get minimumForCheckIn => odometerOut > 0 ? odometerOut : 0;

  /// Check-out must not be below the current check-in reading.
  double get minimumForCheckOut => odometerIn > 0 ? odometerIn : 0;
}
