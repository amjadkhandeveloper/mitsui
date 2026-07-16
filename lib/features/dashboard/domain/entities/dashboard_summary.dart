class DashboardSummary {
  final int? checkStatus;
  /// 0 = regular duty, 1 = standby duty.
  final int standbyStatus;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final double odometerIn;
  final double odometerOut;

  const DashboardSummary({
    this.checkStatus,
    this.standbyStatus = 0,
    this.checkInTime,
    this.checkOutTime,
    this.odometerIn = 0,
    this.odometerOut = 0,
  });

  /// Prefill picker: use IN when OUT is 0, otherwise OUT.
  /// Prefer the larger reading when both are available so truncated/stale
  /// smaller values don't override a real odometer.
  double get referenceOdometer {
    if (odometerOut <= 0) return odometerIn > 0 ? odometerIn : 0;
    if (odometerIn <= 0) return odometerOut;
    return odometerOut >= odometerIn ? odometerOut : odometerIn;
  }

  /// Next check-in must not be below the last completed check-out.
  double get minimumForCheckIn => odometerOut > 0 ? odometerOut : 0;

  /// Check-out must not be below the current check-in reading.
  double get minimumForCheckOut => odometerIn > 0 ? odometerIn : 0;
}
