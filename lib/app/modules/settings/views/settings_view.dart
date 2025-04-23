// app/modules/settings/views/settings_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pharma_sys/app/core/widgets/custom_drawer.dart';
import 'package:pharma_sys/app/utils/theme.dart';

import '../../../utils/widgets/custom_app_bar.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Settings',
      ),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shop Info Settings
            _buildSettingsCard(
              context: context,
              title: 'Shop Information',
              icon: Icons.store,
              description: 'Manage your shop details, contact information, and business identification',
              onTap: () => {}
              // controller.goToShopSettings(),
            ),
            
            SizedBox(height: 16.h),
            
            // Appearance Settings
            _buildSettingsCard(
              context: context,
              title: 'Appearance',
              icon: Icons.palette_outlined,
              description: 'Customize theme, layout, and visual preferences',
              onTap: () =>{},
              //  controller.goToAppearanceSettings(),
              trailing: Obx(() => Switch(
                value: controller.isDarkMode.value,
                onChanged: (value) => controller.toggleThemeMode(),
                activeColor: AppTheme.primaryColor,
              )),
            ),
            
            SizedBox(height: 16.h),
            
            // Language Settings
            _buildSettingsCard(
              context: context,
              title: 'Language',
              icon: Icons.language,
              description: 'Change application language',
              onTap: () =>{},
              //  controller.goToLanguageSettings(),
              trailing: Obx(() => Text(
                controller.selectedLanguage.value,
                style: TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 14.sp,
                ),
              )),
            ),
            
            SizedBox(height: 16.h),
            
            // Currency Settings
            _buildSettingsCard(
              context: context,
              title: 'Currency',
              icon: Icons.monetization_on_outlined,
              description: 'Set default currency for transactions',
              onTap: () => {},
              // controller.goToCurrencySettings(),
              trailing: Obx(() => Text(
                '${controller.selectedCurrency.value} (${controller.getCurrencySymbol()})',
                style: TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 14.sp,
                ),
              )),
            ),
            
            SizedBox(height: 16.h),
            
            // Backup & Restore Settings
            _buildSettingsCard(
              context: context,
              title: 'Backup & Restore',
              icon: Icons.backup,
              description: 'Backup your data or restore from previous backups',
              onTap: () => {},
              // controller.goToBackupSettings(),
            ),
            
            SizedBox(height: 32.h),
            
            // App Information
            _buildAppInfoSection(context),
            
            SizedBox(height: 32.h),
            
            // Danger Zone
            _buildDangerZone(context),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSettingsCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required String description,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Row(
            children: [
              Container(
                width: 50.r,
                height: 50.r,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.primaryColor,
                  size: 24.r,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildAppInfoSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        SizedBox(height: 16.h),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 60.r,
                      height: 60.r,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        Icons.local_pharmacy,
                        color: Colors.white,
                        size: 30.r,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pharmacy Inventory System',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimaryColor,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Version 1.0.0',
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
                SizedBox(height: 16.h),
                const Divider(),
                SizedBox(height: 16.h),
                _buildInfoRow(
                  icon: Icons.code,
                  title: 'Developed By',
                  value: 'Your Company Name',
                ),
                SizedBox(height: 12.h),
                _buildInfoRow(
                  icon: Icons.email_outlined,
                  title: 'Support Email',
                  value: 'support@example.com',
                ),
                SizedBox(height: 12.h),
                _buildInfoRow(
                  icon: Icons.web_outlined,
                  title: 'Website',
                  value: 'www.example.com',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20.r,
          color: AppTheme.primaryColor,
        ),
        SizedBox(width: 12.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimaryColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildDangerZone(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Danger Zone',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        SizedBox(height: 16.h),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
            side: BorderSide(
              color: Colors.red.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reset Shop Information',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'This will permanently delete all shop information. This action cannot be undone.',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      controller.confirmResetShopInfo();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Reset Shop Information'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}