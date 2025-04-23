// app/modules/subscription/views/payment_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pharmacy_inventory_app/app/modules/subscription/controllers/subscription_controller.dart';
import 'package:pharmacy_inventory_app/app/utils/theme.dart';

class PaymentView extends GetView<SubscriptionController> {
  const PaymentView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Information'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.r),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Payment instructions card
                _buildPaymentInstructionsCard(),
                SizedBox(height: 24.h),

                // Payment method selection
                Text(
                  'Payment Method',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                SizedBox(height: 16.h),
                _buildPaymentMethodSelection(),
                SizedBox(height: 24.h),

                // Payment information form
                Text(
                  'Payment Information',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  controller: controller.phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number*',
                    hintText: 'Enter your payment account phone number',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: controller.validatePhone,
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  controller: controller.transactionIdController,
                  decoration: const InputDecoration(
                    labelText: 'Transaction ID',
                    hintText: 'Enter transaction ID (optional for demo)',
                    prefixIcon: Icon(Icons.receipt_long),
                  ),
                  validator: controller.validateTransactionId,
                ),
                SizedBox(height: 32.h),

                // Subscription summary
                _buildSubscriptionSummaryCard(),
                SizedBox(height: 24.h),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: Obx(() => ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : () {
                                controller.subscribeMonthly();
                              },
                        child: controller.isLoading.value
                            ? SizedBox(
                                height: 20.h,
                                width: 20.w,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Confirm Payment',
                                style: TextStyle(fontSize: 16.sp),
                              ),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                        ),
                      )),
                ),
                SizedBox(height: 16.h),

                // Cancel button
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: Text('Cancel'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentInstructionsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppTheme.infoColor,
                  size: 24.r,
                ),
                SizedBox(width: 12.w),
                Text(
                  'Payment Instructions',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              '1. Choose your preferred payment method',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              '2. Send 500 BDT to the following number:',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.phone_android,
                    color: AppTheme.primaryColor,
                    size: 20.r,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '01700-000000',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  IconButton(
                    icon: Icon(
                      Icons.copy,
                      color: AppTheme.primaryColor,
                      size: 18.r,
                    ),
                    onPressed: () {
                      // Copy to clipboard functionality
                      Get.snackbar(
                        'Copied',
                        'Payment number copied to clipboard',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              '3. Enter your payment phone number',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              '4. Enter the transaction ID received from payment provider (optional for demo)',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              '5. Click "Confirm Payment" to activate your subscription',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSelection() {
    return Obx(() => Column(
          children: [
            for (String method in controller.paymentMethods)
              RadioListTile<String>(
                title: Text(method),
                value: method,
                groupValue: controller.selectedPaymentMethod.value,
                onChanged: (value) {
                  if (value != null) {
                    controller.setPaymentMethod(value);
                  }
                },
                activeColor: AppTheme.primaryColor,
                contentPadding: EdgeInsets.symmetric(horizontal: 0),
              ),
          ],
        ));
  }

  Widget _buildSubscriptionSummaryCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Subscription Summary',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            SizedBox(height: 16.h),
            _buildSummaryRow('Plan', 'Monthly Subscription'),
            Divider(height: 24.h),
            _buildSummaryRow('Duration', '30 days'),
            Divider(height: 24.h),
            _buildSummaryRow('Price', '500 BDT'),
            Divider(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                Text(
                  '500 BDT',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppTheme.textSecondaryColor,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimaryColor,
          ),
        ),
      ],
    );
  }
}