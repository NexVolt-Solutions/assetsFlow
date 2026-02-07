import 'package:asset_flow/Core/Constants/app_colors.dart';
import 'package:asset_flow/Core/Constants/size_extension.dart';
import 'package:asset_flow/Core/Model/asset_model.dart';
import 'package:asset_flow/Core/Widget/detail_row.dart';
import 'package:flutter/material.dart';

/// Demo list of assets currently in store (matches design: MacBook, Samsung, Sony).
List<AssetItem> get kStoreDemoAssets => [
  AssetItem(
    id: 's1',
    name: 'MacBook Pro 16"',
    assetId: 'LP-2024-001',
    category: 'Laptop',
    status: 'In Store',
    brand: 'Apple',
    model: 'MacBook Pro',
    condition: 'Good',
    assignedTo: '—',
    lastReturnedBy: 'James Okafor',
  ),
  AssetItem(
    id: 's2',
    name: 'Samsung Galaxy S24',
    assetId: 'MB-2024-002',
    category: 'Mobile',
    status: 'In Store',
    brand: 'Samsung',
    model: 'Galaxy S24',
    condition: 'Good',
    assignedTo: '—',
    lastReturnedBy: 'Omar Hassan',
  ),
  AssetItem(
    id: 's3',
    name: 'Sony WH-1000XM5',
    assetId: 'HS-2024-002',
    category: 'Headset',
    status: 'In Store',
    brand: 'Sony',
    model: 'WH-1000XM5',
    condition: 'Good',
    assignedTo: '—',
  ),
];

class StoreInventoryScreenContent extends StatefulWidget {
  const StoreInventoryScreenContent({super.key});

  @override
  State<StoreInventoryScreenContent> createState() =>
      _StoreInventoryScreenContentState();
}

class _StoreInventoryScreenContentState
    extends State<StoreInventoryScreenContent> {
  late List<AssetItem> _storeAssets = kStoreDemoAssets;

  static IconData _iconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'laptop':
        return Icons.laptop_mac;
      case 'mouse':
        return Icons.mouse;
      case 'keyboard':
        return Icons.keyboard;
      case 'monitor':
        return Icons.monitor;
      case 'mobile':
        return Icons.smartphone;
      case 'headset':
        return Icons.headset;
      default:
        return Icons.devices_other;
    }
  }

  @override
  Widget build(BuildContext context) {
    final count = _storeAssets.length;
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
            'Store / Inventory',
            style: TextStyle(
              color: AppColors.headingColor,
              fontSize: context.text(24),
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: context.h(4)),
          Text(
            '$count assets available in store',
            style: TextStyle(
              color: AppColors.subHeadingColor,
              fontSize: context.text(14),
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: context.h(24)),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;

              final crossAxisCount = width > 900 ? 3 : (width > 600 ? 2 : 1);
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: context.h(16),
                  crossAxisSpacing: context.w(16),
                  childAspectRatio: 1.5,
                ),
                itemCount: _storeAssets.length,
                itemBuilder: (context, index) {
                  final asset = _storeAssets[index];
                  return StoreItemCard(
                    asset: asset,
                    icon: _iconForCategory(asset.category),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Single in-store asset card: icon, Available pill, name, id, Brand/Model/Condition, optional last returned.
class StoreItemCard extends StatelessWidget {
  final AssetItem asset;
  final IconData icon;

  const StoreItemCard({super.key, required this.asset, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.padAll(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(context.radius(12)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: constraints.maxWidth,
              maxHeight: constraints.maxHeight,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.listAvatarBg,
                      child: Icon(
                        icon,
                        color: AppColors.headingColor,
                        size: 26,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: context.padSym(h: 10, v: 5),
                      decoration: BoxDecoration(
                        color: AppColors.statusPillActive,
                        borderRadius: BorderRadius.circular(context.radius(16)),
                      ),
                      child: Text(
                        'Available',
                        style: TextStyle(
                          color: AppColors.headingColor,
                          fontSize: context.text(11),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.h(12)),
                Text(
                  asset.name,
                  style: TextStyle(
                    color: AppColors.headingColor,
                    fontSize: context.text(15),
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: context.h(4)),
                Text(
                  asset.assetId,
                  style: TextStyle(
                    color: AppColors.subHeadingColor,
                    fontSize: context.text(13),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: context.h(12)),
                DetailRow(label: 'Brand', value: asset.brand, labelWidth: 70),
                SizedBox(height: context.h(4)),
                DetailRow(label: 'Model', value: asset.model, labelWidth: 70),
                SizedBox(height: context.h(4)),
                DetailRow(
                  label: 'Condition',
                  value: asset.condition,
                  labelWidth: 70,
                ),
                if (asset.lastReturnedBy != null &&
                    asset.lastReturnedBy!.isNotEmpty) ...[
                  SizedBox(height: context.h(10)),
                  Text(
                    'Last: Returned to Store — ${asset.lastReturnedBy}',
                    style: TextStyle(
                      color: AppColors.subHeadingColor,
                      fontSize: context.text(12),
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
