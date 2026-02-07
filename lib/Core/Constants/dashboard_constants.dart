/// Dashboard layout and navigation constants.

const double kDashboardSidebarWidth = 260;
const double kDashboardBreakpoint = 800;

/// Drawer navigation items. [null] means Logout.
enum DashboardNavItem {
  dashboard,
  employee,
  assets,
  assignAssets,
  storeInventory,
  damagedAssets,
  repairManagement,
  assetReports,
  profile,
}

extension DashboardNavItemX on DashboardNavItem {
  String get title {
    switch (this) {
      case DashboardNavItem.dashboard:
        return 'Dashboard';
      case DashboardNavItem.employee:
        return 'Employee';
      case DashboardNavItem.assets:
        return 'Assets';
      case DashboardNavItem.assignAssets:
        return 'Assign Assets';
      case DashboardNavItem.storeInventory:
        return 'Store / Inventory';
      case DashboardNavItem.damagedAssets:
        return 'Damaged Assets';
      case DashboardNavItem.repairManagement:
        return 'Repair Management';
      case DashboardNavItem.assetReports:
        return 'Asset Reports';
      case DashboardNavItem.profile:
        return 'Profile';
    }
  }
}
