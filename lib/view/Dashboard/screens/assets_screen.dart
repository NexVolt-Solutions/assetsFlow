import 'package:asset_flow/Core/Constants/app_colors.dart';
import 'package:asset_flow/Core/Constants/size_extension.dart';
import 'package:asset_flow/Core/Model/asset_model.dart';
import 'package:asset_flow/Core/Widget/filter_chips.dart';
import 'package:asset_flow/Core/Widget/primary_action_button.dart';
import 'package:asset_flow/Core/Widget/search_input_bar.dart';
import 'dart:convert';
import 'dart:typed_data';

import 'package:asset_flow/view/Dashboard/screens/add_asset_dialog.dart';
import 'package:asset_flow/view/Dashboard/screens/report_damage_dialog.dart';
import 'package:asset_flow/viewModel/assets_screen_view_model.dart';
import 'package:asset_flow/viewModel/employee_screen_view_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';

class AssetsScreenContent extends StatefulWidget {
  const AssetsScreenContent({super.key});

  @override
  State<AssetsScreenContent> createState() => _AssetsScreenContentState();
}

class _AssetsScreenContentState extends State<AssetsScreenContent> {
  final TextEditingController _searchController = TextEditingController();
  late bool _isGridView;

  static bool _sIsGridView = true;

  @override
  void initState() {
    super.initState();
    _isGridView = _sIsGridView;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AssetsScreenViewModel>().fetchAssets();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _setView(bool grid) {
    _sIsGridView = grid;
    setState(() => _isGridView = grid);
  }

  List<AssetItem> _filteredAssets(List<AssetItem> assets) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return assets;
    return assets.where((a) {
      return a.name.toLowerCase().contains(query) ||
          a.assetId.toLowerCase().contains(query) ||
          a.brand.toLowerCase().contains(query) ||
          a.assignedTo.toLowerCase().contains(query);
    }).toList();
  }

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
    return Consumer<AssetsScreenViewModel>(
      builder: (context, vm, child) {
        if (vm.isLoading && vm.assets.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(context.h(48)),
              child: const CircularProgressIndicator(),
            ),
          );
        }
        if (vm.errorMessage != null && vm.assets.isEmpty) {
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
                    onPressed: vm.fetchAssets,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }
        final filtered = _filteredAssets(vm.assets);
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Assets',
                          style: TextStyle(
                            color: AppColors.headingColor,
                            fontSize: context.text(24),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: context.h(4)),
                        Text(
                          'Manage and track all organizational assets',
                          style: TextStyle(
                            color: AppColors.subHeadingColor,
                            fontSize: context.text(14),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OutlinedButton.icon(
                        onPressed: (vm.isImporting || vm.isExporting)
                            ? null
                            : () => _onImportAssets(context),
                        icon: vm.isImporting
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.headingColor,
                                ),
                              )
                            : Icon(Icons.upload_file, size: 18, color: AppColors.headingColor),
                        label: Text(
                          vm.isImporting ? 'Importing...' : 'Import',
                          style: TextStyle(
                            color: AppColors.headingColor,
                            fontSize: context.text(14),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.headingColor),
                        ),
                      ),
                      SizedBox(width: context.w(12)),
                      OutlinedButton.icon(
                        onPressed: (vm.isImporting || vm.isExporting)
                            ? null
                            : () => _onExportAssets(context),
                        icon: vm.isExporting
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.headingColor,
                                ),
                              )
                            : Icon(Icons.download, size: 18, color: AppColors.headingColor),
                        label: Text(
                          vm.isExporting ? 'Exporting...' : 'Export',
                          style: TextStyle(
                            color: AppColors.headingColor,
                            fontSize: context.text(14),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.headingColor),
                        ),
                      ),
                      SizedBox(width: context.w(12)),
                      PrimaryActionButton(
                        label: 'Add Asset',
                        icon: Icons.add,
                        onTap: (vm.isImporting || vm.isExporting)
                            ? null
                            : () async {
                                final result = await showAddAssetDialog(context);
                                if (result == null || !mounted) return;
                                final vmRead = context.read<AssetsScreenViewModel>();
                                final request = AddAssetRequest(
                                  assetCode: result.assetCode,
                                  name: result.assetName,
                                  category: result.category,
                                  brand: result.brand,
                                  model: result.model,
                                  version: result.version,
                                  condition: result.condition,
                                  currentStatus: 'Store',
                                );
                                final success = await vmRead.addAssetWithApi(request);
                                if (!mounted) return;
                                if (success) {
                                  vmRead.clearError();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Asset added successfully'),
                                      backgroundColor: AppColors.repairMarkFixedBg,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        vmRead.errorMessage ?? 'Failed to add asset',
                                      ),
                                      backgroundColor: AppColors.redColor,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              },
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: context.h(24)),
              Row(
                children: [
                  Expanded(
                    child: SearchInputBar(
                      controller: _searchController,
                      hintText: 'Search for...',
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  SizedBox(width: context.w(12)),
                  _ViewToggle(
                    isGrid: _isGridView,
                    onGridTap: () => _setView(true),
                    onListTap: () => _setView(false),
                  ),
                ],
              ),
              SizedBox(height: context.h(16)),
              Text(
                'Category',
                style: TextStyle(
                  color: AppColors.subHeadingColor,
                  fontSize: context.text(12),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: context.h(6)),
              FilterChips<AssetCategory>(
                selected: vm.category,
                values: AssetCategory.values,
                labelBuilder: (c) => c.label,
                onSelected: vm.setCategory,
              ),
              SizedBox(height: context.h(12)),
              Text(
                'Status',
                style: TextStyle(
                  color: AppColors.subHeadingColor,
                  fontSize: context.text(12),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: context.h(6)),
              FilterChips<AssetStatusFilter>(
                selected: vm.statusFilter,
                values: AssetStatusFilter.values,
                labelBuilder: (s) => s.label,
                onSelected: vm.setStatusFilter,
              ),
              SizedBox(height: context.h(20)),
              if (_isGridView) _buildGrid(context, filtered) else _buildList(context, filtered),
              if (vm.hasMore && vm.assets.isNotEmpty) ...[
                SizedBox(height: context.h(16)),
                Center(
                  child: vm.isLoadingMore
                      ? Padding(
                          padding: context.padSym(v: 16),
                          child: const SizedBox(
                            height: 28,
                            width: 28,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : TextButton.icon(
                          onPressed: vm.loadMore,
                          icon: const Icon(Icons.add_circle_outline, size: 20),
                          label: const Text('Load more'),
                        ),
                ),
                SizedBox(height: context.h(24)),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildGrid(BuildContext context, List<AssetItem> items) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 700
            ? 4
            : (constraints.maxWidth > 500 ? 3 : 2);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.72,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final a = items[index];
            return AssetCard(
              key: ValueKey(a.id),
              asset: a,
              icon: _iconForCategory(a.category),
              onEdit: () => _onEditAsset(a),
              onDelete: () => _onDeleteAsset(a),
              onReturnToStore: () => _onReturnAsset(a),
              onReportDamage: () => _onReportDamage(a),
            );
          },
        );
      },
    );
  }

  Widget _buildList(BuildContext context, List<AssetItem> items) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final a = items[index];
        return Padding(
          key: ValueKey(a.id),
          padding: EdgeInsets.only(bottom: context.h(12)),
          child: AssetCard(
            asset: a,
            icon: _iconForCategory(a.category),
            isListTile: true,
            onEdit: () => _onEditAsset(a),
            onDelete: () => _onDeleteAsset(a),
            onReturnToStore: () => _onReturnAsset(a),
            onReportDamage: () => _onReportDamage(a),
          ),
        );
      },
    );
  }

  Future<void> _onEditAsset(AssetItem a) async {
    final result = await showEditAssetDialog(context, a);
    if (result == null || !mounted) return;
    final vm = context.read<AssetsScreenViewModel>();
    final request = UpdateAssetRequest(
      name: result.assetName,
      category: result.category,
      brand: result.brand,
      model: result.model,
      version: result.version,
      condition: result.condition,
      currentStatus: a.status,
    );
    final success = await vm.updateAssetWithApi(a.id, request);
    if (!mounted) return;
    if (success) {
      vm.clearError();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Asset updated'),
          backgroundColor: AppColors.repairMarkFixedBg,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.errorMessage ?? 'Failed to update asset'),
          backgroundColor: AppColors.redColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _onExportAssets(BuildContext context) async {
    final vm = context.read<AssetsScreenViewModel>();
    final r = await vm.exportAssets();
    if (!mounted) return;
    if (r.success && r.csvContent != null && r.csvContent!.isNotEmpty) {
      vm.clearError();
      final bytes = Uint8List.fromList(utf8.encode(r.csvContent!));
      final xFile = XFile.fromData(
        bytes,
        name: 'assets_export.csv',
        mimeType: 'text/csv',
      );
      await Share.shareXFiles([xFile], text: 'Assets export');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Export ready'),
          backgroundColor: AppColors.repairMarkFixedBg,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (!r.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.errorMessage ?? 'Export failed'),
          backgroundColor: AppColors.redColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _onImportAssets(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      withData: true,
      type: FileType.custom,
      allowedExtensions: ['csv', 'xlsx', 'xls'],
    );
    final file = result?.files.singleOrNull;
    if (file == null || !mounted) return;
    final bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not read file. Try again.'),
          backgroundColor: AppColors.redColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final vm = context.read<AssetsScreenViewModel>();
    final r = await vm.importAssets(
      fileBytes: bytes,
      filename: file.name,
    );
    if (!mounted) return;
    if (r.success) {
      vm.clearError();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(r.message ?? 'Assets imported successfully'),
          backgroundColor: AppColors.repairMarkFixedBg,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.errorMessage ?? 'Import failed'),
          backgroundColor: AppColors.redColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _onReturnAsset(AssetItem a) async {
    final vm = context.read<AssetsScreenViewModel>();
    final success = await vm.returnAssetToStore(a.id);
    if (!mounted) return;
    if (success) {
      vm.clearError();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${a.name} returned to store'),
          backgroundColor: AppColors.repairMarkFixedBg,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.errorMessage ?? 'Failed to return asset'),
          backgroundColor: AppColors.redColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _onReportDamage(AssetItem a) async {
    final empVm = context.read<EmployeeScreenViewModel>();
    if (empVm.employees.isEmpty) {
      await empVm.fetchEmployees();
      if (!mounted) return;
    }
    final employees = empVm.employees;
    if (employees.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No employees available. Add employees first.'),
          backgroundColor: AppColors.redColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final result = await showReportDamageDialog(
      context,
      assetName: a.name,
      employees: employees,
    );
    if (result == null || !mounted) return;
    final vm = context.read<AssetsScreenViewModel>();
    final success = await vm.reportDamage(
      assetId: a.id,
      employeeId: result.employeeId,
      reason: result.reason,
      damageDate: result.damageDate,
    );
    if (!mounted) return;
    if (success) {
      vm.clearError();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${a.name} reported as damaged'),
          backgroundColor: AppColors.repairMarkFixedBg,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.errorMessage ?? 'Failed to report damage'),
          backgroundColor: AppColors.redColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _onDeleteAsset(AssetItem a) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text(
          'Delete Asset',
          style: TextStyle(color: AppColors.headingColor),
        ),
        content: Text(
          'Remove "${a.name}" (${a.assetId})?',
          style: TextStyle(color: AppColors.subHeadingColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.subHeadingColor),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete', style: TextStyle(color: AppColors.redColor)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      final vm = context.read<AssetsScreenViewModel>();
      final success = await vm.deleteAssetWithApi(a.id);
      if (!mounted) return;
      if (success) {
        vm.clearError();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Asset deleted'),
            backgroundColor: AppColors.repairMarkFixedBg,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(vm.errorMessage ?? 'Failed to delete asset'),
            backgroundColor: AppColors.redColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

class _ViewToggle extends StatelessWidget {
  final bool isGrid;
  final VoidCallback onGridTap;
  final VoidCallback onListTap;

  const _ViewToggle({
    required this.isGrid,
    required this.onGridTap,
    required this.onListTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: isGrid ? AppColors.buttonColor : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(context.radius(8)),
          child: InkWell(
            onTap: onGridTap,
            borderRadius: BorderRadius.circular(context.radius(8)),
            child: Padding(
              padding: context.padAll(10),
              child: Icon(
                Icons.grid_view_rounded,
                color: AppColors.headingColor,
                size: 22,
              ),
            ),
          ),
        ),
        SizedBox(width: context.w(8)),
        Material(
          color: !isGrid ? AppColors.buttonColor : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(context.radius(8)),
          child: InkWell(
            onTap: onListTap,
            borderRadius: BorderRadius.circular(context.radius(8)),
            child: Padding(
              padding: context.padAll(10),
              child: Icon(
                Icons.view_list_rounded,
                color: AppColors.headingColor,
                size: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AssetCard extends StatelessWidget {
  final AssetItem asset;
  final IconData icon;
  final bool isListTile;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onReturnToStore;
  final VoidCallback? onReportDamage;

  const AssetCard({
    super.key,
    required this.asset,
    required this.icon,
    this.isListTile = false,
    this.onEdit,
    this.onDelete,
    this.onReturnToStore,
    this.onReportDamage,
  });

  /// True if asset is assigned (can be returned to store).
  static bool _canReturnToStore(String status) {
    final s = status.toLowerCase();
    return s.isNotEmpty &&
        s != 'store' &&
        s != 'in store' &&
        s != 'damaged' &&
        s != 'under repair';
  }

  /// True if asset can be reported as damaged (not already damaged/under repair).
  static bool _canReportDamage(String status) {
    final s = status.toLowerCase();
    return s != 'damaged' && s != 'under repair';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.padAll(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(context.radius(12)),
      ),
      clipBehavior: Clip.hardEdge,
      child: isListTile
          ? _buildListContent(context)
          : _buildGridContent(context),
    );
  }

  Widget _buildGridContent(BuildContext context) {
    return LayoutBuilder(
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
                    _StatusPill(status: asset.status),
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
                _DetailLine(label: 'Brand', value: asset.brand),
                SizedBox(height: context.h(4)),
                _DetailLine(label: 'Model', value: asset.model),
                SizedBox(height: context.h(4)),
                _DetailLine(label: 'Condition', value: asset.condition),
                SizedBox(height: context.h(4)),
                _DetailLine(label: 'Assigned To', value: asset.assignedTo),
                if (onEdit != null || onDelete != null || (onReturnToStore != null && _canReturnToStore(asset.status)) || (onReportDamage != null && _canReportDamage(asset.status))) ...[
                  SizedBox(height: context.h(12)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (onReportDamage != null && _canReportDamage(asset.status))
                        IconButton(
                          onPressed: onReportDamage,
                          icon: Icon(
                            Icons.report_outlined,
                            color: AppColors.headingColor,
                            size: 20,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          tooltip: 'Report damage',
                        ),
                      if (onReturnToStore != null && _canReturnToStore(asset.status))
                        IconButton(
                          onPressed: onReturnToStore,
                          icon: Icon(
                            Icons.store_outlined,
                            color: AppColors.headingColor,
                            size: 20,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          tooltip: 'Return to store',
                        ),
                      if (onEdit != null)
                        IconButton(
                          onPressed: onEdit,
                          icon: Icon(
                            Icons.edit_outlined,
                            color: AppColors.headingColor,
                            size: 20,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        ),
                      if (onDelete != null)
                        IconButton(
                          onPressed: onDelete,
                          icon: Icon(
                            Icons.delete_outline,
                            color: AppColors.redColor,
                            size: 20,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildListContent(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.listAvatarBg,
          child: Icon(icon, color: AppColors.headingColor, size: 28),
        ),
        SizedBox(width: context.w(14)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      asset.name,
                      style: TextStyle(
                        color: AppColors.headingColor,
                        fontSize: context.text(16),
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _StatusPill(status: asset.status),
                  if (onReportDamage != null && AssetCard._canReportDamage(asset.status))
                    IconButton(
                      onPressed: onReportDamage,
                      icon: Icon(
                        Icons.report_outlined,
                        color: AppColors.headingColor,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      tooltip: 'Report damage',
                    ),
                  if (onReturnToStore != null && AssetCard._canReturnToStore(asset.status))
                    IconButton(
                      onPressed: onReturnToStore,
                      icon: Icon(
                        Icons.store_outlined,
                        color: AppColors.headingColor,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      tooltip: 'Return to store',
                    ),
                  if (onEdit != null)
                    IconButton(
                      onPressed: onEdit,
                      icon: Icon(
                        Icons.edit_outlined,
                        color: AppColors.headingColor,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                  if (onDelete != null)
                    IconButton(
                      onPressed: onDelete,
                      icon: Icon(
                        Icons.delete_outline,
                        color: AppColors.redColor,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                ],
              ),
              SizedBox(height: context.h(4)),
              Text(
                asset.assetId,
                style: TextStyle(
                  color: AppColors.subHeadingColor,
                  fontSize: context.text(13),
                ),
              ),
              SizedBox(height: context.h(8)),
              Wrap(
                spacing: context.w(16),
                runSpacing: context.h(4),
                children: [
                  _DetailChip(label: 'Brand', value: asset.brand),
                  _DetailChip(label: 'Model', value: asset.model),
                  _DetailChip(label: 'Condition', value: asset.condition),
                  _DetailChip(label: 'Assigned To', value: asset.assignedTo),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String status;

  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.padSym(h: 10, v: 5),
      decoration: BoxDecoration(
        color: AppColors.statusPillActive,
        borderRadius: BorderRadius.circular(context.radius(16)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: AppColors.headingColor,
          fontSize: context.text(11),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  final String label;
  final String value;

  const _DetailLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 85,
          child: Text(
            '$label:',
            style: TextStyle(
              color: AppColors.subHeadingColor,
              fontSize: context.text(12),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: AppColors.headingColor,
              fontSize: context.text(12),
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _DetailChip extends StatelessWidget {
  final String label;
  final String value;

  const _DetailChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Text(
      '$label: $value',
      style: TextStyle(
        color: AppColors.subHeadingColor,
        fontSize: context.text(12),
      ),
    );
  }
}
