// app/modules/settings/controllers/settings_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'dart:convert';

import 'package:pharma_sys/app/data/models/shop_model.dart';
import 'package:pharma_sys/app/modules/settings/view_models/settings_view_model.dart';
import 'package:pharma_sys/app/routes/app_routes.dart';

class SettingsController extends GetxController {
  final SettingsViewModel _viewModel;
  
  // Form controllers
  final shopNameController = TextEditingController();
  final addressController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final websiteController = TextEditingController();
  final ownerNameController = TextEditingController();
  final ownerPhoneController = TextEditingController();
  final ownerEmailController = TextEditingController();
  final taxIdController = TextEditingController();
  final licenseNumberController = TextEditingController();
  
  // Business hours controllers
  final Map<String, Map<String, TextEditingController>> businessHoursControllers = {
    'monday': {'open': TextEditingController(), 'close': TextEditingController()},
    'tuesday': {'open': TextEditingController(), 'close': TextEditingController()},
    'wednesday': {'open': TextEditingController(), 'close': TextEditingController()},
    'thursday': {'open': TextEditingController(), 'close': TextEditingController()},
    'friday': {'open': TextEditingController(), 'close': TextEditingController()},
    'saturday': {'open': TextEditingController(), 'close': TextEditingController()},
    'sunday': {'open': TextEditingController(), 'close': TextEditingController()},
  };
  
  // Logo image path
  final Rx<String?> logoPath = Rx<String?>(null);
  
  // Form key
  final formKey = GlobalKey<FormState>();
  
  // Getters for view model properties
  Rx<ShopModel?> get shopInfo => _viewModel.shopInfo;
  RxBool get isLoading => _viewModel.isLoading;
  RxBool get hasShopInfo => _viewModel.hasShopInfo;
  RxBool get isDarkMode => _viewModel.isDarkMode;
  RxString get selectedLanguage => _viewModel.selectedLanguage;
  RxList<String> get availableLanguages => _viewModel.availableLanguages;
  RxString get selectedCurrency => _viewModel.selectedCurrency;
  RxList<String> get availableCurrencies => _viewModel.availableCurrencies;
  RxMap<String, String> get currencySymbols => _viewModel.currencySymbols;
  
  SettingsController({required SettingsViewModel viewModel})
      : _viewModel = viewModel;
  
  @override
  void onInit() {
    super.onInit();
    fetchShopInfo();
  }
  
  @override
  void onClose() {
    // Dispose all text controllers
    shopNameController.dispose();
    addressController.dispose();
    phoneController.dispose();
    emailController.dispose();
    websiteController.dispose();
    ownerNameController.dispose();
    ownerPhoneController.dispose();
    ownerEmailController.dispose();
    taxIdController.dispose();
    licenseNumberController.dispose();
    
    // Dispose business hours controllers
    for (var day in businessHoursControllers.keys) {
      businessHoursControllers[day]!['open']!.dispose();
      businessHoursControllers[day]!['close']!.dispose();
    }
    
    super.onClose();
  }
  
  // Fetch shop info
  Future<void> fetchShopInfo() async {
    await _viewModel.fetchShopInfo();
    
    // Load shop info into form fields if available
    if (_viewModel.shopInfo.value != null) {
      _loadShopInfoToForm();
    }
  }
  
  // Load shop info to form
  void _loadShopInfoToForm() {
    final shop = _viewModel.shopInfo.value!;
    
    shopNameController.text = shop.name;
    addressController.text = shop.address;
    phoneController.text = shop.phone;
    emailController.text = shop.email ?? '';
    websiteController.text = shop.website ?? '';
    ownerNameController.text = shop.ownerName ?? '';
    ownerPhoneController.text = shop.ownerPhone ?? '';
    ownerEmailController.text = shop.ownerEmail ?? '';
    taxIdController.text = shop.taxId ?? '';
    licenseNumberController.text = shop.licenseNumber ?? '';
    logoPath.value = shop.logo;
    
    // Load business hours
    if (shop.businessHours != null) {
      Map<String, dynamic> businessHours;
      
      // Handle different data types - could be string or map
      if (shop.businessHours is String) {
        try {
          businessHours = json.decode(shop.businessHours as String);
        } catch (e) {
          businessHours = {};
        }
      } else {
        businessHours = shop.businessHours!;
      }
      
      for (var day in businessHoursControllers.keys) {
        if (businessHours.containsKey(day)) {
          var dayData = businessHours[day];
          if (dayData is Map) {
            businessHoursControllers[day]!['open']!.text = dayData['open'] ?? '';
            businessHoursControllers[day]!['close']!.text = dayData['close'] ?? '';
          }
        }
      }
    }
  }
  
  // Clear form fields
  void clearForm() {
    shopNameController.clear();
    addressController.clear();
    phoneController.clear();
    emailController.clear();
    websiteController.clear();
    ownerNameController.clear();
    ownerPhoneController.clear();
    ownerEmailController.clear();
    taxIdController.clear();
    licenseNumberController.clear();
    logoPath.value = null;
    
    // Clear business hours
    for (var day in businessHoursControllers.keys) {
      businessHoursControllers[day]!['open']!.clear();
      businessHoursControllers[day]!['close']!.clear();
    }
  }
  
  // Pick logo image
  Future<void> pickLogo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      // Save the image to app directory
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'shop_logo_${const Uuid().v4()}.jpg';
      final savedImage = File('${appDir.path}/$fileName');
      
