import 'package:asset_flow/Core/Constants/app_colors.dart';
import 'package:asset_flow/Core/Constants/size_extension.dart';
import 'package:flutter/material.dart';

/// Reusable search bar with leading icon.
class SearchInputBar extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;

  const SearchInputBar({
    super.key,
    this.controller,
    this.hintText = 'Search for...',
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.padSym(h: 14, v: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(context.radius(10)),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: AppColors.subHeadingColor, size: 22),
          SizedBox(width: context.w(12)),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: TextStyle(
                color: AppColors.headingColor,
                fontSize: context.text(14),
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: AppColors.subHeadingColor,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
