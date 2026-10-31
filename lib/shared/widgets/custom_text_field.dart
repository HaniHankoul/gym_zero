import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../theme/app_theme.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    this.onFieldSubmitted,
    this.onTap,
    this.readOnly = false,
    this.controller,
    this.suffixIcon,
    required this.hintText,
    required this.icon,
    this.prefixCallBack,
  });
  final Function(String)? onFieldSubmitted;
  final VoidCallback? onTap;
  final bool readOnly;
  final TextEditingController? controller;
  final Widget? suffixIcon;
  final String hintText;
  final List<List<dynamic>> icon;
  final VoidCallback? prefixCallBack;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      cursorColor: AppThemeDark.primary,
      style: TextStyle(color: AppThemeDark.textWhite, fontFamily: "cairo"),
      controller: controller,
      onTap: onTap,
      readOnly: readOnly,
      onChanged: onFieldSubmitted,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: AppThemeDark.primary, fontFamily: "cairo"),
        // prefixIcon: IconButton(
        //   onPressed: prefixCallBack,
        //   icon: Icon(Icons.search, color: AppThemeDark.primary, size: 26),
        // ),
        suffixIcon: SizedBox(
          height: 1,
          child: HugeIcon(
            icon: icon,
            size: 15,
            color: AppThemeDark.primary,
            strokeWidth: 1,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppThemeDark.primary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppThemeDark.primary, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppThemeDark.primary, width: 3),
        ),
        filled: true,
        fillColor: AppThemeDark.primaryLight,
      ),
    );
  }
}
