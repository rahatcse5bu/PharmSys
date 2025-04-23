// app/bindings/sales_binding.dart

import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:pharmacy_inventory_app/app/data/repositories/sale_repository.dart';
import 'package:pharmacy_inventory_app/app/data/repositories/medicine_repository.dart';
import 'package:pharmacy_inventory_app/app/modules/sales/controllers/sales_controller.dart';
import 'package:pharmacy_inventory_app/app/modules/sales/view_models/sales_view_model.dart';

class SalesBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize database if needed
    _initDatabase().then((database) {
      // Create repositories
      final saleRepository = SaleRepository(database: database);
      final medicineRepository = MedicineRepository(database: database);
      
      // Create tables if needed
      saleRepository.createTables();
      
      // Create and inject view model
      final salesViewModel = SalesViewModel(
        saleRepository: saleRepository,
        medicineRepository: medicineRepository,
      );
      Get.put(salesViewModel);
      
      // Create and inject controller
      Get.put(SalesController(
        viewModel: salesViewModel,
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