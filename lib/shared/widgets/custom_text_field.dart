import 'package:flutter/material.dart';

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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: TextFormField(
        controller: controller,
        onTap: onTap,
        readOnly: readOnly,
        onFieldSubmitted: onFieldSubmitted,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.zero,
          hintText: hintText,
          hintStyle: TextStyle(
            color: AppThemeDark.primary,
            fontFamily: "cairo",
          ),
          prefixIcon: IconButton(
            onPressed: prefixCallBack,
            icon: Icon(Icons.search, color: AppThemeDark.primary, size: 26),
          ),
          suffixIcon: suffixIcon,
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
      ),
    );
  }
}
