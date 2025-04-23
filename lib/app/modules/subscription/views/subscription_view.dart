// app/modules/subscription/views/subscription_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pharmacy_inventory_app/app/modules/subscription/controllers/subscription_controller.dart';
import 'package:pharmacy_inventory_app/app/utils/theme.dart';
import 'package:intl/intl.dart';

class SubscriptionView extends GetView<SubscriptionController> {
  const SubscriptionView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription'),
        automaticallyImplyLeading: false,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subscription status card
                _buildSubscriptionStatusCard(),
                SizedBox(height: 24.h),

                // Subscription plans
                Text(
                  'Choose a Plan',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                SizedBox(height: 16.h),

                // Monthly plan card
                _buildPlanCard(
                  title: 'Monthly Plan',
                  price: '500 BDT/month',
                  features: [
                    'Full access to all features',
                    'Unlimited medicine entries',
                    'Sales reports and analytics',
                    'Employee management',
                    'Customer database',
                    'Email support',
                  ],
                  isRecommended: true,
                  onPressed: () {
                    controller.goToPayment();
                  },
                ),
                SizedBox(height: 16.h),

                // Free trial card
                if (!controller.hasSubscription.value &&
                    controller.subscriptionHistory.isEmpty)
                  _buildTrialCard(),

                SizedBox(height: 16.h),

                // Subscription history
                if (controller.subscriptionHistory.isNotEmpty) ...[
                  Text(
                    'Subscription History',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _buildSubscriptionHistoryList(),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSubscriptionStatusCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: controller.hasSubscription.value
                        ? AppTheme.successColor.withOpacity(0.1)
                        : AppTheme.errorColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    controller.hasSubscription.value
                        ? Icons.check_circle_outline
                        : Icons.error_outline,
                    color: controller.hasSubscription.value
                        ? AppTheme.successColor
                        : AppTheme.errorColor,
                    size: 24.r,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.hasSubscription.value
                            ? 'Active Subscription'
                            : 'No Active Subscription',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: controller.hasSubscription.value
                              ? AppTheme.successColor
                              : AppTheme.errorColor,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        controller.hasSubscription.value
                            ? controller.getPlanName()
                            : 'Subscribe to access the app',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (controller.hasSubscription.value) ...[
              SizedBox(height: 16.h),
              Divider(),
              SizedBox(height: 16.h),
              _buildInfoRow(
                'Plan',
                controller.getPlanName(),
                Icons.card_membership,
              ),
              SizedBox(height: 12.h),
              _buildInfoRow(
                'Price',
                controller.getSubscriptionAmount(),
                Icons.monetization_on_outlined,
              ),
              SizedBox(height: 12.h),
              _buildInfoRow(
                'Expires On',
                controller.currentSubscription.value != null
                    ? DateFormat('MMM dd, yyyy').format(
                        controller.currentSubscription.value!.endDate,
                      )
                    : 'Unknown',
                Icons.calendar_today_outlined,
              ),
              SizedBox(height: 12.h),
              _buildInfoRow(
                'Days Remaining',
                '${controller.daysRemaining.value} days',
                Icons.timer_outlined,
              ),
              SizedBox(height: 16.h),
              if (!controller.isTrialActive.value)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      controller.cancelSubscription();
                    },
                    child: Text('Cancel Subscription'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.errorColor,
                      side: BorderSide(color: AppTheme.errorColor),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String price,
    required List<String> features,
    required VoidCallback onPressed,
    bool isRecommended = false,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          border: isRecommended
              ? Border.all(color: AppTheme.primaryColor, width: 2)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isRecommended)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Text(
                  'Recommended',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            SizedBox(height: isRecommended ? 12.h : 0),
            Text(
              title,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              price,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
                color: AppTheme.primaryColor,
              ),
            ),
            SizedBox(height: 16.h),
            ...features.map((feature) => Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppTheme.successColor,
                        size: 16.r,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          feature,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.hasSubscription.value &&
                        !controller.isTrialActive.value
                    ? null
                    : onPressed,
                child: Text(
                  controller.hasSubscription.value && !controller.isTrialActive.value
                      ? 'Current Plan'
                      : 'Subscribe Now',
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  backgroundColor: isRecommended ? AppTheme.primaryColor : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrialCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppTheme.infoColor, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppTheme.infoColor,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Text(
                'Free Trial',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              '7-Day Free Trial',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Free',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
                color: AppTheme.infoColor,
              ),
            ),
            SizedBox(height: 16.h),
            _buildFeatureRow('Access to all features for 7 days'),
            SizedBox(height: 8.h),
            _buildFeatureRow('No credit card required'),
            SizedBox(height: 8.h),
            _buildFeatureRow('Cancel anytime'),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  controller.startFreeTrial();
                },
                child: Text('Start Free Trial'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  backgroundColor: AppTheme.infoColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(String text) {
    return Row(
      children: [
        Icon(
          Icons.check_circle,
          color: AppTheme.successColor,
          size: 16.r,
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16.r,
          color: AppTheme.textSecondaryColor,
        ),
        SizedBox(width: 8.w),
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 14.sp,
            color: AppTheme.textSecondaryColor,
          ),
        ),
        SizedBox(width: 8.w),
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

  Widget _buildSubscriptionHistoryList() {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: controller.subscriptionHistory.length,
      itemBuilder: (context, index) {
        final subscription = controller.subscriptionHistory[index];
        final isActive = !subscription.isExpired();
        
        return Card(
          margin: EdgeInsets.only(bottom: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: ListTile(
            leading: Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: isActive
                    ? AppTheme.successColor.withOpacity(0.1)
                    : AppTheme.textSecondaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isActive ? Icons.check_circle_outline : Icons.history,
                color: isActive
                    ? AppTheme.successColor
                    : AppTheme.textSecondaryColor,
                size: 20.r,
              ),
            ),
            title: Text(
              subscription.planType.capitalize!,
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              '${DateFormat('MMM dd, yyyy').format(subscription.startDate)} - ${DateFormat('MMM dd, yyyy').format(subscription.endDate)}',
              style: TextStyle(
                fontSize: 12.sp,
              ),
            ),
            trailing: Text(
              '${subscription.amount} ${subscription.currency}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        );
      },
    );
  }
}