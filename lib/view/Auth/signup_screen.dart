import 'package:asset_flow/Core/Constants/app_assets.dart';
import 'package:asset_flow/Core/Constants/app_colors.dart';
import 'package:asset_flow/Core/Constants/size_extension.dart';
import 'package:asset_flow/Core/utils/Routes/routes_name.dart';
import 'package:asset_flow/Core/Widget/custom_text_field.dart';
import 'package:asset_flow/Core/Widget/normal_text.dart';
import 'package:asset_flow/viewModel/signup_screen_view_model.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    final vm = context.read<SignupScreenViewModel>();
    vm.clearError();
    if (!_formKey.currentState!.validate()) return;

    final success = await vm.signUp(
      _emailController.text,
      _usernameController.text,
      _passwordController.text,
      _confirmPasswordController.text,
    );
    if (!mounted) return;
    if (success) {
      _hideTopBanner(context);
      Navigator.pushReplacementNamed(context, RoutesName.dashboardScreen);
    } else {
      _showTopSnackBar(context, vm.errorMessage ?? 'Something went wrong', isError: true);
    }
  }

  void _hideTopBanner(BuildContext context) {
    try {
      ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
    } catch (_) {}
  }

  void _showTopSnackBar(BuildContext context, String message,
      {bool isError = true}) {
    _hideTopBanner(context);
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        leading: Icon(
          isError ? Icons.error_outline : Icons.check_circle_outline,
          color: Colors.white,
        ),
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
            },
            child: const Text('DISMISS', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pimaryColor,
      body: Padding(
        padding: context.padSym(h: 40),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: context.h(40)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(AppAssets.logoIcon, fit: BoxFit.scaleDown),
                  SizedBox(width: context.w(34)),
                  NormalText(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    titleText: 'Asset Flow',
                    titleSize: context.text(37),
                    titleWeight: FontWeight.w600,
                    titleColor: AppColors.headingColor,
                  ),
                ],
              ),
              SizedBox(height: context.h(20)),
              Container(
                padding: context.padSym(h: 30, v: 24),
                decoration: BoxDecoration(
                  color: AppColors.contColor.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(context.radius(8)),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      NormalText(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        titleText: 'Welcome',
                        titleSize: context.text(20),
                        titleWeight: FontWeight.w600,
                        titleColor: AppColors.headingColor,
                        sizeBoxheight: context.h(12),
                        subText: 'Sign up to your account',
                        subSize: context.text(16),
                        subWeight: FontWeight.w500,
                        subColor: AppColors.subHeadingColor,
                      ),
                      SizedBox(height: context.h(20)),
                      CustomTextField(
                        controller: _emailController,
                        labelText: 'Email',
                        hintText: 'Enter email',
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Email is required';
                          }
                          if (!v.contains('@') || !v.contains('.')) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: context.h(20)),
                      CustomTextField(
                        controller: _usernameController,
                        labelText: 'Username',
                        hintText: 'Enter username',
                        keyboardType: TextInputType.text,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Username is required';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: context.h(20)),
                      CustomTextField(
                        controller: _passwordController,
                        labelText: 'Password',
                        hintText: 'Enter password',
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: AppColors.contColor,
                          ),
                          onPressed: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                        ),
                        validator: (v) {
                          if (v == null || v.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: context.h(20)),
                      CustomTextField(
                        controller: _confirmPasswordController,
                        labelText: 'Confirm Password',
                        hintText: 'Enter confirm password',
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: _obscureConfirmPassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: AppColors.contColor,
                          ),
                          onPressed: () {
                            setState(() =>
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword);
                          },
                        ),
                        validator: (v) {
                          if (v == null || v.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          if (v != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: context.h(20)),
                      Consumer<SignupScreenViewModel>(
                        builder: (context, vm, child) {
                          return InkWell(
                            onTap: vm.isLoading ? null : _onSubmit,
                            child: Container(
                              padding: context.padSym(h: 20, v: 12),
                              decoration: BoxDecoration(
                                color: vm.isLoading
                                    ? AppColors.buttonColor.withOpacity(0.6)
                                    : AppColors.buttonColor,
                                borderRadius:
                                    BorderRadius.circular(context.radius(8)),
                              ),
                              child: Center(
                                child: vm.isLoading
                                    ? SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.headingColor,
                                        ),
                                      )
                                    : Text(
                                        'Sign Up',
                                        style: TextStyle(
                                          color: AppColors.headingColor,
                                          fontSize: context.text(20),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: context.h(20)),
                      Text.rich(
                        TextSpan(
                          text: 'I Already Have an Account ',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                          children: [
                            TextSpan(
                              text: 'Sign In',
                              style: const TextStyle(
                                color: AppColors.headingColor,
                                fontWeight: FontWeight.w600,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    RoutesName.loginScreen,
                                  );
                                },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: context.h(18)),
                    ],
                  ),
                ),
              ),
              SizedBox(height: context.h(40)),
            ],
          ),
        ),
      ),
    );
  }
}
