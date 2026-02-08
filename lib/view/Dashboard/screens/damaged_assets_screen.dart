import 'package:asset_flow/Core/Constants/app_colors.dart';
import 'package:asset_flow/Core/Constants/size_extension.dart';
import 'package:asset_flow/Core/Model/asset_model.dart';
import 'package:asset_flow/Core/Widget/detail_row.dart';
import 'package:asset_flow/viewModel/damaged_assets_screen_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DamagedAssetsScreenContent extends StatefulWidget {
  const DamagedAssetsScreenContent({super.key});

  @override
  State<DamagedAssetsScreenContent> createState() =>
      _DamagedAssetsScreenContentState();
}

class _DamagedAssetsScreenContentState
    extends State<DamagedAssetsScreenContent> {
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

  Future<void> _onSendToRepair(BuildContext context, AssetItem asset) async {
    final result = await showDialog<({String notes, double? cost})>(
      context: context,
      builder: (ctx) => _SendToRepairDialog(assetName: asset.name),
    );
    if (result == null || !mounted) return;
    final vm = context.read<DamagedAssetsScreenViewModel>();
    final success = await vm.sendToRepair(
      asset.id,
      repairNotes: result.notes.isEmpty ? null : result.notes,
      repairCost: result.cost,
    );
    if (!mounted) return;
    if (success) {
      vm.clearError();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${asset.name} sent to repair'),
          backgroundColor: AppColors.sendToRepairButtonBg,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.errorMessage ?? 'Failed to send to repair'),
          backgroundColor: AppColors.redColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _onRemove(BuildContext context, AssetItem asset) {
    final vm = context.read<DamagedAssetsScreenViewModel>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text(
          'Remove asset?',
          style: TextStyle(color: AppColors.headingColor),
        ),
        content: Text(
          '${asset.name} (${asset.assetId}) will be removed from damaged assets permanently.',
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
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await vm.removeDamagedAsset(asset.id);
              if (!mounted) return;
              if (success) {
                vm.clearError();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${asset.name} removed'),
                    backgroundColor: AppColors.removeButtonBg,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      vm.errorMessage ?? 'Failed to remove asset',
                    ),
                    backgroundColor: AppColors.redColor,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DamagedAssetsScreenViewModel>().fetchDamagedAssets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DamagedAssetsScreenViewModel>(
      builder: (context, vm, child) {
        if (vm.isLoading && vm.items.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(context.h(48)),
              child: const CircularProgressIndicator(),
            ),
          );
        }
        if (vm.errorMessage != null && vm.items.isEmpty) {
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
                    onPressed: vm.fetchDamagedAssets,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }
        final damagedAssets = vm.items;
        final count = damagedAssets.length;
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
                    itemCount: damagedAssets.length,
                    itemBuilder: (context, index) {
                      final asset = damagedAssets[index];
                      return DamagedAssetCard(
                        key: ValueKey(asset.id),
                        asset: asset,
                        icon: _iconForCategory(asset.category),
                        onSendToRepair: () => _onSendToRepair(context, asset),
                        onRemove: () => _onRemove(context, asset),
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

/// Dialog to optionally enter repair notes and cost before sending to repair.
class _SendToRepairDialog extends StatefulWidget {
  final String assetName;

  const _SendToRepairDialog({required this.assetName});

  @override
  State<_SendToRepairDialog> createState() => _SendToRepairDialogState();
}

class _SendToRepairDialogState extends State<_SendToRepairDialog> {
  final _notesController = TextEditingController();
  final _costController = TextEditingController();
  String? _costError;

  @override
  void dispose() {
    _notesController.dispose();
    _costController.dispose();
    super.dispose();
  }

  void _submit() {
    final costStr = _costController.text.trim();
    double? cost;
    if (costStr.isNotEmpty) {
      cost = double.tryParse(costStr);
      if (cost == null || cost < 0) {
        setState(() => _costError = 'Enter a valid amount');
        return;
      }
    }
    setState(() => _costError = null);
    Navigator.of(context).pop((notes: _notesController.text.trim(), cost: cost));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Send to repair'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.assetName,
              style: TextStyle(
                color: AppColors.subHeadingColor,
                fontSize: context.text(13),
              ),
            ),
            SizedBox(height: context.h(16)),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Repair notes (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            SizedBox(height: context.h(12)),
            TextField(
              controller: _costController,
              decoration: InputDecoration(
                labelText: 'Repair cost (optional)',
                border: const OutlineInputBorder(),
                errorText: _costError,
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() => _costError = null),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Send'),
        ),
      ],
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
