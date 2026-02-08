import 'package:asset_flow/Core/Constants/app_colors.dart';
import 'package:asset_flow/Core/Constants/size_extension.dart';
import 'package:asset_flow/Core/Model/asset_model.dart';
import 'package:asset_flow/Core/Widget/detail_row.dart';
import 'package:asset_flow/viewModel/store_inventory_screen_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StoreInventoryScreenContent extends StatefulWidget {
  const StoreInventoryScreenContent({super.key});

  @override
  State<StoreInventoryScreenContent> createState() =>
      _StoreInventoryScreenContentState();
}

class _StoreInventoryScreenContentState
    extends State<StoreInventoryScreenContent> {
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StoreInventoryScreenViewModel>().fetchStoreAssets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StoreInventoryScreenViewModel>(
      builder: (context, vm, child) {
        if (vm.isLoading && vm.storeAssets.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(context.h(48)),
              child: const CircularProgressIndicator(),
            ),
          );
        }
        if (vm.errorMessage != null && vm.storeAssets.isEmpty) {
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
                    onPressed: vm.fetchStoreAssets,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }
        final storeAssets = vm.storeAssets;
        final count = storeAssets.length;
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
                    itemCount: storeAssets.length,
                    itemBuilder: (context, index) {
                      final asset = storeAssets[index];
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
      },
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
                          borderRadius: BorderRadius.circular(
                            context.radius(16),
                          ),
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
            ),
          );
        },
      ),
    );
  }
}
