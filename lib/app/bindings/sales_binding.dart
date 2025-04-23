// app/bindings/sales_binding.dart

import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:pharma_sys/app/data/repositories/sale_repository.dart';
import 'package:pharma_sys/app/data/repositories/medicine_repository.dart';
import 'package:pharma_sys/app/data/repositories/customer_repository.dart';
import 'package:pharma_sys/app/modules/sales/controllers/sales_controller.dart';
import 'package:pharma_sys/app/modules/sales/view_models/sales_view_model.dart';

class SalesBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize database if needed
    _initDatabase().then((database) {
      // Create repositories
      final saleRepository = SaleRepository(database: database);
      final medicineRepository = MedicineRepository(database: database);
      final customerRepository = CustomerRepository(database: database);
      
      // Create tables if needed
      saleRepository.createTables();
      
      // Create and inject view model
      final salesViewModel = SalesViewModel(
        saleRepository: saleRepository,
        medicineRepository: medicineRepository,
        customerRepository: customerRepository,
      );
      Get.put(salesViewModel);
      
      // Create and inject controller
      Get.put(SalesController(
        salesViewModel: salesViewModel,
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