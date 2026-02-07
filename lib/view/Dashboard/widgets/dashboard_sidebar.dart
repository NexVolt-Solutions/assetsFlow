import 'package:asset_flow/Core/Constants/app_assets.dart';
import 'package:asset_flow/Core/Constants/app_colors.dart';
import 'package:asset_flow/Core/Constants/dashboard_constants.dart';
import 'package:asset_flow/Core/Constants/size_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DashboardSidebar extends StatelessWidget {
  final DashboardNavItem currentNav;
  final void Function(DashboardNavItem? item) onNavTap;

  const DashboardSidebar({
    super.key,
    required this.currentNav,
    required this.onNavTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: kDashboardSidebarWidth,
      decoration: const BoxDecoration(
        color: AppColors.pimaryColor,
        border: Border(
          right: BorderSide(color: AppColors.seconderyColor, width: 1),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: context.padSym(h: 20, v: 16),
              child: Row(
                children: [
                  SvgPicture.asset(AppAssets.logoIcon, width: 40, height: 40),
                  SizedBox(width: context.w(12)),
                  Expanded(
                    child: Text(
                      'Asset Flow',
                      style: TextStyle(
                        color: AppColors.headingColor,
                        fontSize: context.text(18),
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: context.padSym(h: 20, v: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.yellowColor,
                    child: Icon(
                      Icons.person,
                      color: AppColors.pimaryColor,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: context.w(12)),
                  Expanded(
                    child: Text(
                      'Hey! Welcome Back John',
                      style: TextStyle(
                        color: AppColors.headingColor,
                        fontSize: context.text(14),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: context.h(24)),
            Expanded(
              child: ListView(
                padding: context.padSym(h: 12, v: 0),
                children: [
                  DashboardNavTile(
                    icon: AppAssets.dashBoardIcon,
                    label: 'Dashboard',
                    navItem: DashboardNavItem.dashboard,
                    currentNav: currentNav,
                    onNavTap: onNavTap,
                  ),
                  DashboardNavTile(
                    icon: AppAssets.employeeIcon,
                    label: 'Employee',
                    navItem: DashboardNavItem.employee,
                    currentNav: currentNav,
                    onNavTap: onNavTap,
                  ),
                  DashboardNavTile(
                    icon: AppAssets.assetsIcon,
                    label: 'Assets',
                    navItem: DashboardNavItem.assets,
                    currentNav: currentNav,
                    onNavTap: onNavTap,
                  ),
                  DashboardNavTile(
                    icon: AppAssets.assignAssetIcon,
                    label: 'Assign Assets',
                    navItem: DashboardNavItem.assignAssets,
                    currentNav: currentNav,
                    onNavTap: onNavTap,
                  ),
                  DashboardNavTile(
                    icon: AppAssets.storeIcon,
                    label: 'Store / Inventory',
                    navItem: DashboardNavItem.storeInventory,
                    currentNav: currentNav,
                    onNavTap: onNavTap,
                  ),
                  DashboardNavTile(
                    icon: AppAssets.damageAssetsIcon,
                    label: 'Damaged Assets',
                    navItem: DashboardNavItem.damagedAssets,
                    currentNav: currentNav,
                    onNavTap: onNavTap,
                  ),
                  DashboardNavTile(
                    icon: AppAssets.repairIcon,
                    label: 'Repair Management',
                    navItem: DashboardNavItem.repairManagement,
                    currentNav: currentNav,
                    onNavTap: onNavTap,
                  ),
                  DashboardNavTile(
                    icon: Icons.assessment_outlined,
                    label: 'Asset Reports',
                    isIcon: true,
                    navItem: DashboardNavItem.assetReports,
                    currentNav: currentNav,
                    onNavTap: onNavTap,
                  ),
                  DashboardNavTile(
                    icon: Icons.person_outline,
                    label: 'Profile',
                    isIcon: true,
                    navItem: DashboardNavItem.profile,
                    currentNav: currentNav,
                    onNavTap: onNavTap,
                  ),
                ],
              ),
            ),
            Divider(color: AppColors.seconderyColor, height: 1),
            Padding(
              padding: context.padSym(h: 12, v: 12),
              child: DashboardNavTile(
                icon: Icons.logout,
                label: 'Logout',
                isIcon: true,
                navItem: null,
                currentNav: currentNav,
                onNavTap: onNavTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardNavTile extends StatelessWidget {
  final dynamic icon;
  final String label;
  final bool isIcon;
  final DashboardNavItem? navItem;
  final DashboardNavItem currentNav;
  final void Function(DashboardNavItem? item) onNavTap;

  const DashboardNavTile({
    super.key,
    required this.icon,
    required this.label,
    this.isIcon = false,
    required this.navItem,
    required this.currentNav,
    required this.onNavTap,
  });

  bool get isActive => navItem != null && currentNav == navItem;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.h(4)),
      child: Material(
        color: isActive ? AppColors.navItemActiveBg : Colors.transparent,
        borderRadius: BorderRadius.circular(context.radius(10)),
        child: InkWell(
          onTap: () => onNavTap(navItem),
          borderRadius: BorderRadius.circular(context.radius(10)),
          child: Padding(
            padding: context.padSym(h: 14, v: 12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 80;
                if (isNarrow) {
                  return Center(
                    child: isIcon
                        ? Icon(
                            icon as IconData,
                            color: AppColors.headingColor,
                            size: 22,
                          )
                        : SvgPicture.asset(
                            icon as String,
                            width: 22,
                            height: 22,
                            colorFilter: const ColorFilter.mode(
                              AppColors.headingColor,
                              BlendMode.srcIn,
                            ),
                          ),
                  );
                }
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isIcon)
                      Icon(
                        icon as IconData,
                        color: AppColors.headingColor,
                        size: 22,
                      )
                    else
                      SvgPicture.asset(
                        icon as String,
                        width: 22,
                        height: 22,
                        colorFilter: const ColorFilter.mode(
                          AppColors.headingColor,
                          BlendMode.srcIn,
                        ),
                      ),
                    SizedBox(width: context.w(12)),
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          color: AppColors.headingColor,
                          fontSize: context.text(14),
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
