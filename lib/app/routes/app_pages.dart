// app/routes/app_pages.dart

import 'package:get/get.dart';
import 'package:pharma_sys/app/bindings/auth_binding.dart';
import 'package:pharma_sys/app/bindings/employee_binding.dart';
import 'package:pharma_sys/app/bindings/home_binding.dart';
import 'package:pharma_sys/app/bindings/inventory_binding.dart';
import 'package:pharma_sys/app/bindings/sales_binding.dart';
import 'package:pharma_sys/app/bindings/settings_binding.dart';
import 'package:pharma_sys/app/bindings/subscription_binding.dart';
import 'package:pharma_sys/app/modules/auth/views/login_view.dart';
// import 'package:pharma_sys/app/modules/auth/views/signup_view.dart';
// import 'package:pharma_sys/app/modules/employees/views/add_employee_view.dart';
// import 'package:pharma_sys/app/modules/employees/views/employee_details_view.dart';
// import 'package:pharma_sys/app/modules/employees/views/employees_view.dart';
import 'package:pharma_sys/app/modules/home/views/home_view.dart';
import 'package:pharma_sys/app/modules/inventory/views/add_medicine_view.dart';
import 'package:pharma_sys/app/modules/inventory/views/inventory_view.dart';
import 'package:pharma_sys/app/modules/inventory/views/low_stock_alert_view.dart';
import 'package:pharma_sys/app/modules/inventory/views/medicine_details_view.dart';
// import 'package:pharma_sys/app/modules/sales/views/new_sale_view.dart';
// import 'package:pharma_sys/app/modules/sales/views/sales_report_view.dart';
// import 'package:pharma_sys/app/modules/sales/views/sales_view.dart';
// import 'package:pharma_sys/app/modules/settings/views/settings_view.dart';
// import 'package:pharma_sys/app/modules/settings/views/shop_details_view.dart';
import 'package:pharma_sys/app/modules/subscription/views/subscription_view.dart';
import 'package:pharma_sys/app/modules/subscription/views/payment_view.dart';
// import 'package:pharma_sys/app/modules/suppliers/views/add_supplier_view.dart';
// import 'package:pharma_sys/app/modules/suppliers/views/supplier_details_view.dart';
// import 'package:pharma_sys/app/modules/suppliers/views/suppliers_view.dart';
import 'package:pharma_sys/app/routes/app_routes.dart';
// import 'package:pharma_sys/app/modules/suppliers/views/suppliers_view.dart';
import 'package:pharma_sys/app/routes/app_routes.dart';

import '../modules/auth/view/sign_up_view.dart';
import '../modules/employee/views/add_employee_view.dart';
import '../modules/employee/views/employee_details_view.dart';
import '../modules/employee/views/employees_view.dart';

class AppPages {
  static const INITIAL = Routes.LOGIN;

  static final routes = [
    // Auth Routes
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginView(),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.SIGNUP,
      page: () => const SignupView(),
      binding: AuthBinding(),
    ),
    
    // Home Route
    GetPage(
      name: Routes.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    
    // Employee Routes
    GetPage(
      name: Routes.EMPLOYEES,
      page: () => const EmployeesView(),
      binding: EmployeeBinding(),
    ),
    GetPage(
      name: Routes.EMPLOYEE_DETAILS,
      page: () => const EmployeeDetailsView(),
      binding: EmployeeBinding(),
    ),
    GetPage(
      name: Routes.ADD_EMPLOYEE,
      page: () => const AddEmployeeView(),
      binding: EmployeeBinding(),
    ),
    
    // Inventory Routes
    GetPage(
      name: Routes.INVENTORY,
      page: () => const InventoryView(),
      binding: InventoryBinding(),
    ),
    GetPage(
      name: Routes.ADD_MEDICINE,
      page: () => const AddMedicineView(),
      binding: InventoryBinding(),
    ),
    GetPage(
      name: Routes.MEDICINE_DETAILS,
      page: () => const MedicineDetailsView(),
      binding: InventoryBinding(),
    ),
    GetPage(
      name: Routes.LOW_STOCK_ALERT,
      page: () => const LowStockAlertView(),
      binding: InventoryBinding(),
    ),
    
    // Sales Routes
    // GetPage(
    //   name: Routes.SALES,
    //   page: () => const SalesView(),
    //   binding: SalesBinding(),
    // ),
    // GetPage(
    //   name: Routes.NEW_SALE,
    //   page: () => const NewSaleView(),
    //   binding: SalesBinding(),
    // ),
    // GetPage(
    //   name: Routes.SALES_REPORT,
    //   page: () => const SalesReportView(),
    //   binding: SalesBinding(),
    // ),
    
    // Supplier Routes
    // GetPage(
    //   name: Routes.SUPPLIERS,
    //   page: () => const SuppliersView(),
    //   binding: EmployeeBinding(),
    // ),
    // GetPage(
    //   name: Routes.SUPPLIER_DETAILS,
    //   page: () => const SupplierDetailsView(),
    //   binding: EmployeeBinding(),
    // ),
    // GetPage(
    //   name: Routes.ADD_SUPPLIER,
    //   page: () => const AddSupplierView(),
    //   binding: EmployeeBinding(),
    // ),
    
    // Settings Routes
    // GetPage(
    //   name: Routes.SETTINGS,
    //   page: () => const SettingsView(),
    //   binding: SettingsBinding(),
    // ),
    // GetPage(
    //   name: Routes.SHOP_DETAILS,
    //   page: () => const ShopDetailsView(),
    //   binding: SettingsBinding(),
    // ),
    
    // Subscription Routes
    GetPage(
      name: Routes.SUBSCRIPTION,
      page: () => const SubscriptionView(),
      binding: SubscriptionBinding(),
    ),
    GetPage(
      name: Routes.PAYMENT,
      page: () => const PaymentView(),
      binding: SubscriptionBinding(),
    ),
  ];
}