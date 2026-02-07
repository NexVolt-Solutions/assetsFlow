import 'package:asset_flow/Core/Constants/app_colors.dart';
import 'package:asset_flow/Core/Constants/size_extension.dart';
import 'package:asset_flow/Core/Model/asset_model.dart';
import 'package:asset_flow/Core/Widget/filter_chips.dart';
import 'package:asset_flow/Core/Widget/primary_action_button.dart';
import 'package:asset_flow/Core/Widget/search_input_bar.dart';
import 'package:asset_flow/view/Dashboard/screens/add_asset_dialog.dart';
import 'package:flutter/material.dart';

enum AssetCategory { all, laptop, mouse, keyboard, monitor, mobile, headset }

extension AssetCategoryX on AssetCategory {
  String get label {
    switch (this) {
      case AssetCategory.all:
        return 'All';
      case AssetCategory.laptop:
        return 'Laptop';
      case AssetCategory.mouse:
        return 'Mouse';
      case AssetCategory.keyboard:
        return 'Keyboard';
      case AssetCategory.monitor:
        return 'Monitor';
      case AssetCategory.mobile:
        return 'Mobile';
      case AssetCategory.headset:
        return 'Headset';
    }
  }
}

enum AssetStatusFilter { all, inUse, store, damaged, underRepair }

extension AssetStatusFilterX on AssetStatusFilter {
  String get label {
    switch (this) {
      case AssetStatusFilter.all:
        return 'All';
      case AssetStatusFilter.inUse:
        return 'In Use';
      case AssetStatusFilter.store:
        return 'Store';
      case AssetStatusFilter.damaged:
        return 'Damaged';
      case AssetStatusFilter.underRepair:
        return 'Under Repair';
    }
  }

  String? get statusValue {
    switch (this) {
      case AssetStatusFilter.all:
        return null;
      case AssetStatusFilter.inUse:
        return 'In Use';
      case AssetStatusFilter.store:
        return 'In Store';
      case AssetStatusFilter.damaged:
        return 'Damaged';
      case AssetStatusFilter.underRepair:
        return 'Under Repair';
    }
  }
}

List<AssetItem> get kDemoAssets => [
  AssetItem(
    id: '1',
    name: 'MacBook Pro 16"',
    assetId: 'LP-2024-001',
    category: 'Laptop',
    status: 'In Use',
    brand: 'Apple',
    model: 'MacBook Pro',
    condition: 'Good',
    assignedTo: 'Aisha Patel',
  ),
  AssetItem(
    id: '2',
    name: 'Logitech MX Master',
    assetId: 'MS-2024-001',
    category: 'Mouse',
    status: 'In Use',
    brand: 'Logitech',
    model: 'MX Master 3S',
    condition: 'Good',
    assignedTo: 'Aisha Patel',
  ),
  AssetItem(
    id: '3',
    name: 'Dell UltraSharp 27"',
    assetId: 'MN-2024-001',
    category: 'Monitor',
    status: 'In Use',
    brand: 'Dell',
    model: 'U2723QE',
    condition: 'Good',
    assignedTo: 'Aisha Patel',
  ),
  AssetItem(
    id: '4',
    name: 'Apple Magic Keyboard',
    assetId: 'KB-2024-001',
    category: 'Keyboard',
    status: 'In Use',
    brand: 'Apple',
    model: 'Magic Keyboard',
    condition: 'Good',
    assignedTo: 'Aisha Patel',
  ),
  AssetItem(
    id: '5',
    name: 'HP Laptop 15',
    assetId: 'LP-2023-012',
    category: 'Laptop',
    status: 'In Store',
    brand: 'HP',
    model: 'Pavilion 15',
    condition: 'Good',
    assignedTo: '—',
  ),
  AssetItem(
    id: '6',
    name: 'Sony WH-1000XM5',
    assetId: 'HS-2024-002',
    category: 'Headset',
    status: 'In Use',
    brand: 'Sony',
    model: 'WH-1000XM5',
    condition: 'Good',
    assignedTo: 'Marcus Johnson',
  ),
];

class AssetsScreenContent extends StatefulWidget {
  const AssetsScreenContent({super.key});

  @override
  State<AssetsScreenContent> createState() => _AssetsScreenContentState();
}

class _AssetsScreenContentState extends State<AssetsScreenContent> {
  final TextEditingController _searchController = TextEditingController();
  late AssetCategory _category;
  late AssetStatusFilter _statusFilter;
  late bool _isGridView;
  late List<AssetItem> _allAssets = kDemoAssets;

