import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Wheel picker for odometer: 5 whole digits + 1 decimal (e.g. 12345.6).
class OdometerWheelPicker extends StatefulWidget {
  final ValueChanged<double> onChanged;
  final double initialValue;

  const OdometerWheelPicker({
    super.key,
    required this.onChanged,
    this.initialValue = 0,
  });

  @override
  State<OdometerWheelPicker> createState() => _OdometerWheelPickerState();
}

class _OdometerWheelPickerState extends State<OdometerWheelPicker> {
  static const int _itemExtent = 36;

  late final List<int> _digits;
  late final List<FixedExtentScrollController> _controllers;

  @override
  void initState() {
    super.initState();
    _digits = _valueToDigits(widget.initialValue);
    _controllers = List.generate(
      6,
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
    final whole = _digits[0] * 10000 +
        _digits[1] * 1000 +
        _digits[2] * 100 +
        _digits[3] * 10 +
        _digits[4];
    return whole + _digits[5] / 10.0;
  }

  String get formattedValue {
    final whole = _digits[0] * 10000 +
        _digits[1] * 1000 +
        _digits[2] * 100 +
        _digits[3] * 10 +
        _digits[4];
    return '$whole.${_digits[5]}';
  }

  List<int> _valueToDigits(double value) {
    if (value <= 0) {
      return List.filled(6, 0);
    }

    final clamped = value.clamp(0.0, 99999.9);
    final whole = clamped.floor();
    final decimal = ((clamped - whole) * 10).round().clamp(0, 9);

    return [
      (whole ~/ 10000) % 10,
      (whole ~/ 1000) % 10,
      (whole ~/ 100) % 10,
      (whole ~/ 10) % 10,
      whole % 10,
      decimal,
    ];
  }

  Widget _buildDigitPicker(int index) {
    return CupertinoPicker(
      scrollController: _controllers[index],
      itemExtent: _itemExtent.toDouble(),
      magnification: 1.12,
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
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${formattedValue} km',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppTheme.mitsuiDarkBlue,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: _itemExtent.toDouble(),
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    for (int i = 0; i < 5; i++) ...[
                      Expanded(child: _buildDigitPicker(i)),
                    ],
                    const Padding(
                      padding: EdgeInsets.only(bottom: 2),
                      child: Text(
                        '.',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Expanded(child: _buildDigitPicker(5)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
