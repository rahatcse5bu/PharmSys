// app/bindings/inventory_binding.dart

import 'package:get/get.dart';
import 'package:pharma_sys/app/data/repositories/medicine_repository.dart';
import 'package:pharma_sys/app/modules/inventory/view_models/inventory_view_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../modules/inventory/controller/inventory_controller.dart';

class InventoryBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize database if needed
    _initDatabase().then((database) {
      // Create medicine repository
      final medicineRepository = MedicineRepository(database: database);
      
      // Create tables if needed
      medicineRepository.createTable();
      
      // Create and inject view model
      final inventoryViewModel = InventoryViewModel(
        medicineRepository: medicineRepository,
      );
      Get.put(inventoryViewModel);
      
      // Create and inject controller
      Get.put(InventoryController(
        viewModel: inventoryViewModel,
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