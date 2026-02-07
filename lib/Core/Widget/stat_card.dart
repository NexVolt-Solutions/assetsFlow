import 'package:asset_flow/Core/Constants/app_colors.dart';
import 'package:asset_flow/Core/Constants/size_extension.dart';
import 'package:flutter/material.dart';

/// Reusable metric card with icon, value, and label.
class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const StatCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.padSym(h: 16, v: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(context.radius(12)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: constraints.maxWidth,
                maxHeight: constraints.maxHeight,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        value,
                        style: TextStyle(
                          color: AppColors.headingColor,
                          fontSize: context.text(24),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: context.h(16)),
                      Text(
                        label,
                        style: TextStyle(
                          color: AppColors.subHeadingColor,
                          fontSize: context.text(13),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: context.w(12)),
                  Container(
                    padding: context.padSym(h: 8, v: 8),
                    decoration: BoxDecoration(
                      color: AppColors.contColor,
                      borderRadius: BorderRadius.circular(context.radius(12)),
                    ),
                    child: Icon(icon, color: AppColors.headingColor, size: 28),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
