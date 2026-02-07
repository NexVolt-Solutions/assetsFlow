import 'package:asset_flow/Core/Constants/app_colors.dart';
import 'package:asset_flow/Core/Constants/size_extension.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String labelText;
  final String hintText;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final bool obscureText;

  const CustomTextField({
    super.key,
    required this.labelText,
    required this.hintText,
    required this.keyboardType,
    this.suffixIcon,
    this.validator,
    this.controller,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: TextStyle(
            color: AppColors.subHeadingColor,
            fontSize: context.text(16),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: context.h(12)),
        Container(
          decoration: BoxDecoration(
            color: AppColors.pimaryColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.subHeadingColor, width: 0.5),
          ),
          child: TextFormField(
            controller: controller,
            validator: validator,
            keyboardType: keyboardType,
            obscureText: obscureText,
            style: TextStyle(
              color: AppColors.headingColor,
              fontSize: context.text(15),
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(color: AppColors.subHeadingColor),
              suffixIcon: suffixIcon,
              suffixIconColor: AppColors.headingColor,
              border: InputBorder.none,
              contentPadding: context.padSym(h: 16, v: 16),
            ),
          ),
        ),
      ],
    );
  }
}
