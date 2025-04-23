// app/utils/widgets/custom_alert_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pharmacy_inventory_app/app/utils/theme.dart';

enum DialogType { info, success, warning, error, confirmation }

class CustomAlertDialog extends StatelessWidget {
  final String title;
  final String message;
  final DialogType type;
  final String? primaryButtonText;
  final String? secondaryButtonText;
  final VoidCallback? onPrimaryButtonPressed;
  final VoidCallback? onSecondaryButtonPressed;
  final Widget? content;
  final bool isDismissible;

  const CustomAlertDialog({
    Key? key,
    required this.title,
    required this.message,
    this.type = DialogType.info,
    this.primaryButtonText,
    this.secondaryButtonText,
    this.onPrimaryButtonPressed,
    this.onSecondaryButtonPressed,
    this.content,
    this.isDismissible = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      title: Row(
        children: [
          _buildIcon(),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: _getDialogColor(),
              ),
            ),
          ),
          if (isDismissible)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Get.back(),
              iconSize: 20.r,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              color: AppTheme.textSecondaryColor,
            ),
        ],
      ),
      content: content != null
          ? content!
          : Text(
              message,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppTheme.textPrimaryColor,
              ),
            ),
      actions: _buildActions(),
      contentPadding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 8.h),
      actionsPadding: EdgeInsets.all(16.r),
      titlePadding: EdgeInsets.fromLTRB(24.w, 16.h, 16.w, 0),
    );
  }

  Widget _buildIcon() {
    IconData iconData;
    
    switch (type) {
      case DialogType.success:
        iconData = Icons.check_circle;
        break;
      case DialogType.warning:
        iconData = Icons.warning_amber_rounded;
        break;
      case DialogType.error:
        iconData = Icons.error;
        break;
      case DialogType.confirmation:
        iconData = Icons.help_outline;
        break;
      case DialogType.info:
      default:
        iconData = Icons.info_outline;
        break;
    }
    
    return Icon(
      iconData,
      color: _getDialogColor(),
      size: 24.r,
    );
  }

  List<Widget> _buildActions() {
    final List<Widget> actions = [];

    // Add secondary button if text is provided
    if (secondaryButtonText != null) {
      actions.add(
        TextButton(
          onPressed: onSecondaryButtonPressed ?? () => Get.back(),
          child: Text(
            secondaryButtonText!,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ),
      );
    }

    // Add primary button if text is provided
    if (primaryButtonText != null) {
      actions.add(
        ElevatedButton(
          onPressed: onPrimaryButtonPressed ?? () => Get.back(),
          style: ElevatedButton.styleFrom(
            backgroundColor: _getDialogColor(),
          ),
          child: Text(
            primaryButtonText!,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    return actions;
  }

  Color _getDialogColor() {
    switch (type) {
      case DialogType.success:
        return AppTheme.successColor;
      case DialogType.warning:
        return AppTheme.warningColor;
      case DialogType.error:
        return AppTheme.errorColor;
      case DialogType.confirmation:
        return AppTheme.primaryColor;
      case DialogType.info:
      default:
        return AppTheme.infoColor;
    }
  }
  
  // Static helper methods for easy dialog creation
  
  static void showInfo({
    required String title,
    required String message,
    String? buttonText,
    VoidCallback? onPressed,
    bool isDismissible = true,
  }) {
    Get.dialog(
      CustomAlertDialog(
        title: title,
        message: message,
        type: DialogType.info,
        primaryButtonText: buttonText ?? 'OK',
        onPrimaryButtonPressed: onPressed,
        isDismissible: isDismissible,
      ),
      barrierDismissible: isDismissible,
    );
  }
  
  static void showSuccess({
    required String title,
    required String message,
    String? buttonText,
    VoidCallback? onPressed,
    bool isDismissible = true,
  }) {
    Get.dialog(
      CustomAlertDialog(
        title: title,
        message: message,
        type: DialogType.success,
        primaryButtonText: buttonText ?? 'OK',
        onPrimaryButtonPressed: onPressed,
        isDismissible: isDismissible,
      ),
      barrierDismissible: isDismissible,
    );
  }
  
  static void showWarning({
    required String title,
    required String message,
    String? buttonText,
    VoidCallback? onPressed,
    bool isDismissible = true,
  }) {
    Get.dialog(
      CustomAlertDialog(
        title: title,
        message: message,
        type: DialogType.warning,
        primaryButtonText: buttonText ?? 'OK',
        onPrimaryButtonPressed: onPressed,
        isDismissible: isDismissible,
      ),
      barrierDismissible: isDismissible,
    );
  }
  
  static void showError({
    required String title,
    required String message,
    String? buttonText,
    VoidCallback? onPressed,
    bool isDismissible = true,
  }) {
    Get.dialog(
      CustomAlertDialog(
        title: title,
        message: message,
        type: DialogType.error,
        primaryButtonText: buttonText ?? 'OK',
        onPrimaryButtonPressed: onPressed,
        isDismissible: isDismissible,
      ),
      barrierDismissible: isDismissible,
    );
  }
  
  static Future<bool?> showConfirmation({
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool isDismissible = true,
  }) async {
    return await Get.dialog<bool>(
      CustomAlertDialog(
        title: title,
        message: message,
        type: DialogType.confirmation,
        primaryButtonText: confirmText,
        secondaryButtonText: cancelText,
        onPrimaryButtonPressed: () {
          Get.back(result: true);
          if (onConfirm != null) onConfirm();
        },
        onSecondaryButtonPressed: () {
          Get.back(result: false);
          if (onCancel != null) onCancel();
        },
        isDismissible: isDismissible,
      ),
      barrierDismissible: isDismissible,
    );
  }
}