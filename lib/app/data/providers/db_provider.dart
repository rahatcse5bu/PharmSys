// app/data/providers/db_provider.dart

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:pharmacy_inventory_app/app/data/repositories/employee_repository.dart';
import 'package:pharmacy_inventory_app/app/data/repositories/medicine_repository.dart';
import 'package:pharmacy_inventory_app/app/data/repositories/sale_repository.dart';
import 'package:pharmacy_inventory_app/app/data/repositories/shop_repository.dart';
import 'package:pharmacy_inventory_app/app/data/repositories/subscription_repository.dart';
import 'package:pharmacy_inventory_app/app/data/repositories/supplier_repository.dart';

class DbProvider {
  static final DbProvider _instance = DbProvider._internal();
  static Database? _database;
  
  // Private constructor
  DbProvider._internal();
  
  // Singleton pattern
  factory DbProvider() => _instance;
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    
    _database = await _initDatabase();
    return _database!;
  }
  
  Future<Database> _initDatabase() async {
    // Get a location for the database
    String path = join(await getDatabasesPath(), 'PharmFlow.db');
    
    // Open/create the database
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }
  
  Future<void> _createDatabase(Database db, int version) async {
    // Create all required tables
    final employeeRepo = EmployeeRepository(database: db);
    await employeeRepo.createTable();
    
    final medicineRepo = MedicineRepository(database: db);
    await medicineRepo.createTable();
    
    final saleRepo = SaleRepository(database: db);
    await saleRepo.createTables();
    
    final shopRepo = ShopRepository(database: db);
    await shopRepo.createTable();
    
    final subscriptionRepo = SubscriptionRepository(database: db);
    await subscriptionRepo.createTable();
    
    final supplierRepo = SupplierRepository(database: db);
    await supplierRepo.createTable();
    
    // Add default data
    await _addDefaultData(db);
  }
  
  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    // Handle database schema upgrades
    if (oldVersion < 2) {
      // Add upgrade code for version 2
    }
  }
  
  Future<void> _addDefaultData(Database db) async {
    // Add default shop info
    final shopRepo = ShopRepository(database: db);
    await shopRepo.createDefaultShop();
    
    // Add other default data as needed
  }
  
  // Close the database
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
  
  // Reset the database (for testing or user data reset)
  Future<void> resetDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
    
    String path = join(await getDatabasesPath(), 'PharmFlow.db');
    await deleteDatabase(path);
    
    _database = await _initDatabase();
  }
}