import 'package:asset_flow/Core/Constants/app_colors.dart';
import 'package:asset_flow/Core/Constants/size_extension.dart';
import 'package:flutter/material.dart';

/// Reusable filter chips. [T] is your enum (e.g. EmployeeFilter).
/// [labels] maps each value to display text.
class FilterChips<T> extends StatelessWidget {
  final T selected;
  final List<T> values;
  final String Function(T) labelBuilder;
  final ValueChanged<T> onSelected;

  const FilterChips({
    super.key,
    required this.selected,
    required this.values,
    required this.labelBuilder,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: values.map((value) {
        final isSelected = selected == value;
        return Material(
          color: isSelected ? AppColors.buttonColor : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(context.radius(8)),
          child: InkWell(
            onTap: () => onSelected(value),
            borderRadius: BorderRadius.circular(context.radius(8)),
            child: Padding(
              padding: context.padSym(h: 16, v: 10),
              child: Text(
                labelBuilder(value),
                style: TextStyle(
                  color: AppColors.headingColor,
                  fontSize: context.text(14),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
