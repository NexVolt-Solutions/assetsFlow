import 'package:asset_flow/Core/Constants/app_colors.dart';
import 'package:asset_flow/Core/Constants/size_extension.dart';
import 'package:asset_flow/Core/Model/asset_model.dart';
import 'package:asset_flow/Core/Widget/detail_row.dart';
import 'package:flutter/material.dart';

/// Demo list of assets with condition Damaged (matches design: Razer, Corsair).
List<AssetItem> get kDamagedDemoAssets => [
  AssetItem(
    id: 'd1',
    name: 'Razer DeathAdder',
    assetId: 'MS-2024-002',
    category: 'Mouse',
    status: 'Damaged',
    brand: 'Razer',
    model: 'DeathAdder V3',
    condition: 'Damaged',
    assignedTo: '—',
    lastReturnedBy: 'James Okafor',
  ),
  AssetItem(
    id: 'd2',
    name: 'Corsair K95 RGB',
    assetId: 'KB-2024-003',
    category: 'Keyboard',
    status: 'Damaged',
    brand: 'Corsair',
    model: 'K95 RGB Platinum',
    condition: 'Damaged',
    assignedTo: '—',
    lastReturnedBy: 'Omar Hassan',
  ),
];

class DamagedAssetsScreenContent extends StatefulWidget {
  const DamagedAssetsScreenContent({super.key});

  @override
  State<DamagedAssetsScreenContent> createState() =>
      _DamagedAssetsScreenContentState();
}

class _DamagedAssetsScreenContentState
    extends State<DamagedAssetsScreenContent> {
  late List<AssetItem> _damagedAssets = kDamagedDemoAssets;

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

  void _onSendToRepair(AssetItem asset) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${asset.name} sent to repair'),
        backgroundColor: AppColors.sendToRepairButtonBg,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onRemove(AssetItem asset) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text(
          'Remove asset?',
          style: TextStyle(color: AppColors.headingColor),
        ),
        content: Text(
          '${asset.name} (${asset.assetId}) will be removed from damaged assets.',
          style: TextStyle(color: AppColors.subHeadingColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.subHeadingColor),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(
                () => _damagedAssets = _damagedAssets
                    .where((a) => a.id != asset.id)
                    .toList(),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${asset.name} removed'),
                  backgroundColor: AppColors.removeButtonBg,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(
              'Remove',
              style: TextStyle(color: AppColors.removeButtonBg),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final count = _damagedAssets.length;
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
            'Damaged Assets',
            style: TextStyle(
              color: AppColors.headingColor,
              fontSize: context.text(24),
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: context.h(4)),
          Text(
            '$count assets marked as damaged',
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
                  childAspectRatio: 1.3,
                ),
                itemCount: _damagedAssets.length,
                itemBuilder: (context, index) {
                  final asset = _damagedAssets[index];
                  return DamagedAssetCard(
                    key: ValueKey(asset.id),
                    asset: asset,
                    icon: _iconForCategory(asset.category),
                    onSendToRepair: () => _onSendToRepair(asset),
                    onRemove: () => _onRemove(asset),
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

/// Single damaged asset card: icon with border, Damaged pill, details, Send to Repair / Remove buttons.
class DamagedAssetCard extends StatelessWidget {
  final AssetItem asset;
  final IconData icon;
  final VoidCallback onSendToRepair;
  final VoidCallback onRemove;

  const DamagedAssetCard({
    super.key,
    required this.asset,
    required this.icon,
    required this.onSendToRepair,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.padAll(16),
      decoration: BoxDecoration(
        color: AppColors.damagedCardBg,
        borderRadius: BorderRadius.circular(context.radius(12)),
      ),
      clipBehavior: Clip.hardEdge,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            height: constraints.maxHeight,
            width: constraints.maxWidth,
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.headingColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.damagedIconBorder,
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          icon,
                          color: AppColors.damagedIconBorder,
                          size: 24,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: context.padSym(h: 10, v: 5),
                        decoration: BoxDecoration(
                          color: AppColors.damagedPillBg,
                          borderRadius: BorderRadius.circular(
                            context.radius(16),
                          ),
                        ),
                        child: Text(
                          'Damaged',
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
                  DetailRow(
                    label: 'Brand',
                    value: asset.brand,
                    labelWidth: 100,
                  ),
                  SizedBox(height: context.h(4)),
                  DetailRow(
                    label: 'Model',
                    value: asset.model,
                    labelWidth: 100,
                  ),
                  SizedBox(height: context.h(4)),
                  DetailRow(
                    label: 'Condition',
                    value: asset.condition,
                    labelWidth: 100,
                    valueColor: AppColors.damagedPillBg,
                  ),
                  if (asset.lastReturnedBy != null &&
                      asset.lastReturnedBy!.isNotEmpty) ...[
                    SizedBox(height: context.h(4)),
                    DetailRow(
                      label: 'Last: Returned to Store —',
                      value: asset.lastReturnedBy!,
                      labelWidth: 160,
                    ),
                  ],
                  SizedBox(height: context.h(16)),
                  Row(
                    children: [
                      Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: onSendToRepair,
                            borderRadius: BorderRadius.circular(
                              context.radius(10),
                            ),
                            child: Container(
                              padding: context.padSym(v: 10),
                              decoration: BoxDecoration(
                                color: AppColors.sendToRepairButtonBg
                                    .withOpacity(0.2),
                                borderRadius: BorderRadius.circular(
                                  context.radius(10),
                                ),
                                border: Border.all(
                                  color: AppColors.sendToRepairButtonBorder,
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Send to Repair',
                                  style: TextStyle(
                                    color: AppColors.sendToRepairButtonBg,
                                    fontSize: context.text(13),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: context.w(10)),
                      Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: onRemove,
                            borderRadius: BorderRadius.circular(
                              context.radius(10),
                            ),
                            child: Container(
                              padding: context.padSym(v: 10),
                              decoration: BoxDecoration(
                                color: AppColors.removeButtonBg.withOpacity(
                                  0.2,
                                ),
                                borderRadius: BorderRadius.circular(
                                  context.radius(10),
                                ),
                                border: Border.all(
                                  color: AppColors.removeButtonBorder,
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Remove',
                                  style: TextStyle(
                                    color: AppColors.removeButtonBg,
                                    fontSize: context.text(13),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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
