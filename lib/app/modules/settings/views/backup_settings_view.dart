// app/modules/settings/views/backup_settings_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pharma_sys/app/utils/theme.dart';
import 'package:intl/intl.dart';

import '../../../utils/widgets/custom_app_bar.dart';
import '../controllers/settings_controller.dart';

class BackupSettingsView extends GetView<SettingsController> {
  const BackupSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Backup & Restore',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Backup Section
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
                    Row(
                      children: [
                        Icon(
                          Icons.backup,
                          color: AppTheme.primaryColor,
                          size: 24.r,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Create Backup',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimaryColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Create a backup of your pharmacy data. This will include all medicines, suppliers, customers, sales and settings.',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    // Backup options
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // Implement local backup
                              _showBackupInProgressDialog(context);
                            },
                            icon: const Icon(Icons.save),
                            label: const Text('Local Backup'),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // Implement cloud backup
                              _showBackupInProgressDialog(context);
                            },
                            icon: const Icon(Icons.cloud_upload),
                            label: const Text('Cloud Backup'),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    // Last backup info
                    Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppTheme.infoColor,
                            size: 20.r,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              'Last backup: ${DateFormat('MMM dd, yyyy - HH:mm').format(DateTime.now().subtract(const Duration(days: 2)))}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppTheme.textSecondaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 24.h),
            
            // Restore Section
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
                    Row(
                      children: [
                        Icon(
                          Icons.restore,
                          color: AppTheme.warningColor,
                          size: 24.r,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Restore Data',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimaryColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Restore your pharmacy data from a previous backup. Current data will be replaced.',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    // Restore options
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // Implement local restore
                              _showRestoreConfirmationDialog(context);
                            },
                            icon: const Icon(Icons.folder_open),
                            label: const Text('From Local'),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // Implement cloud restore
                              _showRestoreConfirmationDialog(context);
                            },
                            icon: const Icon(Icons.cloud_download),
                            label: const Text('From Cloud'),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: AppTheme.warningColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: AppTheme.warningColor.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: AppTheme.warningColor,
                            size: 20.r,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              'Warning: Restoring data will replace all current information. This action cannot be undone.',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppTheme.warningColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 24.h),
            
            // Auto Backup Settings
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
                    Row(
                      children: [
                        Icon(
                          Icons.settings_backup_restore,
                          color: AppTheme.primaryColor,
                          size: 24.r,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Auto Backup Settings',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimaryColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    SwitchListTile(
                      title: Text(
                        'Enable Auto Backup',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                      subtitle: Text(
                        'Automatically backup your data periodically',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                      value: true, // Connect to actual state
                      onChanged: (value) {
                        // Implement auto backup toggle
                      },
                      activeColor: AppTheme.primaryColor,
                    ),
                    const Divider(),
                    ListTile(
                      title: Text(
                        'Backup Frequency',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                      subtitle: Text(
                        'Daily',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                      trailing: const Icon(Icons.keyboard_arrow_right),
                      onTap: () {
                        // Implement frequency picker
                        _showBackupFrequencyDialog(context);
                      },
                    ),
                    const Divider(),
                    ListTile(
                      title: Text(
                        'Storage Location',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                      subtitle: Text(
                        'Local & Cloud',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                      trailing: const Icon(Icons.keyboard_arrow_right),
                      onTap: () {
                        // Implement storage location picker
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 32.h),
            
            Center(
              child: Text(
                'Note: This is a preview feature. Full backup functionality will be available in a future update.',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontStyle: FontStyle.italic,
                  color: AppTheme.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
  
  void _showBackupInProgressDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            SizedBox(height: 16.h),
            Text(
              'Creating Backup...',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Please do not close the application.',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
    
    // Simulate backup process
    Future.delayed(const Duration(seconds: 3), () {
      Get.back(); // Close dialog
      Get.snackbar(
        'Success',
        'Backup created successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    });
  }
  
  void _showRestoreConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Data'),
        content: Text(
          'Are you sure you want to restore data? This will replace all current information and cannot be undone.',
          style: TextStyle(
            fontSize: 14.sp,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _showRestoreInProgressDialog(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.warningColor,
            ),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
  }
  
  void _showRestoreInProgressDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            SizedBox(height: 16.h),
            Text(
              'Restoring Data...',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Please do not close the application.',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
    
    // Simulate restore process
    Future.delayed(const Duration(seconds: 3), () {
      Get.back(); // Close dialog
      Get.snackbar(
        'Success',
        'Data restored successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    });
  }
  
  void _showBackupFrequencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Backup Frequency'),
        children: [
          _buildFrequencyOption('Daily', isSelected: true),
          _buildFrequencyOption('Weekly'),
          _buildFrequencyOption('Monthly'),
          _buildFrequencyOption('Never'),
        ],
      ),
    );
  }
  
  Widget _buildFrequencyOption(String frequency, {bool isSelected = false}) {
    return SimpleDialogOption(
      onPressed: () {
        Get.back();
        // Implement frequency setting
      },
      child: Row(
        children: [
          Text(
            frequency,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimaryColor,
            ),
          ),
          const Spacer(),
          if (isSelected)
            Icon(
              Icons.check,
              color: AppTheme.primaryColor,
              size: 20.r,
            ),
        ],
      ),
    );
  }
}