// app/modules/settings/views/shop_settings_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pharma_sys/app/utils/theme.dart';
import 'dart:io';

import '../../../utils/widgets/custom_app_bar.dart';
import '../controllers/settings_controller.dart';

class ShopSettingsView extends GetView<SettingsController> {
  const ShopSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Shop Information',
        showBackButton: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        return Form(
          key: controller.formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Shop Logo
                Center(
                  child: Stack(
                    children: [
                      Obx(() {
                        return Container(
                          width: 120.r,
                          height: 120.r,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12.r),
                            image: controller.logoPath.value != null
                                ? DecorationImage(
                                    image: FileImage(
                                      File(controller.logoPath.value!),
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: controller.logoPath.value == null
                              ? Icon(
                                  Icons.store,
                                  size: 60.r,
                                  color: Colors.grey[500],
                                )
                              : null,
                        );
                      }),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              controller.pickLogo();
                            },
                            iconSize: 20.r,
                            constraints: BoxConstraints(
                              minHeight: 40.r,
                              minWidth: 40.r,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
                
                // Basic Information
                _buildSectionTitle('Basic Information'),
                SizedBox(height: 16.h),
                
                TextFormField(
                  controller: controller.shopNameController,
                  decoration: const InputDecoration(
                    labelText: 'Shop Name*',
                    hintText: 'Enter your pharmacy name',
                    prefixIcon: Icon(Icons.store),
                  ),
                  validator: controller.validateRequired,
                ),
                SizedBox(height: 16.h),
                
                TextFormField(
                  controller: controller.addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address*',
                    hintText: 'Enter your pharmacy address',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  validator: controller.validateRequired,
                  maxLines: 2,
                ),
                SizedBox(height: 16.h),
                
                TextFormField(
                  controller: controller.phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number*',
                    hintText: 'Enter your pharmacy phone number',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: controller.validatePhone,
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 16.h),
                
                TextFormField(
                  controller: controller.emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    hintText: 'Enter your pharmacy email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: controller.validateEmail,
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 16.h),
                
                TextFormField(
                  controller: controller.websiteController,
                  decoration: const InputDecoration(
                    labelText: 'Website',
                    hintText: 'Enter your pharmacy website',
                    prefixIcon: Icon(Icons.web_outlined),
                  ),
                  validator: controller.validateWebsite,
                  keyboardType: TextInputType.url,
                ),
                SizedBox(height: 24.h),
                
                // Owner Information
                _buildSectionTitle('Owner Information'),
                SizedBox(height: 16.h),
                
                TextFormField(
                  controller: controller.ownerNameController,
                  decoration: const InputDecoration(
                    labelText: 'Owner Name',
                    hintText: 'Enter pharmacy owner name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                SizedBox(height: 24.h),
                
                // Business Registration
                _buildSectionTitle('Business Registration'),
                SizedBox(height: 16.h),
                
                TextFormField(
                  controller: controller.taxIdController,
                  decoration: const InputDecoration(
                    labelText: 'Tax ID',
                    hintText: 'Enter your pharmacy tax ID',
                    prefixIcon: Icon(Icons.confirmation_number_outlined),
                  ),
                ),
                SizedBox(height: 16.h),
                
                TextFormField(
                  controller: controller.licenseNumberController,
                  decoration: const InputDecoration(
                    labelText: 'License Number',
                    hintText: 'Enter your pharmacy license number',
                    prefixIcon: Icon(Icons.card_membership_outlined),
                  ),
                ),
                SizedBox(height: 16.h),
                
                // TextFormField(
                //   controller: controller.regNumberController,
                //   decoration: const InputDecoration(
                //     labelText: 'Registration Number',
                //     hintText: 'Enter your business registration number',
                //     prefixIcon: Icon(Icons.numbers_outlined),
                //   ),
                // ),
                SizedBox(height: 32.h),
                
                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (await controller.saveShopInfo()) {
                        Get.back();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                    ),
                    child: const Text('Save Shop Information'),
                  ),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        );
      }),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Divider(
            color: AppTheme.primaryColor.withOpacity(0.4),
            thickness: 1,
          ),
        ),
      ],
    );
  }
}