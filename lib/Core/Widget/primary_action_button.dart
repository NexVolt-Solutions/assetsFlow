import 'package:asset_flow/Core/Constants/app_colors.dart';
import 'package:asset_flow/Core/Constants/size_extension.dart';
import 'package:flutter/material.dart';

/// Primary action button with optional leading icon (e.g. "+ Add Employees").
class PrimaryActionButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;

  const PrimaryActionButton({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.buttonColor,
      borderRadius: BorderRadius.circular(context.radius(8)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(context.radius(8)),
        child: Padding(
          padding: context.padSym(h: 16, v: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, color: AppColors.headingColor, size: 20),
                SizedBox(width: context.w(8)),
              ],
              Text(
                label,
                style: TextStyle(
                  color: AppColors.headingColor,
                  fontSize: context.text(14),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
