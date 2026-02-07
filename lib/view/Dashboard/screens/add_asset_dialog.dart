import 'package:asset_flow/Core/Constants/app_colors.dart';
import 'package:asset_flow/Core/Constants/size_extension.dart';
import 'package:asset_flow/Core/Model/asset_model.dart';
import 'package:flutter/material.dart';

/// Shows the Add Asset dialog. Returns [AddAssetDialogResult?] on Save, null on dismiss.
Future<AddAssetDialogResult?> showAddAssetDialog(BuildContext context) {
  return showDialog<AddAssetDialogResult>(
    context: context,
    barrierColor: Colors.black54,
    builder: (context) => const AddAssetDialog(),
  );
}

/// Shows the Edit Asset dialog with [existing] pre-filled. Returns [AddAssetDialogResult?] on Save.
Future<AddAssetDialogResult?> showEditAssetDialog(
  BuildContext context,
  AssetItem existing,
) {
  return showDialog<AddAssetDialogResult>(
    context: context,
    barrierColor: Colors.black54,
    builder: (context) => AddAssetDialog(initialAsset: existing),
  );
}

class AddAssetDialogResult {
  final String assetName;
  final String assetCode;
  final String category;
  final String brand;
  final String version;
  final String model;
  final String condition;

  AddAssetDialogResult({
    required this.assetName,
    required this.assetCode,
    required this.category,
    required this.brand,
    required this.version,
    required this.model,
    required this.condition,
  });
}

/// Category → list of brands available for that category.
const Map<String, List<String>> _categoryToBrands = {
  'Laptop': ['Apple', 'Dell', 'HP', 'Lenovo'],
  'Mouse': ['Logitech', 'Microsoft', 'Razer'],
  'Keyboard': ['Apple', 'Logitech', 'Microsoft'],
  'Monitor': ['Dell', 'Samsung', 'LG', 'HP'],
  'Mobile': ['Apple', 'Samsung', 'Google'],
  'Headset': ['Sony', 'Bose', 'Logitech'],
};

/// Brand → list of versions (dependent on brand).
const Map<String, List<String>> _brandToVersions = {
  'Apple': ['M3 Pro', 'M2', 'M1', 'M1 Pro'],
  'Dell': ['U2723QE', 'XPS 15', 'P2422H'],
  'HP': ['Pavilion 15', 'EliteBook', 'Z27'],
  'Lenovo': ['ThinkPad X1', 'IdeaPad'],
  'Logitech': ['MX Master 3S', 'MX Keys', 'MX Ergo'],
  'Microsoft': ['Surface Mouse', 'Surface Keyboard', 'Sculpt'],
  'Razer': ['DeathAdder', 'Basilisk'],
  'Samsung': ['Odyssey G7', 'Galaxy S24', 'Smart Monitor'],
  'LG': ['UltraGear', 'UltraWide'],
  'Google': ['Pixel 8', 'Pixel 7'],
  'Sony': ['WH-1000XM5', 'WH-1000XM4'],
  'Bose': ['QC45', 'QC35 II'],
};

/// Brand → list of models (dependent on brand).
const Map<String, List<String>> _brandToModels = {
  'Apple': ['MacBook Pro', 'MacBook Air', 'Magic Keyboard', 'iPhone'],
  'Dell': ['UltraSharp 27"', 'XPS 15', 'P Series'],
  'HP': ['Pavilion', 'EliteBook', 'Z Display'],
  'Lenovo': ['ThinkPad', 'IdeaPad'],
  'Logitech': ['MX Master', 'MX Keys', 'MX Ergo', 'G Pro'],
  'Microsoft': ['Surface', 'Sculpt'],
  'Razer': ['DeathAdder', 'Basilisk'],
  'Samsung': ['Odyssey', 'Galaxy', 'Smart Monitor'],
  'LG': ['UltraGear', 'UltraWide'],
  'Google': ['Pixel'],
  'Sony': ['WH-1000XM5', 'WH-1000XM4'],
  'Bose': ['QuietComfort 45', 'QuietComfort 35 II'],
};

const List<String> _conditions = ['New', 'Good', 'Fair', 'Damaged'];

