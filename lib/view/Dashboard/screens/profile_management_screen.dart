import 'package:asset_flow/Core/Constants/app_colors.dart';
import 'package:asset_flow/Core/Constants/size_extension.dart';
import 'package:asset_flow/viewModel/profile_management_screen_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileManagementScreenContent extends StatefulWidget {
  const ProfileManagementScreenContent({super.key});

  @override
  State<ProfileManagementScreenContent> createState() =>
      _ProfileManagementScreenContentState();
}

class _ProfileManagementScreenContentState
    extends State<ProfileManagementScreenContent> {
  bool _isEditing = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileManagementScreenViewModel>().fetchProfile();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _startEdit(BuildContext context) {
    final vm = context.read<ProfileManagementScreenViewModel>();
    _nameController.text = vm.displayFullName;
    _emailController.text = vm.displayEmail;
    setState(() => _isEditing = true);
  }

  void _cancelEdit(BuildContext context) {
    final vm = context.read<ProfileManagementScreenViewModel>();
    _nameController.text = vm.displayFullName;
    _emailController.text = vm.displayEmail;
    setState(() => _isEditing = false);
  }

  Future<void> _saveProfile(BuildContext context) async {
    final vm = context.read<ProfileManagementScreenViewModel>();
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final fullName = name.isEmpty ? vm.displayFullName : name;
    final emailVal = email.isEmpty ? vm.displayEmail : email;
    final success = await vm.updateProfile(fullName: fullName, email: emailVal);
    if (!mounted) return;
    if (success) {
      setState(() => _isEditing = false);
      vm.clearError();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile updated successfully'),
          backgroundColor: AppColors.repairMarkFixedBg,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.errorMessage ?? 'Failed to update profile'),
          backgroundColor: AppColors.redColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showChangePasswordDialog() {
    final vm = context.read<ProfileManagementScreenViewModel>();
    showDialog(
      context: context,
      builder: (ctx) => _ChangePasswordDialog(
        onSubmit: (current, newPw, confirm) => vm.changePassword(
          currentPassword: current,
          newPassword: newPw,
          confirmNewPassword: confirm,
        ),
        onSuccess: () {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Password changed successfully'),
                backgroundColor: AppColors.repairMarkFixedBg,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileManagementScreenViewModel>(
      builder: (context, vm, child) {
        if (vm.isLoading && vm.profile == null) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(context.h(48)),
              child: const CircularProgressIndicator(),
            ),
          );
        }
        if (vm.errorMessage != null && vm.profile == null) {
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
                    onPressed: vm.fetchProfile,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }
        return LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 600;
            final padding = EdgeInsets.fromLTRB(
              context.w(isNarrow ? 16 : 24),
              0,
              context.w(isNarrow ? 16 : 24),
              context.h(24),
            );
            return SingleChildScrollView(
              padding: padding,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 720,
                  minHeight: constraints.maxHeight,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profile Management',
                      style: TextStyle(
                        color: AppColors.headingColor,
                        fontSize: context.text(24),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: context.h(8)),
                    Text(
                      'Personal Information',
                      style: TextStyle(
                        color: AppColors.subHeadingColor,
                        fontSize: context.text(14),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: context.h(24)),
                    _ProfileCard(
                      title: 'Profile Information',
                      isEditing: _isEditing,
                      isSaving: vm.isSaving,
                      onEdit: () => _startEdit(context),
                      onCancel: () => _cancelEdit(context),
                      onSave: () => _saveProfile(context),
                      nameController: _nameController,
                      emailController: _emailController,
                      fullName: vm.displayFullName,
                      email: vm.displayEmail,
                      role: vm.department,
                      isActive: vm.isActive,
                    ),
                    SizedBox(height: context.h(20)),
                    _AccountDetailsCard(
                      username: vm.username,
                      onChangePassword: _showChangePasswordDialog,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.title,
    required this.isEditing,
    required this.isSaving,
    required this.onEdit,
    required this.onCancel,
    required this.onSave,
    required this.nameController,
    required this.emailController,
    required this.fullName,
    required this.email,
    required this.role,
    required this.isActive,
  });

  final String title;
  final bool isEditing;
  final bool isSaving;
  final VoidCallback onEdit;
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final String fullName;
  final String email;
  final String role;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: context.padSym(h: context.width >= 400 ? 24 : 16, v: 20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(context.radius(12)),
        border: Border.all(
          color: AppColors.seconderyColor.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppColors.headingColor,
                  fontSize: context.text(18),
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (!isEditing)
                TextButton(
                  onPressed: isSaving ? null : onEdit,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.headingColor,
                  ),
                  child: Text(
                    'Edit',
                    style: TextStyle(
                      fontSize: context.text(14),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: context.h(20)),
          if (isEditing) ...[
            _LabeledField(
              label: 'Full Name',
              child: TextFormField(
                controller: nameController,
                style: TextStyle(
                  color: AppColors.headingColor,
                  fontSize: context.text(14),
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.seconderyColor.withValues(alpha: 0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(context.radius(8)),
                    borderSide: BorderSide(color: AppColors.dropdownBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(context.radius(8)),
                    borderSide: BorderSide(color: AppColors.dropdownBorder),
                  ),
                  contentPadding: context.padSym(h: 12, v: 12),
                ),
              ),
            ),
            SizedBox(height: context.h(16)),
            _LabeledField(
              label: 'Email',
              child: TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(
                  color: AppColors.headingColor,
                  fontSize: context.text(14),
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.seconderyColor.withValues(alpha: 0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(context.radius(8)),
                    borderSide: BorderSide(color: AppColors.dropdownBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(context.radius(8)),
                    borderSide: BorderSide(color: AppColors.dropdownBorder),
                  ),
                  contentPadding: context.padSym(h: 12, v: 12),
                ),
              ),
            ),

            SizedBox(height: context.h(16)),
            _LabeledField(
              label: 'Status',
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.repairFixedIconGreen
                          : AppColors.statusPillOnHold,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: context.w(8)),
                  Text(
                    isActive ? 'Active' : 'On Hold',
                    style: TextStyle(
                      color: AppColors.headingColor,
                      fontSize: context.text(14),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: context.h(24)),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: isSaving ? null : onCancel,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.headingColor,
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(fontSize: context.text(14)),
                  ),
                ),
                SizedBox(width: context.w(12)),
                FilledButton(
                  onPressed: isSaving ? null : onSave,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.buttonColor,
                    foregroundColor: AppColors.headingColor,
                    padding: context.padSym(h: 20, v: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(context.radius(8)),
                    ),
                  ),
                  child: isSaving
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.headingColor,
                          ),
                        )
                      : Text(
                          'Save',
                          style: TextStyle(
                            fontSize: context.text(14),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ],
            ),
          ] else ...[
            _ProfileRow(label: 'Full Name', value: fullName),
            SizedBox(height: context.h(14)),
            _ProfileRow(label: 'Email', value: email),

            SizedBox(height: context.h(14)),
            _ProfileRow(
              label: 'Status',
              value: isActive ? 'Active' : 'On Hold',
              trailing: Container(
                width: 8,
                height: 8,
                margin: EdgeInsets.only(left: context.w(8)),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.repairFixedIconGreen
                      : AppColors.statusPillOnHold,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({required this.label, required this.value, this.trailing});

  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: context.width >= 400 ? 120 : 90,
          child: Text(
            label,
            style: TextStyle(
              color: AppColors.subHeadingColor,
              fontSize: context.text(14),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    color: AppColors.headingColor,
                    fontSize: context.text(14),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (trailing != null) ...[
                SizedBox(width: context.w(4)),
                trailing!,
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.subHeadingColor,
            fontSize: context.text(12),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: context.h(6)),
        child,
      ],
    );
  }
}

class _AccountDetailsCard extends StatelessWidget {
  const _AccountDetailsCard({
    required this.username,
    required this.onChangePassword,
  });

  final String username;
  final VoidCallback onChangePassword;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: context.padSym(h: context.width >= 400 ? 24 : 16, v: 20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(context.radius(12)),
        border: Border.all(
          color: AppColors.seconderyColor.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account Details',
            style: TextStyle(
              color: AppColors.headingColor,
              fontSize: context.text(18),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: context.h(20)),
          _ProfileRow(label: 'Username', value: username),
          SizedBox(height: context.h(14)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: context.width >= 400 ? 120 : 90,
                child: Text(
                  'Password',
                  style: TextStyle(
                    color: AppColors.subHeadingColor,
                    fontSize: context.text(14),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onChangePassword,
                  borderRadius: BorderRadius.circular(context.radius(8)),
                  child: Padding(
                    padding: context.padSym(h: 12, v: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.key,
                          size: 18,
                          color: AppColors.headingColor,
                        ),
                        SizedBox(width: context.w(8)),
                        Text(
                          'Change Password',
                          style: TextStyle(
                            color: AppColors.headingColor,
                            fontSize: context.text(14),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog({
    required this.onSubmit,
    required this.onSuccess,
  });

  final Future<({bool success, String? errorMessage})> Function(
    String currentPassword,
    String newPassword,
    String confirmNewPassword,
  ) onSubmit;
  final VoidCallback onSuccess;

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_newController.text != _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('New password and confirm password do not match'),
          backgroundColor: AppColors.redColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    final result = await widget.onSubmit(
      _currentController.text,
      _newController.text,
      _confirmController.text,
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    if (result.success) {
      Navigator.of(context).pop();
      widget.onSuccess();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorMessage ?? 'Failed to change password'),
          backgroundColor: AppColors.redColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.radius(16)),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 400,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: SingleChildScrollView(
          padding: context.padAll(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Change Password',
                  style: TextStyle(
                    color: AppColors.headingColor,
                    fontSize: context.text(20),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: context.h(8)),
                Text(
                  'Enter your current password and choose a new one.',
                  style: TextStyle(
                    color: AppColors.subHeadingColor,
                    fontSize: context.text(14),
                  ),
                ),
                SizedBox(height: context.h(24)),
                TextFormField(
                  controller: _currentController,
                  obscureText: _obscureCurrent,
                  style: TextStyle(
                    color: AppColors.headingColor,
                    fontSize: context.text(14),
                  ),
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    labelStyle: TextStyle(color: AppColors.subHeadingColor),
                    filled: true,
                    fillColor: AppColors.seconderyColor.withValues(alpha: 0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(context.radius(8)),
                      borderSide: BorderSide(color: AppColors.dropdownBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(context.radius(8)),
                      borderSide: BorderSide(color: AppColors.dropdownBorder),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureCurrent
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppColors.subHeadingColor,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscureCurrent = !_obscureCurrent),
                    ),
                  ),
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'Enter current password'
                      : null,
                ),
                SizedBox(height: context.h(16)),
                TextFormField(
                  controller: _newController,
                  obscureText: _obscureNew,
                  style: TextStyle(
                    color: AppColors.headingColor,
                    fontSize: context.text(14),
                  ),
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    labelStyle: TextStyle(color: AppColors.subHeadingColor),
                    filled: true,
                    fillColor: AppColors.seconderyColor.withValues(alpha: 0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(context.radius(8)),
                      borderSide: BorderSide(color: AppColors.dropdownBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(context.radius(8)),
                      borderSide: BorderSide(color: AppColors.dropdownBorder),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureNew ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.subHeadingColor,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscureNew = !_obscureNew),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter new password';
                    if (v.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                SizedBox(height: context.h(16)),
                TextFormField(
                  controller: _confirmController,
                  obscureText: _obscureConfirm,
                  style: TextStyle(
                    color: AppColors.headingColor,
                    fontSize: context.text(14),
                  ),
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    labelStyle: TextStyle(color: AppColors.subHeadingColor),
                    filled: true,
                    fillColor: AppColors.seconderyColor.withValues(alpha: 0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(context.radius(8)),
                      borderSide: BorderSide(color: AppColors.dropdownBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(context.radius(8)),
                      borderSide: BorderSide(color: AppColors.dropdownBorder),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppColors.subHeadingColor,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'Confirm your new password'
                      : null,
                ),
                SizedBox(height: context.h(28)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.headingColor,
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(fontSize: context.text(14)),
                      ),
                    ),
                    SizedBox(width: context.w(12)),
                    FilledButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.buttonColor,
                        foregroundColor: AppColors.headingColor,
                        padding: context.padSym(h: 20, v: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            context.radius(8),
                          ),
                        ),
                      ),
                      child: _isSubmitting
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.headingColor,
                              ),
                            )
                          : Text(
                              'Change Password',
                              style: TextStyle(
                                fontSize: context.text(14),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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
