// app/bindings/settings_binding.dart

import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:pharmacy_inventory_app/app/data/repositories/shop_repository.dart';
import 'package:pharmacy_inventory_app/app/modules/settings/controllers/settings_controller.dart';
import 'package:pharmacy_inventory_app/app/modules/settings/view_models/settings_view_model.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize database if needed
    _initDatabase().then((database) {
      // Create repository
      final shopRepository = ShopRepository(database: database);
      
      // Create tables if needed
      shopRepository.createTable();
      
      // Create and inject view model
      final settingsViewModel = SettingsViewModel(
        shopRepository: shopRepository,
      );
      Get.put(settingsViewModel);
      
      // Create and inject controller
      Get.put(SettingsController(
        viewModel: settingsViewModel,
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