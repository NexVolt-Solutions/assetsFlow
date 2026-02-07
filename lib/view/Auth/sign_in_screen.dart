import 'package:asset_flow/Core/Constants/app_assets.dart';
import 'package:asset_flow/Core/Constants/app_colors.dart';
import 'package:asset_flow/Core/Constants/size_extension.dart';
import 'package:asset_flow/Core/Widget/custom_text_field.dart';
import 'package:asset_flow/Core/Widget/normal_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
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
                    subText: 'Sign up to your account',
                    subSize: context.text(16),
                    subWeight: FontWeight.w500,
                    subColor: AppColors.subHeadingColor,
                  ),
                  SizedBox(height: context.h(20)),
                  CustomTextField(
                    labelText: "Name",
                    hintText: "Enter name",
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "name is required";
                      }
                      if (!value.contains("@")) {
                        return "Enter valid name";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: context.h(20)),
                  CustomTextField(
                    labelText: "Email",
                    hintText: "Enter email",
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Email is required";
                      }
                      if (!value.contains("@")) {
                        return "Enter valid email";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: context.h(20)),
                  CustomTextField(
                    labelText: "Password",
                    hintText: "Enter password",
                    keyboardType: TextInputType.text,
                    obscureText: true,
                    suffixIcon: Icon(
                      Icons.visibility,
                      color: AppColors.contColor,
                    ),
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return "Password must be 6 characters";
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: context.h(20)),
                  CustomTextField(
                    labelText: "Confirm Password",
                    hintText: "Enter confirm password",
                    keyboardType: TextInputType.text,
                    obscureText: true,
                    suffixIcon: Icon(
                      Icons.visibility,
                      color: AppColors.contColor,
                    ),
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return "Password must be 6 characters";
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: context.h(20)),
                  Container(
                    padding: context.padSym(h: 20, v: 12),
                    decoration: BoxDecoration(
                      color: AppColors.buttonColor,
                      borderRadius: BorderRadius.circular(context.radius(8)),
                    ),
                    child: Center(
                      child: Text(
                        'Sign In',
                        style: TextStyle(
                          color: AppColors.headingColor,
                          fontSize: context.text(20),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                   SizedBox(height: context.h(20)),
                  Text.rich(
                    TextSpan(
                      text: "I Already Have an Account",
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                      children: [
                        TextSpan(
                          text: "Sign In",
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
