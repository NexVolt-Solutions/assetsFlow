import 'package:asset_flow/Core/Constants/app_colors.dart';
import 'package:asset_flow/Core/Constants/size_extension.dart';
import 'package:asset_flow/Core/Model/dashboard_model.dart';
import 'package:asset_flow/Core/Widget/section_title.dart';
import 'package:asset_flow/Core/Widget/stat_card.dart';
import 'package:asset_flow/viewModel/dashboard_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardOverviewContent extends StatefulWidget {
  const DashboardOverviewContent({super.key});

  @override
  State<DashboardOverviewContent> createState() => _DashboardOverviewContentState();
}

class _DashboardOverviewContentState extends State<DashboardOverviewContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardViewModel>().fetchDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardViewModel>(
      builder: (context, vm, child) {
        if (vm.isLoading && vm.data == null) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(context.h(48)),
              child: const CircularProgressIndicator(),
            ),
          );
        }
        if (vm.errorMessage != null && vm.data == null) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(context.h(24)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    vm.errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.subHeadingColor,
                      fontSize: context.text(14),
                    ),
                  ),
                  SizedBox(height: context.h(16)),
                  TextButton.icon(
                    onPressed: vm.fetchDashboard,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }
        final data = vm.data;
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            context.w(24),
            0,
            context.w(24),
            context.h(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Overview of your asset management system',
                style: TextStyle(
                  color: AppColors.subHeadingColor,
                  fontSize: context.text(14),
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: context.h(28)),
              SectionTitle(title: 'Employees'),
              SizedBox(height: context.h(12)),
              _EmployeeCards(data: data),
              SizedBox(height: context.h(28)),
              SectionTitle(title: 'Assets'),
              SizedBox(height: context.h(12)),
              _AssetCards(data: data),
              SizedBox(height: context.h(28)),
              SectionTitle(title: 'Recent Employees'),
              SizedBox(height: context.h(12)),
              _RecentEmployeesList(data: data),
              SizedBox(height: context.h(28)),
              SectionTitle(title: 'Recent Assets'),
              SizedBox(height: context.h(12)),
              _RecentAssetsList(data: data),
            ],
          ),
        );
      },
    );
  }
}

class _EmployeeCards extends StatelessWidget {
  final DashboardData? data;

  const _EmployeeCards({this.data});

  @override
  Widget build(BuildContext context) {
    final total = data?.totalEmployees ?? 0;
    final active = data?.activeEmployees ?? 0;
    final resigned = data?.resignedEmployees ?? 0;
    final onHold = data?.onHoldEmployees ?? 0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 700
            ? 4
            : (constraints.maxWidth > 450 ? 2 : 1);
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.5,
          children: [
            StatCard(
              value: '$total',
              label: 'Total Employee',
              icon: Icons.people_outline,
            ),
            StatCard(
              value: '$active',
              label: 'Active',
              icon: Icons.check_circle_outline,
            ),
            StatCard(value: '$resigned', label: 'Resigned', icon: Icons.refresh),
            StatCard(
              value: '$onHold',
              label: 'On Hold',
              icon: Icons.indeterminate_check_box_outlined,
            ),
          ],
        );
      },
    );
  }
}

class _AssetCards extends StatelessWidget {
  final DashboardData? data;

  const _AssetCards({this.data});

  @override
  Widget build(BuildContext context) {
    final total = data?.totalAssets ?? 0;
    final inUse = data?.assetsInUse ?? 0;
    final inStore = data?.assetsInStore ?? 0;
    final damaged = data?.damagedAssets ?? 0;
    final underRepair = data?.assetsUnderRepair ?? 0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 700
            ? 4
            : (constraints.maxWidth > 450 ? 2 : 1);
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.5,
          children: [
            StatCard(
              value: '$total',
              label: 'Total Assets',
              icon: Icons.description_outlined,
            ),
            StatCard(value: '$inUse', label: 'In Use', icon: Icons.computer),
            StatCard(
              value: '$inStore',
              label: 'In Store',
              icon: Icons.storefront_outlined,
            ),
            StatCard(
              value: '$damaged',
              label: 'Damaged',
              icon: Icons.warning_amber_outlined,
            ),
            StatCard(
              value: '$underRepair',
              label: 'Under Repair',
              icon: Icons.build_outlined,
            ),
          ],
        );
      },
    );
  }
}

