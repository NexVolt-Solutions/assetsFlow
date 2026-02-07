import 'package:asset_flow/Core/Constants/app_colors.dart';
import 'package:asset_flow/Core/Constants/size_extension.dart';
import 'package:flutter/material.dart';

class ProfileManagementScreenContent extends StatefulWidget {
  const ProfileManagementScreenContent({super.key});

  @override
  State<ProfileManagementScreenContent> createState() =>
      _ProfileManagementScreenContentState();
}

class _ProfileManagementScreenContentState
    extends State<ProfileManagementScreenContent> {
  bool _isEditing = false;

  String _fullName = 'Sarah Mitchell';
  String _email = 'sarah.mitchell@acmeassets.com';
  final String _role = 'Admin';
  bool _isActive = true;
  final String _username = 's.mitchell';

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = _fullName;
    _emailController.text = _email;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _startEdit() {
    _nameController.text = _fullName;
    _emailController.text = _email;
    setState(() => _isEditing = true);
  }

  void _cancelEdit() {
    _nameController.text = _fullName;
    _emailController.text = _email;
    setState(() => _isEditing = false);
  }

  void _saveProfile() {
    setState(() {
      _fullName = _nameController.text.trim().isEmpty
          ? _fullName
          : _nameController.text.trim();
      _email = _emailController.text.trim().isEmpty
          ? _email
          : _emailController.text.trim();
      _isEditing = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile updated successfully'),
          backgroundColor: AppColors.repairMarkFixedBg,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (ctx) => _ChangePasswordDialog(
        onChanged: () {
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
                  onEdit: _startEdit,
                  onCancel: _cancelEdit,
                  onSave: _saveProfile,
                  nameController: _nameController,
                  emailController: _emailController,
                  fullName: _fullName,
                  email: _email,
                  role: _role,
                  isActive: _isActive,
                ),
                SizedBox(height: context.h(20)),
                _AccountDetailsCard(
                  username: _username,
                  onChangePassword: _showChangePasswordDialog,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.title,
    required this.isEditing,
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
                  onPressed: onEdit,
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
                  onPressed: onCancel,
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
                  onPressed: onSave,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.buttonColor,
                    foregroundColor: AppColors.headingColor,
                    padding: context.padSym(h: 20, v: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(context.radius(8)),
                    ),
                  ),
                  child: Text(
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
  const _ChangePasswordDialog({required this.onChanged});

  final VoidCallback onChanged;

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

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() {
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
    Navigator.of(context).pop();
    widget.onChanged();
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
                    if (v.length < 6)
                      return 'Password must be at least 6 characters';
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
                      onPressed: () => Navigator.of(context).pop(),
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
                      onPressed: _submit,
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
                      child: Text(
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
