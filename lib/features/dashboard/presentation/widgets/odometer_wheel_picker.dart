import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Wheel picker for odometer: 6 whole digits + 1 decimal (e.g. 123456.7).
class OdometerWheelPicker extends StatefulWidget {
  final ValueChanged<double> onChanged;
  final double initialValue;
  final bool readOnly;

  const OdometerWheelPicker({
    super.key,
    required this.onChanged,
    this.initialValue = 0,
    this.readOnly = false,
  });

  @override
  State<OdometerWheelPicker> createState() => _OdometerWheelPickerState();
}

class _OdometerWheelPickerState extends State<OdometerWheelPicker> {
  static const int _itemExtent = 36;
  static const int _wholeDigitCount = 6;
  static const int _digitCount = 7; // 6 whole + 1 fractional
  static const double _maxValue = 999999.9;

  late final List<int> _digits;
  late final List<FixedExtentScrollController> _controllers;

  @override
  void initState() {
    super.initState();
    _digits = _valueToDigits(widget.initialValue);
    _controllers = List.generate(
      _digitCount,
      (index) => FixedExtentScrollController(initialItem: _digits[index]),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onChanged(value);
    });
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  double get value {
    final whole = _digits[0] * 100000 +
        _digits[1] * 10000 +
        _digits[2] * 1000 +
        _digits[3] * 100 +
        _digits[4] * 10 +
        _digits[5];
    return whole + _digits[6] / 10.0;
  }

  String get formattedValue {
    final whole = _digits[0] * 100000 +
        _digits[1] * 10000 +
        _digits[2] * 1000 +
        _digits[3] * 100 +
        _digits[4] * 10 +
        _digits[5];
    return '$whole.${_digits[6]}';
  }

  List<int> _valueToDigits(double value) {
    if (value <= 0) {
      return List.filled(_digitCount, 0);
    }

    final clamped = value.clamp(0.0, _maxValue);
    final whole = clamped.floor();
    final decimal = ((clamped - whole) * 10).round().clamp(0, 9);

    return [
      (whole ~/ 100000) % 10,
      (whole ~/ 10000) % 10,
      (whole ~/ 1000) % 10,
      (whole ~/ 100) % 10,
      (whole ~/ 10) % 10,
      whole % 10,
      decimal,
    ];
  }

  Widget _buildDigitPicker(int index, Color digitColor) {
    return CupertinoPicker(
      scrollController: _controllers[index],
      itemExtent: _itemExtent.toDouble(),
      magnification: 1.08,
      squeeze: 1.05,
      useMagnifier: true,
      onSelectedItemChanged: (item) {
        setState(() => _digits[index] = item);
        widget.onChanged(value);
      },
      children: List.generate(
        10,
        (digit) => Center(
          child: Text(
            '$digit',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: digitColor,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final digitColor = scheme.onSurface;
    final wheelBg =
        isDark ? AppTheme.darkSurfaceElevated : Colors.grey.shade100;
    final selectionBg =
        isDark ? AppTheme.darkSurface : Colors.white.withValues(alpha: 0.9);
    final selectionBorder =
        isDark ? AppTheme.darkBorder : Colors.grey.shade300;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$formattedValue km',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        IgnorePointer(
          ignoring: widget.readOnly,
          child: Opacity(
            opacity: widget.readOnly ? 0.75 : 1,
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                color: wheelBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: _itemExtent.toDouble(),
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: selectionBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: selectionBorder),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        for (int i = 0; i < _wholeDigitCount; i++) ...[
                          Expanded(child: _buildDigitPicker(i, digitColor)),
                        ],
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            '.',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: digitColor,
                            ),
                          ),
                        ),
                        Expanded(child: _buildDigitPicker(6, digitColor)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
