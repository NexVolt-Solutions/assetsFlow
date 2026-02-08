import 'package:asset_flow/Core/Constants/app_colors.dart';
import 'package:asset_flow/Core/Constants/size_extension.dart';
import 'package:asset_flow/Core/Model/employee_model.dart';
import 'package:flutter/material.dart';

/// Result of Report Damage dialog: employee_id, reason, damage_date (YYYY-MM-DD).
typedef ReportDamageResult = ({String employeeId, String reason, String damageDate});

/// Shows the Report Damage dialog. [employees] used for employee dropdown.
/// Returns [ReportDamageResult] on Submit, null on cancel.
Future<ReportDamageResult?> showReportDamageDialog(
  BuildContext context, {
  required String assetName,
  required List<EmployeeItem> employees,
}) {
  if (employees.isEmpty) {
    return Future.value(null);
  }
  return showDialog<ReportDamageResult>(
    context: context,
    barrierColor: Colors.black54,
    builder: (context) => ReportDamageDialog(
      assetName: assetName,
      employees: employees,
    ),
  );
}

class ReportDamageDialog extends StatefulWidget {
  final String assetName;
  final List<EmployeeItem> employees;

  const ReportDamageDialog({
    super.key,
    required this.assetName,
    required this.employees,
  });

  @override
  State<ReportDamageDialog> createState() => _ReportDamageDialogState();
}

class _ReportDamageDialogState extends State<ReportDamageDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _reasonController = TextEditingController();
  EmployeeItem? _selectedEmployee;
  DateTime _damageDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedEmployee = widget.employees.isNotEmpty ? widget.employees.first : null;
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) {
    final y = d.year;
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _damageDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      setState(() => _damageDate = picked);
    }
  }

  void _onSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      final emp = _selectedEmployee;
      if (emp == null) return;
      Navigator.of(context).pop((
        employeeId: emp.id,
        reason: _reasonController.text.trim(),
        damageDate: _formatDate(_damageDate),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.pimaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.radius(16)),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: context.padAll(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Report damaged asset',
                  style: TextStyle(
                    color: AppColors.headingColor,
                    fontSize: context.text(18),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: context.h(6)),
                Text(
                  widget.assetName,
                  style: TextStyle(
                    color: AppColors.subHeadingColor,
                    fontSize: context.text(14),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: context.h(20)),
                DropdownButtonFormField<EmployeeItem>(
                  value: _selectedEmployee,
                  decoration: InputDecoration(
                    labelText: 'Employee',
                    labelStyle: TextStyle(color: AppColors.subHeadingColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(context.radius(8)),
                    ),
                  ),
                  dropdownColor: AppColors.cardBackground,
                  items: widget.employees
                      .map((e) => DropdownMenuItem<EmployeeItem>(
                            value: e,
                            child: Text(
                              '${e.name} · ${e.code}',
                              style: TextStyle(
                                color: AppColors.headingColor,
                                fontSize: context.text(14),
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedEmployee = v),
                  validator: (v) => v == null ? 'Select an employee' : null,
                ),
                SizedBox(height: context.h(16)),
                TextFormField(
                  controller: _reasonController,
                  decoration: InputDecoration(
                    labelText: 'Reason',
                    hintText: 'Describe the damage',
                    labelStyle: TextStyle(color: AppColors.subHeadingColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(context.radius(8)),
                    ),
                  ),
                  style: TextStyle(color: AppColors.headingColor),
                  maxLines: 3,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Enter a reason';
                    return null;
                  },
                ),
                SizedBox(height: context.h(16)),
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(context.radius(8)),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Damage date',
                      labelStyle: TextStyle(color: AppColors.subHeadingColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(context.radius(8)),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDate(_damageDate),
                          style: TextStyle(
                            color: AppColors.headingColor,
                            fontSize: context.text(14),
                          ),
                        ),
                        Icon(
                          Icons.calendar_today_outlined,
                          color: AppColors.subHeadingColor,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: context.h(24)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: AppColors.subHeadingColor),
                      ),
                    ),
                    SizedBox(width: context.w(8)),
                    FilledButton(
                      onPressed: _onSubmit,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.redColor,
                      ),
                      child: const Text('Report damage'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