const List<String> _categories = [
  'Laptop',
  'Mouse',
  'Keyboard',
  'Monitor',
  'Mobile',
  'Headset',
];

class AddAssetDialog extends StatefulWidget {
  final AssetItem? initialAsset;

  const AddAssetDialog({super.key, this.initialAsset});

  @override
  State<AddAssetDialog> createState() => _AddAssetDialogState();
}

class _AddAssetDialogState extends State<AddAssetDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _assetNameController;
  late final TextEditingController _assetCodeController;

  String _category = _categories.first;
  String? _brand;
  String? _version;
  String? _model;
  String _condition = _conditions.first;

  bool get _isEditMode => widget.initialAsset != null;

  List<String> get _brands => _categoryToBrands[_category] ?? [];
  List<String> get _versions => (_brand != null && _brandToVersions.containsKey(_brand))
      ? _brandToVersions[_brand]!
      : [];
  List<String> get _models => (_brand != null && _brandToModels.containsKey(_brand))
      ? _brandToModels[_brand]!
      : [];

  @override
  void initState() {
    super.initState();
    final existing = widget.initialAsset;
    if (existing != null) {
      _assetNameController = TextEditingController(text: existing.name);
      _assetCodeController = TextEditingController(text: existing.assetId);
      _category = _categories.contains(existing.category) ? existing.category : _categories.first;
      _brand = _brands.contains(existing.brand) ? existing.brand : (_brands.isNotEmpty ? _brands.first : null);
      _version = _versions.isNotEmpty ? _versions.first : null;
      _model = _models.contains(existing.model) ? existing.model : (_models.isNotEmpty ? _models.first : null);
      _condition = _conditions.contains(existing.condition) ? existing.condition : _conditions.first;
    } else {
      _assetNameController = TextEditingController(text: 'MACBOOK PRO');
      _assetCodeController = TextEditingController(text: 'EMP009');
      _brand = _brands.isNotEmpty ? _brands.first : null;
      _version = _versions.isNotEmpty ? _versions.first : null;
      _model = _models.isNotEmpty ? _models.first : null;
    }
  }

  @override
  void dispose() {
    _assetNameController.dispose();
    _assetCodeController.dispose();
    super.dispose();
  }

  void _onCategoryChanged(String? value) {
    if (value == null) return;
    setState(() {
      _category = value;
      _brand = _brands.isNotEmpty ? _brands.first : null;
      _version = _versions.isNotEmpty ? _versions.first : null;
      _model = _models.isNotEmpty ? _models.first : null;
    });
  }

  void _onBrandChanged(String? value) {
    setState(() {
      _brand = value;
      _version = _versions.isNotEmpty ? _versions.first : null;
      _model = _models.isNotEmpty ? _models.first : null;
    });
  }

  void _onSave() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(context).pop(AddAssetDialogResult(
        assetName: _assetNameController.text.trim(),
        assetCode: _assetCodeController.text.trim(),
        category: _category,
        brand: _brand ?? '',
        version: _version ?? '',
        model: _model ?? '',
        condition: _condition,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width > 500;
    return Dialog(
      backgroundColor: AppColors.pimaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.radius(16)),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 560,
          maxHeight: MediaQuery.sizeOf(context).height * 0.88,
        ),
        child: SingleChildScrollView(
          padding: context.padAll(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                SizedBox(height: context.h(24)),
                if (isWide) _buildTwoColumnRow(context) else _buildSingleColumn(context),
                SizedBox(height: context.h(28)),
                _buildSaveButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.cardBackground,
          child: Icon(
            Icons.add_circle_outline_rounded,
            color: AppColors.headingColor,
            size: 28,
          ),
        ),
        SizedBox(width: context.w(14)),
        Text(
          _isEditMode ? 'Edit Asset' : 'Add Asset',
          style: TextStyle(
            color: AppColors.headingColor,
            fontSize: context.text(22),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildTwoColumnRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              _buildLabeledField(context, 'Asset Name', _assetNameController, 'MACBOOK PRO',
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
              SizedBox(height: context.h(16)),
              _buildDropdown(context, 'Category', _category, _categories, _onCategoryChanged),
              SizedBox(height: context.h(16)),
              _buildDropdown(context, 'Model', _model, _models, (v) => setState(() => _model = v)),
              SizedBox(height: context.h(16)),
              _buildDropdown(context, 'Condition', _condition, _conditions,
                  (v) => setState(() => _condition = v ?? _conditions.first)),
            ],
          ),
        ),
        SizedBox(width: context.w(16)),
        Expanded(
          child: Column(
            children: [
              _buildLabeledField(context, 'Asset Code', _assetCodeController, 'EMP009',
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
              SizedBox(height: context.h(16)),
              _buildDropdown(context, 'Brand', _brand, _brands, _onBrandChanged),
              SizedBox(height: context.h(16)),
              _buildDropdown(context, 'Version', _version, _versions, (v) => setState(() => _version = v)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSingleColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildLabeledField(context, 'Asset Name', _assetNameController, 'MACBOOK PRO',
            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
        SizedBox(height: context.h(16)),
        _buildLabeledField(context, 'Asset Code', _assetCodeController, 'EMP009',
            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
        SizedBox(height: context.h(16)),
        _buildDropdown(context, 'Category', _category, _categories, _onCategoryChanged),
        SizedBox(height: context.h(16)),
        _buildDropdown(context, 'Brand', _brand, _brands, _onBrandChanged),
        SizedBox(height: context.h(16)),
        _buildDropdown(context, 'Version', _version, _versions, (v) => setState(() => _version = v)),
        SizedBox(height: context.h(16)),
        _buildDropdown(context, 'Model', _model, _models, (v) => setState(() => _model = v)),
        SizedBox(height: context.h(16)),
        _buildDropdown(context, 'Condition', _condition, _conditions,
            (v) => setState(() => _condition = v ?? _conditions.first)),
      ],
    );
  }

  Widget _buildLabeledField(
    BuildContext context,
    String label,
    TextEditingController controller,
    String hint, {
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.subHeadingColor,
            fontSize: context.text(14),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: context.h(8)),
        _styledTextField(context, controller: controller, hint: hint, validator: validator),
      ],
    );
  }

  Widget _buildDropdown(
    BuildContext context,
    String label,
    String? value,
    List<String> items,
    ValueChanged<String?>? onChanged,
  ) {
    final effectiveValue = value != null && items.contains(value)
        ? value
        : (items.isNotEmpty ? items.first : null);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.subHeadingColor,
            fontSize: context.text(14),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: context.h(8)),
        _styledDropdown(
          value: effectiveValue,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (items.isEmpty) ? null : onChanged,
        ),
      ],
    );
  }

  Widget _styledTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(context.radius(10)),
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        style: TextStyle(
          color: AppColors.headingColor,
          fontSize: context.text(14),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.subHeadingColor, fontSize: 14),
          border: InputBorder.none,
          contentPadding: context.padSym(h: 14, v: 14),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(context.radius(10)),
            borderSide: const BorderSide(color: AppColors.redColor),
          ),
        ),
      ),
    );
  }

  Widget _styledDropdown({
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?>? onChanged,
  }) {
    return Container(
      padding: context.padSym(h: 14, v: 4),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(context.radius(10)),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items,
        onChanged: onChanged,
        dropdownColor: AppColors.cardBackground,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          isDense: true,
        ),
        style: TextStyle(
          color: AppColors.headingColor,
          fontSize: context.text(14),
          fontWeight: FontWeight.w500,
        ),
        icon: Icon(
          Icons.keyboard_arrow_down,
          color: AppColors.headingColor,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: AppColors.buttonColor,
        borderRadius: BorderRadius.circular(context.radius(10)),
        child: InkWell(
          onTap: _onSave,
          borderRadius: BorderRadius.circular(context.radius(10)),
          child: Padding(
            padding: context.padSym(v: 14),
            child: Center(
              child: Text(
                _isEditMode ? 'Update Asset' : 'Save Asset',
                style: TextStyle(
                  color: AppColors.headingColor,
                  fontSize: context.text(16),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
