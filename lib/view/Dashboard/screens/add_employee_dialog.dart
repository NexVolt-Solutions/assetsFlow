import 'package:asset_flow/Core/Constants/app_colors.dart';
import 'package:asset_flow/Core/Constants/size_extension.dart';
import 'package:asset_flow/Core/Model/employee_model.dart';
import 'package:flutter/material.dart';

/// Shows the Add Employee dialog. Returns [AddEmployeeDialogResult?] on Save, null on dismiss.
Future<AddEmployeeDialogResult?> showAddEmployeeDialog(BuildContext context) {
  return showDialog<AddEmployeeDialogResult>(
    context: context,
    barrierColor: Colors.black54,
    builder: (context) => const AddEmployeeDialog(),
  );
}

/// Shows the Edit Employee dialog with [employee] pre-filled. Returns [AddEmployeeDialogResult?] on Update, null on dismiss.
Future<AddEmployeeDialogResult?> showEditEmployeeDialog(
  BuildContext context,
  EmployeeItem employee,
) {
  return showDialog<AddEmployeeDialogResult>(
    context: context,
    barrierColor: Colors.black54,
    builder: (context) => AddEmployeeDialog(existing: employee),
  );
}

class AddEmployeeDialogResult {
  final String employeeId;
  final String employeeCode;
  final String fullName;
  final String department;
  final String status;
  final DateTime? joiningDate;
  final DateTime? resignationDate;

  AddEmployeeDialogResult({
    required this.employeeId,
    required this.employeeCode,
    required this.fullName,
    required this.department,
    required this.status,
    this.joiningDate,
    this.resignationDate,
  });
}

class AddEmployeeDialog extends StatefulWidget {
  final EmployeeItem? existing;

  const AddEmployeeDialog({super.key, this.existing});

  @override
  State<AddEmployeeDialog> createState() => _AddEmployeeDialogState();
}

class _AddEmployeeDialogState extends State<AddEmployeeDialog> {
  static const List<String> _departments = [
    'Engineering',
    'HR',
    'Marketing',
    'Operations',
    'Design',
  ];
  static const List<String> _statuses = ['Active', 'Resigned', 'On Hold'];

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _employeeIdController;
  late final TextEditingController _employeeCodeController;
  late final TextEditingController _fullNameController;
  late final TextEditingController _joiningDateController;
  late final TextEditingController _resignationDateController;

  String _department = _departments.first;
  String _status = _statuses.first;
  DateTime? _joiningDate;
  DateTime? _resignationDate;

