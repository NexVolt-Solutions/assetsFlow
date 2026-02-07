import 'package:asset_flow/Core/Constants/app_colors.dart';
import 'package:asset_flow/Core/Constants/size_extension.dart';
import 'package:asset_flow/Core/Widget/section_title.dart';
import 'package:asset_flow/Core/Widget/stat_card.dart';
import 'package:flutter/material.dart';

class DashboardOverviewContent extends StatelessWidget {
  const DashboardOverviewContent({super.key});

  @override
  Widget build(BuildContext context) {
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
          _EmployeeCards(),
          SizedBox(height: context.h(28)),
          SectionTitle(title: 'Assets'),
          SizedBox(height: context.h(12)),
          _AssetCards(),
          SizedBox(height: context.h(28)),
          SectionTitle(title: 'Recent Employees'),
          SizedBox(height: context.h(12)),
          _RecentEmployees(),
          SizedBox(height: context.h(28)),
          SectionTitle(title: 'Recent Assets'),
          SizedBox(height: context.h(12)),
          _RecentAssets(),
        ],
      ),
    );
  }
}

class _EmployeeCards extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
              value: '8',
              label: 'Total Employee',
              icon: Icons.people_outline,
            ),
            StatCard(
              value: '5',
              label: 'Active',
              icon: Icons.check_circle_outline,
            ),
            StatCard(value: '2', label: 'Resigned', icon: Icons.refresh),
            StatCard(
              value: '1',
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
  @override
  Widget build(BuildContext context) {
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
              value: '18',
              label: 'Total Assets',
              icon: Icons.description_outlined,
            ),
            StatCard(value: '12', label: 'In Use', icon: Icons.computer),
            StatCard(
              value: '3',
              label: 'In Store',
              icon: Icons.storefront_outlined,
            ),
            StatCard(
              value: '2',
              label: 'Damaged',
              icon: Icons.warning_amber_outlined,
            ),
            StatCard(
              value: '1',
              label: 'Under Repair',
              icon: Icons.build_outlined,
            ),
          ],
        );
      },
    );
  }
}

class _RecentEmployees extends StatelessWidget {
  static const _items = [
    ('Aisha Patel', 'Engineering', 'AP', 'Active'),
    ('Marcus Johnson', 'Design', 'MJ', 'Active'),
    ('James Wilson', 'Operations', 'JW', 'Resigned'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(context.radius(12)),
      ),
      child: Column(
        children: [
          for (int i = 0; i < _items.length; i++) ...[
            if (i > 0) Divider(height: 1, color: AppColors.seconderyColor),
            _RecentEmployeeTile(
              name: _items[i].$1,
              role: _items[i].$2,
              initials: _items[i].$3,
              status: _items[i].$4,
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
    final isResigned = status == 'Resigned';
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

class _RecentAssets extends StatelessWidget {
  static const _items = [
    ('MacBook Pro 16', 'LP-2024-001', Icons.laptop_mac),
    ('Logitech MX Master', 'MS-2024-002', Icons.mouse),
    ('Apple Magic Keyboard', 'KB-2024-003', Icons.keyboard),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(context.radius(12)),
      ),
      child: Column(
        children: [
          for (int i = 0; i < _items.length; i++) ...[
            if (i > 0) Divider(height: 1, color: AppColors.seconderyColor),
            _RecentAssetTile(
              name: _items[i].$1,
              assetId: _items[i].$2,
              icon: _items[i].$3,
            ),
          ],
        ],
      ),
    );
  }
}

class _RecentAssetTile extends StatelessWidget {
  final String name;
  final String assetId;
  final IconData icon;

  const _RecentAssetTile({
    required this.name,
    required this.assetId,
    required this.icon,
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
            child: Icon(icon, color: AppColors.headingColor, size: 24),
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
                  assetId,
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
              'In Use',
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
