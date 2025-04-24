// app/bindings/home_binding.dart

import 'package:get/get.dart';
import '../modules/home/controllers/home_controller.dart';
import '../modules/home/view_models/home_view_model.dart';
import '../data/repositories/medicine_repository.dart';
import '../data/repositories/sale_repository.dart';
import '../data/repositories/employee_repository.dart';
import '../data/repositories/shop_repository.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize repositories
    Get.lazyPut<MedicineRepository>(() => MedicineRepository(database: Get.find()));
    Get.lazyPut<SaleRepository>(() => SaleRepository(database: Get.find()));
    Get.lazyPut<EmployeeRepository>(() => EmployeeRepository(database: Get.find()));
    Get.lazyPut<ShopRepository>(() => ShopRepository(database: Get.find()));

    // Initialize view model
    Get.lazyPut<HomeViewModel>(() => HomeViewModel(
      medicineRepository: Get.find<MedicineRepository>(),
      saleRepository: Get.find<SaleRepository>(),
      employeeRepository: Get.find<EmployeeRepository>(),
      shopRepository: Get.find<ShopRepository>()
    ));
    
    // Initialize controller with view model and repositories
    Get.lazyPut<HomeController>(
      () => HomeController(
    
        medicineRepository: Get.find<MedicineRepository>(),
        saleRepository: Get.find<SaleRepository>(),
        employeeRepository: Get.find<EmployeeRepository>(),
        shopRepository: Get.find<ShopRepository>()
      )
    );
  }
}