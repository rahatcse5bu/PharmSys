// app/modules/settings/view_models/settings_view_model.dart

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pharma_sys/app/data/models/shop_model.dart';
import 'package:pharma_sys/app/data/repositories/shop_repository.dart';
import 'dart:convert';

class SettingsViewModel extends GetxController {
  final ShopRepository _shopRepository;
  
  // Observable variables
  final Rx<ShopModel?> shopInfo = Rx<ShopModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool hasShopInfo = false.obs;
  
  // Theme settings
  final RxBool isDarkMode = false.obs;
  
  // App settings
  final RxString selectedLanguage = 'English'.obs;
  final RxList<String> availableLanguages = <String>['English', 'Bengali', 'Hindi', 'Arabic'].obs;
  
  // Currency settings
  final RxString selectedCurrency = 'BDT'.obs;
  final RxList<String> availableCurrencies = <String>['BDT', 'USD', 'EUR', 'GBP', 'JPY', 'INR'].obs;
  final RxMap<String, String> currencySymbols = <String, String>{
    'BDT': '৳',
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'JPY': '¥',
    'INR': '₹',
  }.obs;
  
  SettingsViewModel({required ShopRepository shopRepository}) 
      : _shopRepository = shopRepository;
  
  @override
  void onInit() {
    super.onInit();
    fetchShopInfo();
    loadSettings();
  }
  
  // Fetch shop information from repository
  Future<void> fetchShopInfo() async {
    try {
      isLoading.value = true;
      final shop = await _shopRepository.getShopInfo();
      shopInfo.value = shop;
      hasShopInfo.value = shop != null;
      
      if (shop != null && shop.settings != null) {
        Map<String, dynamic> settings;
        
        // Handle potential string format of settings (from SQLite)
        if (shop.settings is String) {
          try {
            settings = json.decode(shop.settings as String);
          } catch (e) {
            settings = {};
          }
        } else {
          settings = shop.settings!;
        }
        
        // Update app settings from shop settings
        if (settings.containsKey('currency')) {
          selectedCurrency.value = settings['currency'] as String;
        }
        
        if (settings.containsKey('language')) {
          selectedLanguage.value = settings['language'] as String;
        }
      }
      
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to load shop information: ${e.toString()}');
    }
  }
  
  // Save shop information
  Future<bool> saveShopInfo(ShopModel shop) async {
    try {
      isLoading.value = true;
      await _shopRepository.saveShopInfo(shop);
      shopInfo.value = shop;
      hasShopInfo.value = true;
      isLoading.value = false;
      Get.snackbar('Success', 'Shop information saved successfully');
      return true;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to save shop information: ${e.toString()}');
      return false;
    }
  }
  
  // Update shop information
  Future<bool> updateShopInfo(ShopModel shop) async {
    try {
      isLoading.value = true;
      await _shopRepository.updateShopInfo(shop);
      shopInfo.value = shop;
      isLoading.value = false;
      Get.snackbar('Success', 'Shop information updated successfully');
      return true;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to update shop information: ${e.toString()}');
      return false;
    }
  }
  
  // Update logo
  Future<bool> updateLogo(String id, String logoPath) async {
    try {
      isLoading.value = true;
      await _shopRepository.updateLogo(id, logoPath);
      
      // Update local shop info object
      if (shopInfo.value != null) {
        shopInfo.value = shopInfo.value!.copyWith(logo: logoPath);
      }
      
      isLoading.value = false;
      Get.snackbar('Success', 'Logo updated successfully');
      return true;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to update logo: ${e.toString()}');
      return false;
    }
  }
  
  // Check if shop information exists
  Future<bool> checkShopInfoExists() async {
    try {
      final shop = await _shopRepository.getShopInfo();
      return shop != null;
    } catch (e) {
      Get.snackbar('Error', 'Failed to check shop information: ${e.toString()}');
      return false;
    }
  }
  
  // Reset shop information (this would actually create a default shop in your implementation)
  Future<bool> resetShopInfo() async {
    try {
      isLoading.value = true;
      await _shopRepository.createDefaultShop();
      await fetchShopInfo(); // Refresh the shop info
      isLoading.value = false;
      Get.snackbar('Success', 'Shop information has been reset to defaults');
      return true;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to reset shop information: ${e.toString()}');
      return false;
    }
  }
  
  // Toggle theme mode
  void toggleThemeMode() {
    isDarkMode.value = !isDarkMode.value;
    saveSettings();
  }
  
  // Set language
  void setLanguage(String language) {
    if (availableLanguages.contains(language)) {
      selectedLanguage.value = language;
      saveSettings();
      
      // Update shop settings if shop info exists
      if (shopInfo.value != null) {
        _updateShopSettingsField('language', language);
      }
    }
  }
  
  // Set currency
  void setCurrency(String currency) {
    if (availableCurrencies.contains(currency)) {
      selectedCurrency.value = currency;
      saveSettings();
      
      // Update shop settings if shop info exists
      if (shopInfo.value != null) {
        _updateShopSettingsField('currency', currency);
      }
    }
  }
  
  // Update a field in the shop settings
  Future<void> _updateShopSettingsField(String field, dynamic value) async {
    try {
      if (shopInfo.value == null) return;
      
      Map<String, dynamic> settings = {};
      
      // Get current settings or create new ones
      if (shopInfo.value!.settings != null) {
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
      
      // Update the specific field
      settings[field] = value;
      
      // Update settings in database
      await _shopRepository.updateShopSettings(shopInfo.value!.id, settings);
      
      // Update local shop info
      final updatedShop = shopInfo.value!.copyWith(settings: settings);
      shopInfo.value = updatedShop;
      
    } catch (e) {
      Get.snackbar('Error', 'Failed to update shop settings: ${e.toString()}');
    }
  }
  
  // Get currency symbol
  String getCurrencySymbol() {
    return currencySymbols[selectedCurrency.value] ?? '৳';
  }
  
  // Load settings from local storage
  void loadSettings() {
    final box = GetStorage();
    isDarkMode.value = box.read('isDarkMode') ?? false;
    
    // These will be overridden by shop settings if available
    selectedLanguage.value = box.read('language') ?? 'English';
    selectedCurrency.value = box.read('currency') ?? 'BDT';
  }
  
  // Save settings to local storage
  void saveSettings() {
    final box = GetStorage();
    box.write('isDarkMode', isDarkMode.value);
    box.write('language', selectedLanguage.value);
    box.write('currency', selectedCurrency.value);
  }
  
  // Get tax rate
  Future<double> getTaxRate() async {
    return await _shopRepository.getTaxRate();
  }
  
  // Get currency
  Future<String> getCurrencyFromRepo() async {
    return await _shopRepository.getCurrency();
  }
}