  static const String _kDefaultId = 'EMP009';

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      _employeeIdController = TextEditingController(text: existing.id);
      _employeeCodeController = TextEditingController(text: existing.code);
      _fullNameController = TextEditingController(text: existing.name);
      _department = existing.department;
      _status = existing.status;
      _joiningDate = _parseDate(existing.joiningDate);
      _resignationDate = existing.resignationDate != null
          ? _parseDate(existing.resignationDate!)
          : null;
      _joiningDateController = TextEditingController(
        text: _joiningDate != null ? _formatDate(_joiningDate!) : '',
      );
      _resignationDateController = TextEditingController(
        text: _resignationDate != null ? _formatDate(_resignationDate!) : '',
      );
    } else {
      _employeeIdController = TextEditingController(text: _kDefaultId);
      _employeeCodeController = TextEditingController(text: _kDefaultId);
      _fullNameController = TextEditingController();
      _joiningDateController = TextEditingController();
      _resignationDateController = TextEditingController();
    }
  }

  static DateTime? _parseDate(String value) {
    if (value.isEmpty) return null;
    final iso = DateTime.tryParse(value);
    if (iso != null) return iso;
    final parts = value.split(RegExp(r'[/\-]'));
    if (parts.length == 3) {
      final m = int.tryParse(parts[0]);
      final d = int.tryParse(parts[1]);
      final y = int.tryParse(parts[2]);
      if (m != null && d != null && y != null) {
        if (m > 12)
          return DateTime.tryParse(
            '$y-${parts[0].padLeft(2, '0')}-${parts[1].padLeft(2, '0')}',
          );
        return DateTime(y, m, d);
      }
    }
    return null;
  }

  static String _formatDate(DateTime d) {
    return '${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}/${d.year}';
  }

  @override
  void dispose() {
    _employeeIdController.dispose();
    _employeeCodeController.dispose();
    _fullNameController.dispose();
    _joiningDateController.dispose();
    _resignationDateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(
    BuildContext context, {
    required bool isJoining,
  }) async {
    final initial = isJoining ? _joiningDate : _resignationDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.yellowColor,
              onPrimary: AppColors.pimaryColor,
              surface: AppColors.cardBackground,
              onSurface: AppColors.headingColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked == null) return;
    if (isJoining) {
      setState(() {
        _joiningDate = picked;
        _joiningDateController.text =
            '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
      });
    } else {
      setState(() {
        _resignationDate = picked;
        _resignationDateController.text =
            '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  void _onSave() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(context).pop(
        AddEmployeeDialogResult(
          employeeId: _employeeIdController.text.trim(),
          employeeCode: _employeeCodeController.text.trim(),
          fullName: _fullNameController.text.trim(),
          department: _department,
          status: _status,
          joiningDate: _joiningDate,
          resignationDate: _resignationDate,
        ),
      );
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
          maxWidth: 520,
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
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
                if (isWide)
                  _buildTwoColumnFieldRow(context)
                else
                  _buildSingleColumnFields(context),
                SizedBox(height: context.h(16)),
                _buildFullNameField(context),
                SizedBox(height: context.h(16)),
                if (isWide)
                  _buildDepartmentStatusRow(context)
                else
                  _buildDepartmentStatusColumn(context),
                SizedBox(height: context.h(16)),
                if (isWide)
                  _buildDateRow(context)
                else
                  _buildDateColumn(context),
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
    final isEdit = widget.existing != null;
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.cardBackground,
          child: Icon(
            isEdit ? Icons.person : Icons.person_add_rounded,
            color: AppColors.headingColor,
            size: 28,
          ),
        ),
        SizedBox(width: context.w(14)),
        Text(
          isEdit ? 'Edit Employee' : 'Add Employee',
          style: TextStyle(
            color: AppColors.headingColor,
            fontSize: context.text(22),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildTwoColumnFieldRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildLabeledField(
            context,
            label: 'Employee ID',
            controller: _employeeIdController,
            hint: 'EMP009',
          ),
        ),
        SizedBox(width: context.w(16)),
        Expanded(
          child: _buildLabeledField(
            context,
            label: 'Employee Code',
            controller: _employeeCodeController,
            hint: 'EMP009',
          ),
        ),
      ],
    );
  }

  Widget _buildSingleColumnFields(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabeledField(
          context,
          label: 'Employee ID',
          controller: _employeeIdController,
          hint: 'EMP009',
        ),
        SizedBox(height: context.h(16)),
        _buildLabeledField(
          context,
          label: 'Employee Code',
          controller: _employeeCodeController,
          hint: 'EMP009',
        ),
      ],
    );
  }

  Widget _buildLabeledField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required String hint,
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
        _styledTextField(context, controller: controller, hint: hint),
      ],
    );
  }

  Widget _buildFullNameField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Full Name',
          style: TextStyle(
            color: AppColors.subHeadingColor,
            fontSize: context.text(14),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: context.h(8)),
        _styledTextField(
          context,
          controller: _fullNameController,
          hint: 'Enter Full Name',
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Enter full name';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDepartmentStatusRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildDepartmentDropdown(context)),
        SizedBox(width: context.w(16)),
        Expanded(child: _buildStatusDropdown(context)),
      ],
    );
  }

  Widget _buildDepartmentStatusColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDepartmentDropdown(context),
        SizedBox(height: context.h(16)),
        _buildStatusDropdown(context),
      ],
    );
  }

  Widget _buildDepartmentDropdown(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Department',
          style: TextStyle(
            color: AppColors.subHeadingColor,
            fontSize: context.text(14),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: context.h(8)),
        _styledDropdown<String>(
          value: _department,
          items: _departments
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) =>
              setState(() => _department = v ?? _departments.first),
        ),
      ],
    );
  }

  Widget _buildStatusDropdown(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status',
          style: TextStyle(
            color: AppColors.subHeadingColor,
            fontSize: context.text(14),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: context.h(8)),
        _styledDropdown<String>(
          value: _status,
          items: _statuses
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) => setState(() => _status = v ?? _statuses.first),
        ),
      ],
    );
  }

  Widget _buildDateRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildDateField(context, isJoining: true)),
        SizedBox(width: context.w(16)),
        Expanded(child: _buildDateField(context, isJoining: false)),
      ],
    );
  }

  Widget _buildDateColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDateField(context, isJoining: true),
        SizedBox(height: context.h(16)),
        _buildDateField(context, isJoining: false),
      ],
    );
  }

  Widget _buildDateField(BuildContext context, {required bool isJoining}) {
    final controller = isJoining
        ? _joiningDateController
        : _resignationDateController;
    final label = isJoining ? 'Joining Date' : 'Resignation Date';
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
        _styledTextField(
          context,
          controller: controller,
          hint: 'mm/dd/yyyy',
          readOnly: true,
          suffixIcon: IconButton(
            icon: Icon(
              Icons.calendar_today,
              color: AppColors.subHeadingColor,
              size: 20,
            ),
            onPressed: () => _pickDate(context, isJoining: isJoining),
          ),
        ),
      ],
    );
  }

  Widget _styledTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String hint,
    bool readOnly = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(context.radius(10)),
      ),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        validator: validator,
        style: TextStyle(
          color: AppColors.headingColor,
          fontSize: context.text(14),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.subHeadingColor, fontSize: 14),
          suffixIcon: suffixIcon,
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

  Widget _styledDropdown<T>({
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: context.padSym(h: 14, v: 4),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(context.radius(10)),
      ),
      child: DropdownButtonFormField<T>(
        initialValue: value,
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
                widget.existing != null ? 'Update Employee' : 'Save Employee',
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
