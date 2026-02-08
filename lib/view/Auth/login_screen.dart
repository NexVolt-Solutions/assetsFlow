import 'package:asset_flow/Core/Constants/app_assets.dart';
import 'package:asset_flow/Core/Constants/app_colors.dart';
import 'package:asset_flow/Core/Constants/size_extension.dart';
import 'package:asset_flow/Core/utils/Routes/routes_name.dart';
import 'package:asset_flow/Core/Widget/custom_text_field.dart';
import 'package:asset_flow/Core/Widget/normal_text.dart';
import 'package:asset_flow/view/Auth/signup_screen.dart';
import 'package:asset_flow/viewModel/login_screen_view_model.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    final vm = context.read<LoginScreenViewModel>();
    vm.clearError();

    final success = await vm.login(
      _emailController.text,
      _passwordController.text,
    );
    if (!mounted) return;
    if (success) {
      Navigator.pushReplacementNamed(context, RoutesName.dashboardScreen);
    } else {
      _showErrorSnackBar(context, vm.errorMessage ?? 'Something went wrong');
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pimaryColor,
      body: Padding(
        padding: context.padSym(h: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
              child: Column(
                children: [
                  NormalText(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    titleText: 'Welcome back',
                    titleSize: context.text(20),
                    titleWeight: FontWeight.w600,
                    titleColor: AppColors.headingColor,
                    sizeBoxheight: context.h(12),
                    subText: 'Sign in to your account',
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
                  ),
                  SizedBox(height: context.h(20)),
                  Consumer<LoginScreenViewModel>(
                    builder: (context, vm, child) {
                      return CustomTextField(
                        controller: _passwordController,
                        labelText: 'Password',
                        hintText: 'Enter password',
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: vm.obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            vm.obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: AppColors.headingColor,
                          ),
                          onPressed: vm.toggleObscurePassword,
                        ),
                      );
                    },
                  ),
                  SizedBox(height: context.h(20)),
                  Consumer<LoginScreenViewModel>(
                    builder: (context, vm, child) {
                      return InkWell(
                        onTap: vm.isLoading ? null : _onSubmit,
                        child: Container(
                          padding: context.padSym(h: 20, v: 12),
                          decoration: BoxDecoration(
                            color: vm.isLoading
                                ? AppColors.buttonColor.withOpacity(0.6)
                                : AppColors.buttonColor,
                            borderRadius: BorderRadius.circular(
                              context.radius(8),
                            ),
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
                                    'Sign In',
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
                      text: "I Don't Have an Account ",
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                      children: [
                        TextSpan(
                          text: "Sign Up",
                          style: const TextStyle(
                            color: AppColors.headingColor,
                            fontWeight: FontWeight.w600,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SignUpScreen(),
                                ),
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
          ],
        ),
      ),
    );
  }
}
