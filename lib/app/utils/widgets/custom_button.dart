// app/utils/widgets/custom_button.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharma_sys/app/utils/theme.dart';

enum ButtonType { primary, secondary, outline, text }
enum ButtonSize { small, medium, large }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final ButtonSize size;
  final IconData? icon;
  final bool iconLeading;
  final bool isLoading;
  final bool fullWidth;
  final Color? color;
  final Color? textColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  
  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.icon,
    this.iconLeading = true,
    this.isLoading = false,
    this.fullWidth = false,
    this.color,
    this.textColor,
    this.borderRadius,
    this.padding,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // Determine button styling based on type
    final ButtonStyle buttonStyle = _getButtonStyle(context);
    
    // Build button content
    Widget buttonContent = _buildButtonContent();
    
    // Apply fullWidth if needed
    if (fullWidth) {
      buttonContent = SizedBox(
        width: double.infinity,
        child: buttonContent,
      );
    }
    
    // Apply appropriate button widget based on type
    switch (type) {
      case ButtonType.primary:
      case ButtonType.secondary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: buttonContent,
        );
      case ButtonType.outline:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: buttonContent,
        );
      case ButtonType.text:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: buttonContent,
        );
    }
  }
  
  Widget _buildButtonContent() {
    // Get the font size based on button size
    final double fontSize = _getFontSize();
    
    // Show loading indicator when isLoading is true
    if (isLoading) {
      return SizedBox(
        height: _getLoaderSize(),
        width: _getLoaderSize(),
        child: CircularProgressIndicator(
          strokeWidth: 2.w,
          valueColor: AlwaysStoppedAnimation<Color>(
            type == ButtonType.primary ? Colors.white : AppTheme.primaryColor,
          ),
        ),
      );
    }
    
    // Show text only if no icon
    if (icon == null) {
      return Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      );
    }
    
    // Show icon + text with appropriate order
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (iconLeading) ...[
          Icon(icon, size: fontSize + 2.sp),
          SizedBox(width: 8.w),
        ],
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (!iconLeading) ...[
          SizedBox(width: 8.w),
          Icon(icon, size: fontSize + 2.sp),
        ],
      ],
    );
  }
  
  ButtonStyle _getButtonStyle(BuildContext context) {
    // Get the base colors
    final Color buttonColor = color ?? _getButtonColor();
    final Color buttonTextColor = textColor ?? _getTextColor();
    
    // Get padding based on size
    final EdgeInsetsGeometry buttonPadding = padding ?? _getPadding();
    
    // Get border radius
    final double buttonBorderRadius = borderRadius ?? 8.r;
    
    switch (type) {
      case ButtonType.primary:
        return ElevatedButton.styleFrom(
          foregroundColor: buttonTextColor,
          backgroundColor: buttonColor,
          padding: buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonBorderRadius),
          ),
          elevation: 1,
        );
      case ButtonType.secondary:
        return ElevatedButton.styleFrom(
          foregroundColor: buttonColor,
          backgroundColor: buttonColor.withOpacity(0.1),
          padding: buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonBorderRadius),
          ),
          elevation: 0,
        );
      case ButtonType.outline:
        return OutlinedButton.styleFrom(
          foregroundColor: buttonColor,
          padding: buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonBorderRadius),
          ),
          side: BorderSide(color: buttonColor),
        );
      case ButtonType.text:
        return TextButton.styleFrom(
          foregroundColor: buttonColor,
          padding: buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonBorderRadius),
          ),
        );
    }
  }
  
  Color _getButtonColor() {
    switch (type) {
      case ButtonType.primary:
      case ButtonType.outline:
      case ButtonType.text:
        return AppTheme.primaryColor;
      case ButtonType.secondary:
        return AppTheme.accentColor;
    }
  }
  
  Color _getTextColor() {
    switch (type) {
      case ButtonType.primary:
        return Colors.white;
      case ButtonType.secondary:
      case ButtonType.outline:
      case ButtonType.text:
        return AppTheme.primaryColor;
    }
  }
  
  EdgeInsetsGeometry _getPadding() {
    switch (size) {
      case ButtonSize.small:
        return EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h);
      case ButtonSize.medium:
        return EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h);
      case ButtonSize.large:
        return EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h);
    }
  }
  
  double _getFontSize() {
    switch (size) {
      case ButtonSize.small:
        return 12.sp;
      case ButtonSize.medium:
        return 14.sp;
      case ButtonSize.large:
        return 16.sp;
    }
  }
  
  double _getLoaderSize() {
    switch (size) {
      case ButtonSize.small:
        return 16.sp;
      case ButtonSize.medium:
        return 20.sp;
      case ButtonSize.large:
        return 24.sp;
    }
  }
}