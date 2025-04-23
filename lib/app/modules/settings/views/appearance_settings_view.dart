// app/modules/settings/views/appearance_settings_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pharma_sys/app/utils/theme.dart';

import '../../../utils/widgets/custom_app_bar.dart';
import '../controllers/settings_controller.dart';

class AppearanceSettingsView extends GetView<SettingsController> {
  const AppearanceSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Appearance Settings',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme Mode
            Card(
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
                      'Theme Mode',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Obx(() => SwitchListTile(
                        title: Text(
                          'Dark Mode',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textPrimaryColor,
                          ),
                        ),
                        subtitle: Text(
                          'Use dark theme throughout the app',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                        value: controller.isDarkMode.value,
                        onChanged: (value) => controller.toggleThemeMode(),
                        activeColor: AppTheme.primaryColor,
                        secondary: Icon(
                          controller.isDarkMode.value
                              ? Icons.dark_mode
                              : Icons.light_mode,
                          color: controller.isDarkMode.value
                              ? AppTheme.primaryColor
                              : Colors.amber,
                        ),
                      )),
                    ),
                    SizedBox(height: 16.h),
                    const Divider(),
                    SizedBox(height: 8.h),
                    // Theme preview
                    Text(
                      'Preview',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Obx(() => Container(
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: controller.isDarkMode.value
                            ? Colors.grey[850]
                            : Colors.white,
                        borderRadius: BorderRadius.circular(8.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40.r,
                                height: 40.r,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Icon(
                                  Icons.medical_services_outlined,
                                  color: Colors.white,
                                  size: 24.r,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Sample Medicine',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: controller.isDarkMode.value
                                          ? Colors.white
                                          : AppTheme.textPrimaryColor,
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    '500mg Tablet',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: controller.isDarkMode.value
                                          ? Colors.grey[400]
                                          : AppTheme.textSecondaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Text(
                                '\$9.99',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed: null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                  disabledBackgroundColor: AppTheme.primaryColor,
                                  foregroundColor: Colors.white,
                                  disabledForegroundColor: Colors.white.withOpacity(0.8),
                                ),
                                child: const Text('Add to Cart'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 24.h),
            
            // Text Size
            Card(
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
                      'Text Size',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    
                    ListTile(
                      title: Text(
                        'Small',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      leading: Radio(
                        value: 'small',
                        groupValue: 'medium', // Default value
                        onChanged: (value) {
                          // Implement text size change
                        },
                        activeColor: AppTheme.primaryColor,
                      ),
                    ),
                    ListTile(
                      title: Text(
                        'Medium',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      leading: Radio(
                        value: 'medium',
                        groupValue: 'medium', // Default value
                        onChanged: (value) {
                          // Implement text size change
                        },
                        activeColor: AppTheme.primaryColor,
                      ),
                    ),
                    ListTile(
                      title: Text(
                        'Large',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      leading: Radio(
                        value: 'large',
                        groupValue: 'medium', // Default value
                        onChanged: (value) {
                          // Implement text size change
                        },
                        activeColor: AppTheme.primaryColor,
                      ),
                    ),
                    
                    SizedBox(height: 8.h),
                    const Divider(),
                    SizedBox(height: 8.h),
                    
                    Text(
                      'Note: Text size changes will affect the entire application. Some screens may need to be adjusted accordingly.',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontStyle: FontStyle.italic,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 24.h),
            
            // Color Scheme (Placeholder - actual implementation would require more complex theme management)
            Card(
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
                      'Color Scheme',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildColorOption(Colors.blue, isSelected: true),
                        _buildColorOption(Colors.green),
                        _buildColorOption(Colors.purple),
                        _buildColorOption(Colors.orange),
                        _buildColorOption(Colors.teal),
                      ],
                    ),
                    
                    SizedBox(height: 16.h),
                    const Divider(),
                    SizedBox(height: 8.h),
                    
                    Text(
                      'Note: Color scheme feature will be available in a future update.',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontStyle: FontStyle.italic,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 32.h),
            
            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  controller.saveSettings();
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                ),
                child: const Text('Save Appearance Settings'),
              ),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
  
  Widget _buildColorOption(Color color, {bool isSelected = false}) {
    return GestureDetector(
      onTap: () {
        // Handle color selection
      },
      child: Container(
        width: 48.r,
        height: 48.r,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.black : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: isSelected
            ? const Icon(
                Icons.check,
                color: Colors.white,
              )
            : null,
      ),
    );
  }
}