import 'package:asset_flow/Core/Constants/app_colors.dart';
import 'package:asset_flow/Core/Constants/dashboard_constants.dart';
import 'package:asset_flow/Core/Constants/size_extension.dart';
import 'package:flutter/material.dart';

class NavPlaceholderScreen extends StatelessWidget {
  final DashboardNavItem navItem;

  const NavPlaceholderScreen({super.key, required this.navItem});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: context.padAll(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_outlined,
              size: 64,
              color: AppColors.subHeadingColor,
            ),
            SizedBox(height: context.h(16)),
            Text(
              navItem.title,
              style: TextStyle(
                color: AppColors.headingColor,
                fontSize: context.text(22),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.h(8)),
            Text(
              'Screen content goes here',
              style: TextStyle(
                color: AppColors.subHeadingColor,
                fontSize: context.text(14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
