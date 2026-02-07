import 'package:asset_flow/Core/Constants/app_colors.dart';
import 'package:asset_flow/Core/Constants/dashboard_constants.dart';
import 'package:asset_flow/Core/Constants/size_extension.dart';
import 'package:asset_flow/Core/utils/Routes/routes_name.dart';
import 'package:asset_flow/view/Dashboard/screens/assets_screen.dart';
import 'package:asset_flow/view/Dashboard/screens/employee_screen.dart';
import 'package:asset_flow/view/Dashboard/widgets/dashboard_app_bar.dart';
import 'package:asset_flow/view/Dashboard/widgets/dashboard_overview_content.dart';
import 'package:asset_flow/view/Dashboard/widgets/dashboard_sidebar.dart';
import 'package:asset_flow/view/Dashboard/widgets/nav_placeholder_screen.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _drawerOpen = true;
  DashboardNavItem _currentNav = DashboardNavItem.dashboard;

  void _onNavTap(DashboardNavItem? item) {
    if (item == null) {
      Navigator.pushReplacementNamed(context, RoutesName.loginScreen);
      return;
    }
    setState(() => _currentNav = item);
    if (context.width < kDashboardBreakpoint) {
      Navigator.pop(context);
    }
  }

  Widget _buildContent() {
    switch (_currentNav) {
      case DashboardNavItem.dashboard:
        return const DashboardOverviewContent();
      case DashboardNavItem.employee:
        return const EmployeeScreenContent();
      case DashboardNavItem.assets:
        return const AssetsScreenContent();
      case DashboardNavItem.assignAssets:
        return NavPlaceholderScreen(navItem: DashboardNavItem.assignAssets);
      case DashboardNavItem.storeInventory:
        return NavPlaceholderScreen(navItem: DashboardNavItem.storeInventory);
      case DashboardNavItem.damagedAssets:
        return NavPlaceholderScreen(navItem: DashboardNavItem.damagedAssets);
      case DashboardNavItem.repairManagement:
        return NavPlaceholderScreen(navItem: DashboardNavItem.repairManagement);
      case DashboardNavItem.assetReports:
        return NavPlaceholderScreen(navItem: DashboardNavItem.assetReports);
      case DashboardNavItem.profile:
        return NavPlaceholderScreen(navItem: DashboardNavItem.profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = context.width >= kDashboardBreakpoint;
    final usePersistentDrawer = isWide;

    if (usePersistentDrawer) {
      return Scaffold(
        backgroundColor: AppColors.pimaryColor,
        body: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: _drawerOpen ? kDashboardSidebarWidth : 0,
              decoration: const BoxDecoration(
                color: AppColors.pimaryColor,
                border: Border(
                  right: BorderSide(color: AppColors.seconderyColor, width: 1),
                ),
              ),
              clipBehavior: Clip.hardEdge,
              child: _drawerOpen
                  ? LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth < 120) {
                          return const SizedBox.shrink();
                        }
                        return DashboardSidebar(
                          currentNav: _currentNav,
                          onNavTap: _onNavTap,
                        );
                      },
                    )
                  : null,
            ),
            Expanded(
              child: Column(
                children: [
                  DashboardAppBar(
                    title: _currentNav.title,
                    onMenuTap: () => setState(() => _drawerOpen = !_drawerOpen),
                    showMenuIcon: true,
                  ),
                  Expanded(child: _buildContent()),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.pimaryColor,
      appBar: _buildAppBar(
        context,
        _currentNav.title,
        () => Scaffold.of(context).openDrawer(),
      ),
      drawer: Drawer(
        backgroundColor: AppColors.pimaryColor,
        child: DashboardSidebar(currentNav: _currentNav, onNavTap: _onNavTap),
      ),
      body: _buildContent(),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    String title,
    VoidCallback onMenuTap,
  ) {
    return AppBar(
      backgroundColor: AppColors.pimaryColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: AppColors.headingColor),
        onPressed: onMenuTap,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: AppColors.headingColor,
          fontSize: context.text(20),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
