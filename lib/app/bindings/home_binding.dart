// app/bindings/home_binding.dart

import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:pharmacy_inventory_app/app/data/repositories/medicine_repository.dart';
import 'package:pharmacy_inventory_app/app/data/repositories/sale_repository.dart';
import 'package:pharmacy_inventory_app/app/data/repositories/employee_repository.dart';
import 'package:pharmacy_inventory_app/app/data/repositories/shop_repository.dart';
import 'package:pharmacy_inventory_app/app/modules/home/controllers/home_controller.dart';
import 'package:pharmacy_inventory_app/app/modules/home/view_models/home_view_model.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize database if needed
    _initDatabase().then((database) {
      // Create repositories
      final medicineRepository = MedicineRepository(database: database);
      final saleRepository = SaleRepository(database: database);
      final employeeRepository = EmployeeRepository(database: database);
      final shopRepository = ShopRepository(database: database);
      
      // Create view model
      final homeViewModel = HomeViewModel(
        medicineRepository: medicineRepository,
        saleRepository: saleRepository,
        employeeRepository: employeeRepository,
        shopRepository: shopRepository,
      );
      Get.put(homeViewModel);
      
      // Create controller
      Get.put(HomeController(
        medicineRepository: medicineRepository,
        saleRepository: saleRepository,
        employeeRepository: employeeRepository,
        shopRepository: shopRepository,
      ));
    });
  }

  Future<Database> _initDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), 'pharmacy_inventory.db'),
      onCreate: (db, version) async {
        // Create tables on database creation if needed
      },
      version: 1,
    );
  }
}