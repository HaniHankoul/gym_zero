import 'package:flutter/material.dart';

import '../constants/general_sizes.dart';
import 'custom_text.dart';

class UniversalButton extends StatefulWidget {
  const UniversalButton({
    super.key,
    this.widthPortion,
    this.height,
    required this.onTap,
    required this.title,
    required this.color,
    required this.textColor,
    required this.borderColor,
    this.icon,
    this.bRadius,
    this.isLoading = false,
  });
  final VoidCallback onTap;
  final double? widthPortion;
  final double? height;
  final IconData? icon;
  final String title;
  final Color color;
  final Color textColor;
  final Color borderColor;
  final double? bRadius;
  final bool isLoading;

  @override
  State<UniversalButton> createState() => _UniversalButtonState();
}

class _UniversalButtonState extends State<UniversalButton> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (_isPressed == value) {
      return;
    }

    setState(() {
      _isPressed = value;
    });
  }

  void _handleTap() {
    if (widget.isLoading) {
      return;
    }
    widget.onTap();
    _setPressed(false);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return AnimatedScale(
      scale: _isPressed ? 0.96 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: InkWell(
        onTap: widget.isLoading ? null : _handleTap,
        onTapDown: widget.isLoading ? null : (_) => _setPressed(true),
        onTapCancel: widget.isLoading ? null : () => _setPressed(false),
        borderRadius: BorderRadius.circular(
          widget.bRadius ?? GeneralSizes.borderRadiusM,
        ),
        child: Container(
          width: widget.widthPortion == null
              ? widget.widthPortion
              : screenWidth * widget.widthPortion!,
          height: widget.height == null ? widget.height : widget.height!,
          padding: EdgeInsets.symmetric(
            horizontal: GeneralSizes.smallSize,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(
              widget.bRadius ?? GeneralSizes.borderRadiusM,
            ),
            border: Border.all(color: widget.borderColor, width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            textDirection: TextDirection.rtl,
            children: [
              // if (widget.isLoading)
              //   LottieBuilder.asset(
              //     fit: BoxFit.cover,
              //     width: 20,
              //     Assets.assetsImagesLottiesLoadingBlackDots,
              //   )
              // else if (widget.icon != null)
              Icon(widget.icon, size: 18, color: widget.textColor),
              if (!widget.isLoading)
                SizedBox(width: GeneralSizes.smallSize + 3),
              if (!widget.isLoading)
                CustomText(
                  text: widget.title,
                  color: widget.textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
