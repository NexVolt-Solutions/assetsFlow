import 'package:asset_flow/Core/Constants/app_colors.dart';
import 'package:asset_flow/Core/Constants/size_extension.dart';
import 'package:asset_flow/Core/Model/asset_model.dart';
import 'package:asset_flow/Core/Model/employee_model.dart';
import 'package:asset_flow/Core/Widget/primary_action_button.dart';
import 'package:asset_flow/view/Dashboard/screens/assets_screen.dart' show kDemoAssets;
import 'package:asset_flow/view/Dashboard/screens/employee_screen.dart' show kDemoEmployees;
import 'package:flutter/material.dart';

class AssignAssetScreenContent extends StatefulWidget {
  const AssignAssetScreenContent({super.key});

  @override
  State<AssignAssetScreenContent> createState() => _AssignAssetScreenContentState();
}

class _AssignAssetScreenContentState extends State<AssignAssetScreenContent> {
  String? _selectedEmployeeId;
  final Set<String> _selectedAssetIds = {};
  late List<AssetItem> _availableAssets = kDemoAssets;

  List<EmployeeItem> get _employees => kDemoEmployees;

  EmployeeItem? get _selectedEmployee {
    if (_selectedEmployeeId == null) return null;
    for (final e in _employees) {
      if (e.id == _selectedEmployeeId) return e;
    }
    return null;
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

  void _toggleAsset(String assetId) {
    setState(() {
      if (_selectedAssetIds.contains(assetId)) {
        _selectedAssetIds.remove(assetId);
      } else {
        _selectedAssetIds.add(assetId);
      }
    });
  }

  void _onAssign() {
    if (_selectedEmployee == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select an employee'),
          backgroundColor: AppColors.redColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (_selectedAssetIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select at least one asset'),
          backgroundColor: AppColors.redColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Assigned ${_selectedAssetIds.length} asset(s) to ${_selectedEmployee!.name}',
        ),
        backgroundColor: AppColors.buttonColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
    setState(() {
      _selectedAssetIds.clear();
    });
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
          Text(
            'Assign Asset',
            style: TextStyle(
              color: AppColors.headingColor,
              fontSize: context.text(24),
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: context.h(4)),
          Text(
            'Assign available assets to employees',
            style: TextStyle(
              color: AppColors.subHeadingColor,
              fontSize: context.text(14),
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: context.h(28)),
          _buildNewAssignmentSection(context),
          SizedBox(height: context.h(24)),
          _buildSelectAssetsSection(context),
          SizedBox(height: context.h(28)),
          SizedBox(
            width: double.infinity,
            child: PrimaryActionButton(
              label: 'Assign Asset',
              icon: Icons.add_circle_outline,
              onTap: _onAssign,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewAssignmentSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.person_outline, color: AppColors.headingColor, size: 22),
            SizedBox(width: context.w(10)),
            Text(
              'New Assignment',
              style: TextStyle(
                color: AppColors.headingColor,
                fontSize: context.text(18),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        SizedBox(height: context.h(14)),
        Text(
          'Select Employee',
          style: TextStyle(
            color: AppColors.subHeadingColor,
            fontSize: context.text(14),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: context.h(8)),
        Container(
          padding: context.padSym(h: 14, v: 4),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(context.radius(10)),
          ),
          child: DropdownButtonFormField<String>(
            value: _employees.any((e) => e.id == _selectedEmployeeId)
                ? _selectedEmployeeId
                : null,
            hint: Text(
              'Choose an employee...',
              style: TextStyle(
                color: AppColors.subHeadingColor,
                fontSize: context.text(14),
              ),
            ),
            items: _employees
                .map(
                  (e) => DropdownMenuItem<String>(
                    value: e.id,
                    child: Text(
                      '${e.name} · ${e.code}',
                      style: TextStyle(
                        color: AppColors.headingColor,
                        fontSize: context.text(14),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => _selectedEmployeeId = v),
            dropdownColor: AppColors.cardBackground,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
            ),
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.headingColor,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectAssetsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Assets',
          style: TextStyle(
            color: AppColors.subHeadingColor,
            fontSize: context.text(14),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: context.h(12)),
        ..._availableAssets.map((asset) => _AssignableAssetTile(
              asset: asset,
              icon: _iconForCategory(asset.category),
              isSelected: _selectedAssetIds.contains(asset.id),
              onTap: () => _toggleAsset(asset.id),
            )),
      ],
    );
  }
}

class _AssignableAssetTile extends StatelessWidget {
  final AssetItem asset;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _AssignableAssetTile({
    required this.asset,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.h(10)),
      child: Material(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(context.radius(10)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(context.radius(10)),
          child: Padding(
            padding: context.padSym(h: 16, v: 14),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.listAvatarBg,
                  child: Icon(icon, color: AppColors.headingColor, size: 26),
                ),
                SizedBox(width: context.w(14)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        asset.name,
                        style: TextStyle(
                          color: AppColors.headingColor,
                          fontSize: context.text(15),
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
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
                    ],
                  ),
                ),
                Icon(
                  isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: isSelected ? AppColors.headingColor : AppColors.subHeadingColor,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
