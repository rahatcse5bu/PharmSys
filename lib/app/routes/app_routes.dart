// app/routes/app_routes.dart

abstract class Routes {
  // Auth routes
  static const SPLASH = '/splash';
  static const LOGIN = '/login';
  static const SIGNUP = '/signup';
  
  // Main routes
  static const HOME = '/home';
  
  // Employee routes
  static const EMPLOYEES = '/employees';
  static const EMPLOYEE_DETAILS = '/employee-details';
  static const ADD_EMPLOYEE = '/add-employee';
  
  // Inventory routes
  static const INVENTORY = '/inventory';
  static const ADD_MEDICINE = '/add-medicine';
  static const MEDICINE_DETAILS = '/medicine-details';
  static const LOW_STOCK_ALERT = '/low-stock-alert';
  
  // Sales routes
  static const SALES = '/sales';
  static const NEW_SALE = '/new-sale';
  static const SALES_REPORT = '/sales-report';
  
  // Supplier routes
  static const SUPPLIERS = '/suppliers';
  static const SUPPLIER_DETAILS = '/supplier-details';
  static const ADD_SUPPLIER = '/add-supplier';
  
  // Settings routes
  static const SETTINGS = '/settings';
  static const SHOP_DETAILS = '/shop-details';
  
  // Subscription routes
  static const SUBSCRIPTION = '/subscription';
  static const PAYMENT = '/payment';
}