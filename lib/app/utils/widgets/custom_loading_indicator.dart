// app/utils/widgets/custom_loading_indicator.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharmacy_inventory_app/app/utils/theme.dart';

class CustomLoadingIndicator extends StatelessWidget {
  final double size;
  final Color color;
  final String? message;
  final bool isOverlay;
  final bool isDismissible;

  const CustomLoadingIndicator({
    Key? key,
    this.size = 40,
    this.color = AppTheme.primaryColor,
    this.message,
    this.isOverlay = false,
    this.isDismissible = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Widget loadingWidget = Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: size.r,
            width: size.r,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(color),
              strokeWidth: 3.w,
            ),
          ),
          if (message != null) ...[
            SizedBox(height: 16.h),
            Text(
              message!,
              style: TextStyle(
                fontSize: 14.sp,
                color: isOverlay ? Colors.white : AppTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );

    if (isOverlay) {
      return WillPopScope(
        onWillPop: () async => isDismissible,
        child: Stack(
          children: [
            const ModalBarrier(
              dismissible: false,
              color: Colors.black54,
            ),
            loadingWidget,
          ],
        ),
      );
    }

    return loadingWidget;
  }

  // Show the loading indicator as a dialog
  static void show({
    String? message,
    bool isDismissible = false,
  }) {
    showDialog(
      context: Get.context!,
      barrierDismissible: isDismissible,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => isDismissible,
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: CustomLoadingIndicator(
              message: message,
              isOverlay: true,
              isDismissible: isDismissible,
            ),
          ),
        );
      },
    );
  }

  // Hide the loading indicator dialog
  static void hide() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  // Show the loading indicator with a transparent background
  static void showTransparent({
    String? message,
    bool isDismissible = false,
  }) {
    showDialog(
      context: Get.context!,
      barrierColor: Colors.transparent,
      barrierDismissible: isDismissible,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => isDismissible,
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: CustomLoadingIndicator(
              message: message,
              isDismissible: isDismissible,
            ),
          ),
        );
      },
    );
  }

  // Overlay the loading indicator on the screen
  static OverlayEntry? overlayEntry;
  
  static void showOverlay({String? message}) {
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
        child: Material(
          color: Colors.transparent,
          child: CustomLoadingIndicator(
            message: message,
            isOverlay: true,
          ),
        ),
      ),
    );
    
    if (overlayEntry != null) {
      Overlay.of(Get.context!).insert(overlayEntry!);
    }
  }

  // Hide the overlay loading indicator
  static void hideOverlay() {
    overlayEntry?.remove();
    overlayEntry = null;
  }
}