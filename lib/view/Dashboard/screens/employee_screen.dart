import 'package:asset_flow/Core/Constants/app_colors.dart';
import 'package:asset_flow/Core/Constants/size_extension.dart';
import 'package:asset_flow/Core/Model/employee_model.dart';
import 'package:asset_flow/Core/Widget/detail_row.dart';
import 'package:asset_flow/Core/Widget/filter_chips.dart';
import 'package:asset_flow/Core/Widget/primary_action_button.dart';
import 'package:asset_flow/Core/Widget/search_input_bar.dart';
import 'package:asset_flow/Core/Widget/section_title.dart';
import 'package:asset_flow/view/Dashboard/screens/add_employee_dialog.dart';
import 'package:asset_flow/viewModel/employee_screen_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EmployeeScreenContent extends StatefulWidget {
  const EmployeeScreenContent({super.key});

  @override
  State<EmployeeScreenContent> createState() => _EmployeeScreenContentState();
}

class _EmployeeScreenContentState extends State<EmployeeScreenContent> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _expandedIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployeeScreenViewModel>().fetchEmployees();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<EmployeeItem> _filteredBySearch(List<EmployeeItem> employees) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return employees;
    return employees.where((e) {
      return e.name.toLowerCase().contains(query) ||
          e.code.toLowerCase().contains(query) ||
          e.department.toLowerCase().contains(query);
    }).toList();
  }

  void _toggleExpanded(String id) {
    final vm = context.read<EmployeeScreenViewModel>();
    setState(() {
      if (_expandedIds.contains(id)) {
        _expandedIds.remove(id);
        vm.clearDetail();
      } else {
        _expandedIds.add(id);
        vm.fetchEmployeeDetail(id);
      }
    });
  }

  Future<void> _onEditEmployee(EmployeeItem employee) async {
    final vm = context.read<EmployeeScreenViewModel>();
    await vm.fetchEmployeeDetail(employee.id);
    if (!mounted) return;
    final source = vm.detailEmployee ?? employee;
    final result = await showEditEmployeeDialog(context, source);
    if (result == null || !mounted) return;
    final resignStr = result.resignationDate != null
        ? '${result.resignationDate!.year}-${result.resignationDate!.month.toString().padLeft(2, '0')}-${result.resignationDate!.day.toString().padLeft(2, '0')}'
        : null;
    final request = UpdateEmployeeRequest(
      username: result.fullName,
      department: result.department,
      status: result.status,
      resignationDate: resignStr,
    );
    final success = await vm.updateEmployeeWithApi(employee.id, request);
    if (!mounted) return;
    if (success) {
      vm.clearError();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Employee updated'),
          backgroundColor: AppColors.repairMarkFixedBg,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.errorMessage ?? 'Failed to update employee'),
          backgroundColor: AppColors.redColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EmployeeScreenViewModel>(
      builder: (context, vm, child) {
        if (vm.isLoading && vm.employees.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(context.h(48)),
              child: const CircularProgressIndicator(),
            ),
          );
        }
        if (vm.errorMessage != null && vm.employees.isEmpty) {
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
                    onPressed: vm.fetchEmployees,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final filtered = _filteredBySearch(vm.employees);

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
                          'Employees',
                          style: TextStyle(
                            color: AppColors.headingColor,
                            fontSize: context.text(24),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: context.h(4)),
                        Text(
                          'Manage employee records and asset assignments',
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
                    label: 'Add Employees',
                    icon: Icons.add,
                    onTap: () async {
                      final result = await showAddEmployeeDialog(context);
                      if (result == null || !mounted) return;
                      final vm = context.read<EmployeeScreenViewModel>();
                      if (result.email != null && result.password != null) {
                        final joinStr = result.joiningDate != null
                            ? '${result.joiningDate!.year}-${result.joiningDate!.month.toString().padLeft(2, '0')}-${result.joiningDate!.day.toString().padLeft(2, '0')}'
                            : '';
                        final resignStr = result.resignationDate != null
                            ? '${result.resignationDate!.year}-${result.resignationDate!.month.toString().padLeft(2, '0')}-${result.resignationDate!.day.toString().padLeft(2, '0')}'
                            : null;
                        final request = AddEmployeeRequest(
                          username: result.fullName,
                          email: result.email!,
                          password: result.password!,
                          department: result.department,
                          status: result.status,
                          joiningDate: joinStr,
                          resignationDate: resignStr,
                        );
                        final success = await vm.addEmployeeWithApi(request);
                        if (!mounted) return;
                        if (success) {
                          vm.clearError();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Employee added successfully'),
                              backgroundColor: AppColors.repairMarkFixedBg,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(vm.errorMessage ?? 'Failed to add employee'),
                              backgroundColor: AppColors.redColor,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      } else {
                        final joinStr = result.joiningDate != null
                            ? '${result.joiningDate!.year}-${result.joiningDate!.month.toString().padLeft(2, '0')}-${result.joiningDate!.day.toString().padLeft(2, '0')}'
                            : '';
                        final resignStr = result.resignationDate != null
                            ? '${result.resignationDate!.year}-${result.resignationDate!.month.toString().padLeft(2, '0')}-${result.resignationDate!.day.toString().padLeft(2, '0')}'
                            : null;
                        vm.addEmployee(EmployeeItem(
                          id: result.employeeId,
                          name: result.fullName,
                          initials: EmployeeItem.initialsFromName(result.fullName),
                          code: result.employeeCode,
                          department: result.department,
                          status: result.status,
                          joiningDate: joinStr,
                          resignationDate: resignStr,
                          assignedAssets: [],
                        ));
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Employee added'),
                              backgroundColor: AppColors.repairMarkFixedBg,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
              SizedBox(height: context.h(24)),
              SearchInputBar(
                controller: _searchController,
                hintText: 'Search for...',
                onChanged: (_) => setState(() {}),
              ),
              SizedBox(height: context.h(12)),
              FilterChips<EmployeeFilter>(
                selected: vm.filter,
                values: EmployeeFilter.values,
                labelBuilder: (f) => f.label,
                onSelected: vm.setFilter,
              ),
              SizedBox(height: context.h(24)),
              SectionTitle(title: 'Employees'),
              SizedBox(height: context.h(12)),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final e = filtered[index];
                  final isThisDetail = vm.detailEmployeeId == e.id;
                  return Padding(
                    key: ValueKey(e.id),
                    padding: EdgeInsets.only(bottom: context.h(12)),
                    child: EmployeeExpandableCard(
                      employee: e,
                      isExpanded: _expandedIds.contains(e.id),
                      onToggle: () => _toggleExpanded(e.id),
                      onEdit: () => _onEditEmployee(e),
                      detailEmployee: isThisDetail ? vm.detailEmployee : null,
                      detailLoading: isThisDetail && vm.detailLoading,
                      detailError: isThisDetail ? vm.detailError : null,
                      onRetryDetail: () => vm.fetchEmployeeDetail(e.id),
                    ),
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

class EmployeeExpandableCard extends StatelessWidget {
  final EmployeeItem employee;
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback? onEdit;
  final EmployeeItem? detailEmployee;
  final bool detailLoading;
  final String? detailError;
  final VoidCallback? onRetryDetail;

  const EmployeeExpandableCard({
    super.key,
    required this.employee,
    required this.isExpanded,
    required this.onToggle,
    this.onEdit,
    this.detailEmployee,
    this.detailLoading = false,
    this.detailError,
    this.onRetryDetail,
  });

  static Color _statusColor(String status) {
    switch (status) {
      case 'Active':
        return AppColors.statusPillActive;
      case 'Resigned':
        return AppColors.redColor;
      case 'On Hold':
        return AppColors.statusPillOnHold;
      default:
        return AppColors.statusPillActive;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.h(12)),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(context.radius(12)),
        ),
        child: Column(
          children: [
            InkWell(
              onTap: onToggle,
              borderRadius: BorderRadius.circular(context.radius(12)),
              child: Padding(
                padding: context.padAll(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: AppColors.listAvatarBg,
                            child: Text(
                              employee.initials,
                              style: TextStyle(
                                color: AppColors.headingColor,
                                fontSize: context.text(14),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(width: context.w(14)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  employee.name,
                                  style: TextStyle(
                                    color: AppColors.headingColor,
                                    fontSize: context.text(16),
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                SizedBox(height: context.h(4)),
                                Text(
                                  '${employee.code} · ${employee.department}',
                                  style: TextStyle(
                                    color: AppColors.subHeadingColor,
                                    fontSize: context.text(13),
                                    fontWeight: FontWeight.w400,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: context.padSym(h: 10, v: 6),
                            decoration: BoxDecoration(
                              color: _statusColor(employee.status),
                              borderRadius: BorderRadius.circular(
                                context.radius(20),
                              ),
                            ),
                            child: Text(
                              '${employee.status} · ${employee.assignedAssets.length} assets',
                              style: TextStyle(
                                color: AppColors.headingColor,
                                fontSize: context.text(12),
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          if (onEdit != null) ...[
                            SizedBox(width: context.w(8)),
                            IconButton(
                              onPressed: onEdit,
                              icon: Icon(
                                Icons.edit_outlined,
                                color: AppColors.headingColor,
                                size: 22,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 40,
                                minHeight: 40,
                              ),
                              tooltip: 'Edit employee',
                            ),
                          ],
                          SizedBox(width: context.w(4)),
                          Icon(
                            isExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: AppColors.headingColor,
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isExpanded) ...[
              Divider(height: 1, color: AppColors.seconderyColor),
              Padding(
                padding: context.padAll(16),
                child: detailLoading
                    ? Center(
                        child: Padding(
                          padding: context.padSym(v: 24),
                          child: const CircularProgressIndicator(),
                        ),
                      )
                    : detailError != null
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                detailError!,
                                style: TextStyle(
                                  color: AppColors.subHeadingColor,
                                  fontSize: context.text(14),
                                ),
                              ),
                              if (onRetryDetail != null) ...[
                                SizedBox(height: context.h(12)),
                                TextButton.icon(
                                  onPressed: onRetryDetail,
                                  icon: const Icon(Icons.refresh, size: 18),
                                  label: const Text('Retry'),
                                ),
                              ],
                            ],
                          )
                        : _buildDetailContent(
                            context,
                            detailEmployee ?? employee,
                          ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

Widget _buildDetailContent(BuildContext context, EmployeeItem e) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      DetailRow(label: 'Employee ID', value: e.id),
      SizedBox(height: context.h(8)),
      DetailRow(
        label: 'Joining Date',
        value: e.joiningDate,
      ),
      SizedBox(height: context.h(8)),
      DetailRow(label: 'Department', value: e.department),
      SizedBox(height: context.h(8)),
      DetailRow(
        label: 'Resignation Date',
        value: e.resignationDate ?? '—',
      ),
      SizedBox(height: context.h(16)),
      Text(
        'Assigned Assets',
        style: TextStyle(
          color: AppColors.headingColor,
          fontSize: context.text(14),
          fontWeight: FontWeight.w600,
        ),
      ),
      SizedBox(height: context.h(10)),
      if (e.assignedAssets.isEmpty)
        Text(
          'No assets assigned',
          style: TextStyle(
            color: AppColors.subHeadingColor,
            fontSize: context.text(13),
          ),
        )
      else
        ...e.assignedAssets.map(
                        (a) => Padding(
                          padding: EdgeInsets.only(bottom: context.h(8)),
                          child: Row(
                            children: [
                              Icon(
                                Icons.laptop_mac,
                                color: AppColors.subHeadingColor,
                                size: 20,
                              ),
                              SizedBox(width: context.w(10)),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      a.name,
                                      style: TextStyle(
                                        color: AppColors.headingColor,
                                        fontSize: context.text(14),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      a.assetId,
                                      style: TextStyle(
                                        color: AppColors.subHeadingColor,
                                        fontSize: context.text(12),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: context.padSym(h: 8, v: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.statusPillActive,
                                  borderRadius: BorderRadius.circular(
                                    context.radius(16),
                                  ),
                                ),
                                child: Text(
                                  a.status,
                                  style: TextStyle(
                                    color: AppColors.headingColor,
                                    fontSize: context.text(11),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
        ],
    );
}