  /// Preserve view/filter state across layout changes (e.g. grid↔list, resize).
  static bool _sIsGridView = true;
  static AssetCategory _sCategory = AssetCategory.all;
  static AssetStatusFilter _sStatusFilter = AssetStatusFilter.all;

  @override
  void initState() {
    super.initState();
    _isGridView = _sIsGridView;
    _category = _sCategory;
    _statusFilter = _sStatusFilter;
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

  void _setCategory(AssetCategory c) {
    _sCategory = c;
    setState(() => _category = c);
  }

  void _setStatusFilter(AssetStatusFilter s) {
    _sStatusFilter = s;
    setState(() => _statusFilter = s);
  }

  List<AssetItem> get _filteredAssets {
    final query = _searchController.text.trim().toLowerCase();
    return _allAssets.where((a) {
      final matchCategory =
          _category == AssetCategory.all ||
          a.category.toLowerCase() == _category.label.toLowerCase();
      final matchStatus =
          _statusFilter.statusValue == null ||
          a.status == _statusFilter.statusValue;
      final matchSearch =
          query.isEmpty ||
          a.name.toLowerCase().contains(query) ||
          a.assetId.toLowerCase().contains(query) ||
          a.brand.toLowerCase().contains(query) ||
          a.assignedTo.toLowerCase().contains(query);
      return matchCategory && matchStatus && matchSearch;
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
              PrimaryActionButton(
                label: 'Add Asset',
                icon: Icons.add,
                onTap: () async {
                  final result = await showAddAssetDialog(context);
                  if (result != null && mounted) {
                    setState(() {
                      final newId = '${_allAssets.length + 1}';
                      _allAssets = [
                        ..._allAssets,
                        AssetItem(
                          id: newId,
                          name: result.assetName,
                          assetId: result.assetCode,
                          category: result.category,
                          status: 'In Store',
                          brand: result.brand,
                          model: result.model,
                          condition: result.condition,
                          assignedTo: '—',
                        ),
                      ];
                    });
                  }
                },
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
            selected: _category,
            values: AssetCategory.values,
            labelBuilder: (c) => c.label,
            onSelected: _setCategory,
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
            selected: _statusFilter,
            values: AssetStatusFilter.values,
            labelBuilder: (s) => s.label,
            onSelected: _setStatusFilter,
          ),
          SizedBox(height: context.h(20)),
          if (_isGridView) _buildGrid(context) else _buildList(context),
        ],
      ),
    );
  }

  Widget _buildGrid(BuildContext context) {
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
            childAspectRatio: 1.0,
          ),
          itemCount: _filteredAssets.length,
          itemBuilder: (context, index) {
            final a = _filteredAssets[index];
            return AssetCard(
              asset: a,
              icon: _iconForCategory(a.category),
              onEdit: () => _onEditAsset(a),
              onDelete: () => _onDeleteAsset(a),
            );
          },
        );
      },
    );
  }

  Widget _buildList(BuildContext context) {
    return Column(
      children: _filteredAssets
          .map(
            (a) => Padding(
              padding: EdgeInsets.only(bottom: context.h(12)),
              child: AssetCard(
                asset: a,
                icon: _iconForCategory(a.category),
                isListTile: true,
                onEdit: () => _onEditAsset(a),
                onDelete: () => _onDeleteAsset(a),
              ),
            ),
          )
          .toList(),
    );
  }

  Future<void> _onEditAsset(AssetItem a) async {
    final result = await showEditAssetDialog(context, a);
    if (result == null || !mounted) return;
    setState(() {
      _allAssets = _allAssets.map((item) {
        if (item.id == a.id) {
          return AssetItem(
            id: item.id,
            name: result.assetName,
            assetId: result.assetCode,
            category: result.category,
            status: item.status,
            brand: result.brand,
            model: result.model,
            condition: result.condition,
            assignedTo: item.assignedTo,
          );
        }
        return item;
      }).toList();
    });
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
      setState(
        () => _allAssets = _allAssets.where((item) => item.id != a.id).toList(),
      );
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

  const AssetCard({
    super.key,
    required this.asset,
    required this.icon,
    this.isListTile = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.padAll(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(context.radius(12)),
      ),
      child: isListTile
          ? _buildListContent(context)
          : _buildGridContent(context),
    );
  }

  Widget _buildGridContent(BuildContext context) {
    return LayoutBuilder(
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
                    child: Icon(icon, color: AppColors.headingColor, size: 26),
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
              if (onEdit != null || onDelete != null) ...[
                SizedBox(height: context.h(12)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
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
