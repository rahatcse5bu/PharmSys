// app/utils/constants.dart

class AppConstants {
  // App information
  static const String appName = 'PharmSys';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Pharmacy Inventory Management System';

  // API endpoints - if used in future
  static const String baseUrl = 'https://api.pharmflow.com';
  
  // Storage keys
  static const String storageUserKey = 'user';
  static const String storageTokenKey = 'token';
  static const String storageShopKey = 'shop';
  
  // Subscription
  static const double monthlySubscriptionPrice = 500.0;
  static const int trialPeriodDays = 7;
  static const String defaultCurrency = 'BDT';
  
  // Medicine types
  static const List<String> medicineTypes = [
    'tablet',
    'capsule',
    'syrup',
    'injection',
    'cream',
    'ointment',
    'lotion',
    'suspension',
    'drops',
    'powder',
    'inhaler',
    'spray',
    'suppository',
    'patch',
    'gel',
    'solution',
  ];
  
  // Employee roles
  static const List<String> employeeRoles = [
    'manager',
    'pharmacist',
    'salesperson',
    'cashier',
    'inventory_manager',
    'delivery_person',
  ];
  
  // Payment methods
  static const List<String> paymentMethods = [
    'cash',
    'card',
    'mobile_banking',
    'credit',
  ];
  
  // Payment statuses
  static const List<String> paymentStatuses = [
    'paid',
    'partial',
    'due',
  ];
  
  // User roles
  static const List<String> userRoles = [
    'admin',
    'manager',
    'staff',
  ];
  
  // Date formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  
  // Default alert threshold
  static const int defaultAlertThreshold = 10;
  
  // Default tax rate
  static const double defaultTaxRate = 5.0;
}