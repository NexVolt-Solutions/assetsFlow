import 'package:asset_flow/Core/Constants/app_colors.dart';
import 'package:asset_flow/Core/Constants/size_extension.dart';
import 'package:flutter/material.dart';

/// Reusable label-value row (e.g. "Employee ID: EMP001").
class DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final double? labelWidth;

  const DetailRow({
    super.key,
    required this.label,
    required this.value,
    this.labelWidth = 130,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: labelWidth,
          child: Text(
            label,
            style: TextStyle(
              color: AppColors.subHeadingColor,
              fontSize: context.text(13),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: AppColors.headingColor,
              fontSize: context.text(13),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