      await File(pickedFile.path).copy(savedImage.path);
      logoPath.value = savedImage.path;
      
      // Update logo in shop info if available
      if (shopInfo.value != null) {
        await _viewModel.updateLogo(shopInfo.value!.id, savedImage.path);
      }
    }
  }
  
  // Collect business hours from controllers
  Map<String, dynamic> _collectBusinessHours() {
    final Map<String, dynamic> businessHours = {};
    
    for (var day in businessHoursControllers.keys) {
      businessHours[day] = {
        'open': businessHoursControllers[day]!['open']!.text,
        'close': businessHoursControllers[day]!['close']!.text,
      };
    }
    
    return businessHours;
  }
  
  // Save shop info
  Future<bool> saveShopInfo() async {
    if (!formKey.currentState!.validate()) {
      return false;
    }
    
    final now = DateTime.now();
    final businessHours = _collectBusinessHours();
    
    // Get current settings or create new ones
    Map<String, dynamic> settings = {};
    if (shopInfo.value != null && shopInfo.value!.settings != null) {
      if (shopInfo.value!.settings is String) {
        try {
          settings = json.decode(shopInfo.value!.settings as String);
        } catch (e) {
          settings = {};
        }
      } else {
        settings = Map<String, dynamic>.from(shopInfo.value!.settings!);
      }
    }
    
    // Update settings with current values
    settings['currency'] = selectedCurrency.value;
    settings['language'] = selectedLanguage.value;
    if (!settings.containsKey('taxRate')) {
      settings['taxRate'] = 5.0;
    }
    if (!settings.containsKey('timezone')) {
      settings['timezone'] = 'Asia/Dhaka';
    }
    
    final shop = ShopModel(
      id: shopInfo.value?.id ?? '',
      name: shopNameController.text.trim(),
      address: addressController.text.trim(),
      phone: phoneController.text.trim(),
      email: emailController.text.trim().isNotEmpty ? emailController.text.trim() : null,
      website: websiteController.text.trim().isNotEmpty ? websiteController.text.trim() : null,
      logo: logoPath.value,
      licenseNumber: licenseNumberController.text.trim().isNotEmpty ? licenseNumberController.text.trim() : null,
      taxId: taxIdController.text.trim().isNotEmpty ? taxIdController.text.trim() : null,
      ownerName: ownerNameController.text.trim().isNotEmpty ? ownerNameController.text.trim() : null,
      ownerPhone: ownerPhoneController.text.trim().isNotEmpty ? ownerPhoneController.text.trim() : null,
      ownerEmail: ownerEmailController.text.trim().isNotEmpty ? ownerEmailController.text.trim() : null,
      businessHours: businessHours,
      settings: settings,
      createdAt: shopInfo.value?.createdAt ?? now,
      updatedAt: now,
    );
    
    if (shopInfo.value == null) {
      return await _viewModel.saveShopInfo(shop);
    } else {
      return await _viewModel.updateShopInfo(shop);
    }
  }
  
  // Delegate methods to view model
  Future<bool> checkShopInfoExists() => _viewModel.checkShopInfoExists();
  Future<bool> resetShopInfo() => _viewModel.resetShopInfo();
  void toggleThemeMode() => _viewModel.toggleThemeMode();
  void setLanguage(String language) => _viewModel.setLanguage(language);
  void setCurrency(String currency) => _viewModel.setCurrency(currency);
  String getCurrencySymbol() => _viewModel.getCurrencySymbol();
  void saveSettings() => _viewModel.saveSettings();
  
  // Navigate to shop settings screen
  // void goToShopSettings() {
  //   Get.toNamed(Routes.SHOP_SETTINGS);
  // }
  
  // // Navigate to appearance settings screen
  // void goToAppearanceSettings() {
  //   Get.toNamed(Routes.APPEARANCE_SETTINGS);
  // }
  
  // // Navigate to language settings screen
  // void goToLanguageSettings() {
  //   Get.toNamed(Routes.LANGUAGE_SETTINGS);
  // }
  
  // // Navigate to currency settings screen
  // void goToCurrencySettings() {
  //   Get.toNamed(Routes.CURRENCY_SETTINGS);
  // }
  
  // // Navigate to backup settings screen
  // void goToBackupSettings() {
  //   Get.toNamed(Routes.BACKUP_SETTINGS);
  // }
  
  // // Navigate to business hours settings screen
  // void goToBusinessHoursSettings() {
  //   Get.toNamed(Routes.BUSINESS_HOURS_SETTINGS);
  // }
  
  // Validate form fields
  String? validateRequired(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }
  
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Email is optional
    }
    
    if (!GetUtils.isEmail(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }
  
  String? validateWebsite(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Website is optional
    }
    
    if (!GetUtils.isURL(value)) {
      return 'Please enter a valid website URL';
    }
    
    return null;
  }
  
  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    
    if (!GetUtils.isPhoneNumber(value)) {
      return 'Please enter a valid phone number';
    }
    
    return null;
  }
  
  String? validateTimeFormat(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Time can be empty (closed)
    }
    
    // Validate time format (HH:MM)
    final RegExp timeRegex = RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$');
    if (!timeRegex.hasMatch(value)) {
      return 'Use format: HH:MM';
    }
    
    return null;
  }
  
  // Confirm reset shop info
  Future<bool> confirmResetShopInfo() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Confirm Reset'),
        content: const Text('Are you sure you want to reset all shop information? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      final result = await resetShopInfo();
      if (result) {
        clearForm();
      }
      return result;
    }
    
    return false;
  }
}