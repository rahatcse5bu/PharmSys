// app/bindings/subscription_binding.dart

import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:pharmacy_inventory_app/app/data/repositories/subscription_repository.dart';
import 'package:pharmacy_inventory_app/app/modules/subscription/controllers/subscription_controller.dart';
import 'package:pharmacy_inventory_app/app/modules/subscription/view_models/subscription_view_model.dart';

class SubscriptionBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize database if needed
    _initDatabase().then((database) {
      // Create subscription repository
      final subscriptionRepository = SubscriptionRepository(database: database);
      
      // Create tables if needed
      subscriptionRepository.createTable();
      
      // Create and inject view model
      final subscriptionViewModel = SubscriptionViewModel(
        subscriptionRepository: subscriptionRepository,
      );
      Get.put(subscriptionViewModel);
      
      // Create and inject controller
      Get.put(SubscriptionController(
        viewModel: subscriptionViewModel,
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