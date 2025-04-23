// app/modules/settings/views/language_settings_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pharma_sys/app/utils/theme.dart';

import '../../../utils/widgets/custom_app_bar.dart';
import '../controllers/settings_controller.dart';

class LanguageSettingsView extends GetView<SettingsController> {
  const LanguageSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Language Settings',
        showBackButton: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Text(
              'Select your preferred language:',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimaryColor,
              ),
            ),
          ),
          
          // Language List
          Expanded(
            child: Obx(() => ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.r),
              itemCount: controller.availableLanguages.length,
              itemBuilder: (context, index) {
                final language = controller.availableLanguages[index];
                final isSelected = language == controller.selectedLanguage.value;
                
                return Card(
                  elevation: isSelected ? 2 : 0,
                  margin: EdgeInsets.only(bottom: 8.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    side: BorderSide(
                      color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: InkWell(
                    onTap: () => controller.setLanguage(language),
                    borderRadius: BorderRadius.circular(8.r),
                    child: Padding(
                      padding: EdgeInsets.all(16.r),
                      child: Row(
                        children: [
                          _buildLanguageFlag(language),
                          SizedBox(width: 16.w),
                          Text(
                            language,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: AppTheme.textPrimaryColor,
                            ),
                          ),
                          const Spacer(),
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              color: AppTheme.primaryColor,
                              size: 24.r,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            )),
          ),
          
          // Save Button
          Padding(
            padding: EdgeInsets.all(16.r),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  controller.saveSettings();
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                ),
                child: const Text('Save Language Setting'),
              ),
            ),
          ),
          
          // Note
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 8.r),
            child: Text(
              'Note: After changing the language, some screens may need to be reloaded to apply the changes completely.',
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
    );
  }
  
  Widget _buildLanguageFlag(String language) {
    String flagEmoji;
    
    // Map language names to flag emojis
    switch (language) {
      case 'English':
        flagEmoji = '🇺🇸';
        break;
      case 'Spanish':
        flagEmoji = '🇪🇸';
        break;
      case 'French':
        flagEmoji = '🇫🇷';
        break;
      case 'Arabic':
        flagEmoji = '🇸🇦';
        break;
      default:
        flagEmoji = '🌐';
    }
    
    return Text(
      flagEmoji,
      style: TextStyle(
        fontSize: 24.sp,
      ),
    );
  }
}