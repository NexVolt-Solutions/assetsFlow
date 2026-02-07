import 'package:asset_flow/Core/Constants/app_colors.dart';
import 'package:asset_flow/Core/Constants/size_extension.dart';
import 'package:flutter/material.dart';

class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onMenuTap;
  final bool showMenuIcon;

  const DashboardAppBar({
    super.key,
    required this.title,
    required this.onMenuTap,
    this.showMenuIcon = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.pimaryColor,
      padding: context.padSym(h: 24, v: 12),
      child: Row(
        children: [
          if (showMenuIcon)
            IconButton(
              icon: const Icon(Icons.menu, color: AppColors.headingColor),
              onPressed: onMenuTap,
            ),
          if (showMenuIcon) SizedBox(width: context.w(8)),
          Text(
            title,
            style: TextStyle(
              color: AppColors.headingColor,
              fontSize: context.text(24),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
