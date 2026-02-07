import 'package:asset_flow/Core/Constants/app_colors.dart';
import 'package:asset_flow/Core/Constants/size_extension.dart';
import 'package:flutter/material.dart';

/// Reusable section heading (e.g. "Employees", "Assets").
class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: AppColors.headingColor,
        fontSize: context.text(18),
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
