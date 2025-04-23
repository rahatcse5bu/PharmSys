// app/bindings/employee_binding.dart

import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:pharmacy_inventory_app/app/data/repositories/employee_repository.dart';
import 'package:pharmacy_inventory_app/app/modules/employees/controllers/employee_controller.dart';
import 'package:pharmacy_inventory_app/app/modules/employees/view_models/employee_view_model.dart';

class EmployeeBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize database if needed
    _initDatabase().then((database) {
      // Create repository
      final employeeRepository = EmployeeRepository(database: database);
      
      // Create tables if needed
      employeeRepository.createTable();
      
      // Create and inject view model
      final employeeViewModel = EmployeeViewModel(
        employeeRepository: employeeRepository,
      );
      Get.put(employeeViewModel);
      
      // Create and inject controller
      Get.put(EmployeeController(
        viewModel: employeeViewModel,
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