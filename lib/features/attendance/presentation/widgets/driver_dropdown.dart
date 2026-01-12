import 'package:flutter/material.dart';
import '../../../../core/utils/animations.dart';
import '../../../../core/widgets/styled_card.dart';
import '../../domain/entities/driver.dart';

class DriverDropdown extends StatelessWidget {
  final List<Driver> drivers;
  final Driver? selectedDriver;
  final Function(Driver?) onDriverSelected;

  const DriverDropdown({
    super.key,
    required this.drivers,
    this.selectedDriver,
    required this.onDriverSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FadeSlideAnimation(
      delay: const Duration(milliseconds: 300),
      beginOffset: const Offset(0, 0.2),
      child: StyledCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: DropdownButtonFormField<Driver>(
          value: selectedDriver,
          decoration: InputDecoration(
            labelText: 'Select Driver',
            labelStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          items: [
            const DropdownMenuItem<Driver>(
              value: null,
              child: Text('All Drivers'),
            ),
            ...drivers.map((driver) {
              return DropdownMenuItem<Driver>(
                value: driver,
                child: Text(driver.name),
              );
            }),
          ],
          onChanged: onDriverSelected,
          isExpanded: true,
          icon: Icon(
            Icons.arrow_drop_down,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