String _initialsFromName(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty) return '?';
  if (parts.length == 1) {
    final s = parts[0];
    return s.length >= 2 ? s.substring(0, 2).toUpperCase() : s.toUpperCase();
  }
  return (parts[0].isNotEmpty ? parts[0][0] : '') +
      (parts[1].isNotEmpty ? parts[1][0] : '');
}

class _RecentEmployeesList extends StatelessWidget {
  final DashboardData? data;

  const _RecentEmployeesList({this.data});

  @override
  Widget build(BuildContext context) {
    final items = data?.recentEmployees ?? [];
    if (items.isEmpty) {
      return Container(
        padding: context.padSym(h: 16, v: 24),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(context.radius(12)),
        ),
        child: Center(
          child: Text(
            'No recent employees',
            style: TextStyle(
              color: AppColors.subHeadingColor,
              fontSize: context.text(14),
            ),
          ),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(context.radius(12)),
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0) Divider(height: 1, color: AppColors.seconderyColor),
            _RecentEmployeeTile(
              name: items[i].name,
              role: items[i].department,
              initials: _initialsFromName(items[i].name),
              status: items[i].status,
            ),
          ],
        ],
      ),
    );
  }
}

class _RecentEmployeeTile extends StatelessWidget {
  final String name;
  final String role;
  final String initials;
  final String status;

  const _RecentEmployeeTile({
    required this.name,
    required this.role,
    required this.initials,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final isResigned = status.toLowerCase().contains('resign');
    return Padding(
      padding: context.padSym(h: 16, v: 14),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.listAvatarBg,
            child: Text(
              initials,
              style: TextStyle(
                color: AppColors.headingColor,
                fontSize: context.text(14),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: context.w(14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: AppColors.headingColor,
                    fontSize: context.text(15),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: context.h(2)),
                Text(
                  role,
                  style: TextStyle(
                    color: AppColors.subHeadingColor,
                    fontSize: context.text(13),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: context.padSym(h: 10, v: 6),
            decoration: BoxDecoration(
              color: isResigned
                  ? AppColors.redColor
                  : AppColors.statusPillActive,
              borderRadius: BorderRadius.circular(context.radius(20)),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: AppColors.headingColor,
                fontSize: context.text(12),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentAssetsList extends StatelessWidget {
  final DashboardData? data;

  const _RecentAssetsList({this.data});

  @override
  Widget build(BuildContext context) {
    final items = data?.recentAssets ?? [];
    if (items.isEmpty) {
      return Container(
        padding: context.padSym(h: 16, v: 24),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(context.radius(12)),
        ),
        child: Center(
          child: Text(
            'No recent assets',
            style: TextStyle(
              color: AppColors.subHeadingColor,
              fontSize: context.text(14),
            ),
          ),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(context.radius(12)),
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0) Divider(height: 1, color: AppColors.seconderyColor),
            _RecentAssetTile(
              name: items[i].name,
              subText: items[i].category,
              status: items[i].currentStatus,
            ),
          ],
        ],
      ),
    );
  }
}

class _RecentAssetTile extends StatelessWidget {
  final String name;
  final String subText;
  final String status;

  const _RecentAssetTile({
    required this.name,
    required this.subText,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.padSym(h: 16, v: 14),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.listAvatarBg,
            child: Icon(Icons.description_outlined,
                color: AppColors.headingColor, size: 24),
          ),
          SizedBox(width: context.w(14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: AppColors.headingColor,
                    fontSize: context.text(15),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: context.h(2)),
                Text(
                  subText,
                  style: TextStyle(
                    color: AppColors.subHeadingColor,
                    fontSize: context.text(13),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: context.padSym(h: 10, v: 6),
            decoration: BoxDecoration(
              color: AppColors.statusPillActive,
              borderRadius: BorderRadius.circular(context.radius(20)),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: AppColors.headingColor,
                fontSize: context.text(12),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
