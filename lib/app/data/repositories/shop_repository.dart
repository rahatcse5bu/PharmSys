// app/data/repositories/shop_repository.dart

import 'package:pharmacy_inventory_app/app/data/models/shop_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class ShopRepository {
  final Database database;
  final String tableName = 'shop';
  final Uuid uuid = Uuid();
  
  ShopRepository({required this.database});

  Future<void> createTable() async {
    await database.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        address TEXT NOT NULL,
        phone TEXT NOT NULL,
        email TEXT,
        website TEXT,
        logo TEXT,
        licenseNumber TEXT,
        taxId TEXT,
        ownerName TEXT,
        ownerPhone TEXT,
        ownerEmail TEXT,
        businessHours TEXT,
        settings TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
  }

  Future<ShopModel?> getShopInfo() async {
    final List<Map<String, dynamic>> maps = await database.query(tableName);
    
    if (maps.isNotEmpty) {
      return ShopModel(
        id: maps[0]['id'],
        name: maps[0]['name'],
        address: maps[0]['address'],
        phone: maps[0]['phone'],
        email: maps[0]['email'],
        website: maps[0]['website'],
        logo: maps[0]['logo'],
        licenseNumber: maps[0]['licenseNumber'],
        taxId: maps[0]['taxId'],
        ownerName: maps[0]['ownerName'],
        ownerPhone: maps[0]['ownerPhone'],
        ownerEmail: maps[0]['ownerEmail'],
        businessHours: maps[0]['businessHours'] != null 
            ? Map<String, dynamic>.from(maps[0]['businessHours']) 
            : null,
        settings: maps[0]['settings'] != null 
            ? Map<String, dynamic>.from(maps[0]['settings']) 
            : null,
        createdAt: DateTime.parse(maps[0]['createdAt']),
        updatedAt: DateTime.parse(maps[0]['updatedAt']),
      );
    }
    
    // Return default shop information if none exists
    return createDefaultShop();
  }

  Future<ShopModel> createDefaultShop() async {
    final now = DateTime.now();
    final String id = uuid.v4();
    
    final defaultShop = ShopModel(
      id: id,
      name: 'PharmFlow Pharmacy',
      address: '123 Main Street, Dhaka',
      phone: '+880 1700 000000',
      email: 'contact@pharmflow.com',
      website: 'www.pharmflow.com',
      logo: null,
      licenseNumber: 'LIC-12345',
      taxId: 'TAX-67890',
      ownerName: 'Admin User',
      ownerPhone: '+880 1700 000000',
      ownerEmail: 'admin@pharmflow.com',
      businessHours: {
        'monday': {'open': '09:00', 'close': '20:00'},
        'tuesday': {'open': '09:00', 'close': '20:00'},
        'wednesday': {'open': '09:00', 'close': '20:00'},
        'thursday': {'open': '09:00', 'close': '20:00'},
        'friday': {'open': '09:00', 'close': '20:00'},
        'saturday': {'open': '10:00', 'close': '18:00'},
        'sunday': {'open': '10:00', 'close': '16:00'},
      },
      settings: {
        'currency': 'BDT',
        'taxRate': 5.0,
        'language': 'en',
        'timezone': 'Asia/Dhaka',
      },
      createdAt: now,
      updatedAt: now,
    );

    await saveShopInfo(defaultShop);
    return defaultShop;
  }

  Future<void> saveShopInfo(ShopModel shop) async {
    final now = DateTime.now();
    final updatedShop = shop.copyWith(updatedAt: now);
    
    await database.insert(
      tableName,
      {
        'id': updatedShop.id,
        'name': updatedShop.name,
        'address': updatedShop.address,
        'phone': updatedShop.phone,
        'email': updatedShop.email,
        'website': updatedShop.website,
        'logo': updatedShop.logo,
        'licenseNumber': updatedShop.licenseNumber,
        'taxId': updatedShop.taxId,
        'ownerName': updatedShop.ownerName,
        'ownerPhone': updatedShop.ownerPhone,
        'ownerEmail': updatedShop.ownerEmail,
        'businessHours': updatedShop.businessHours != null 
            ? updatedShop.businessHours.toString() 
            : null,
        'settings': updatedShop.settings != null 
            ? updatedShop.settings.toString() 
            : null,
        'createdAt': updatedShop.createdAt.toIso8601String(),
        'updatedAt': updatedShop.updatedAt.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateShopInfo(ShopModel shop) async {
    final now = DateTime.now();
    final updatedShop = shop.copyWith(updatedAt: now);
    
    await database.update(
      tableName,
      {
        'name': updatedShop.name,
        'address': updatedShop.address,
        'phone': updatedShop.phone,
        'email': updatedShop.email,
        'website': updatedShop.website,
        'logo': updatedShop.logo,
        'licenseNumber': updatedShop.licenseNumber,
        'taxId': updatedShop.taxId,
        'ownerName': updatedShop.ownerName,
        'ownerPhone': updatedShop.ownerPhone,
        'ownerEmail': updatedShop.ownerEmail,
        'businessHours': updatedShop.businessHours != null 
            ? updatedShop.businessHours.toString() 
            : null,
        'settings': updatedShop.settings != null 
            ? updatedShop.settings.toString() 
            : null,
        'updatedAt': updatedShop.updatedAt.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [updatedShop.id],
    );
  }

  Future<void> updateLogo(String id, String logoPath) async {
    final now = DateTime.now();
    
    await database.update(
      tableName,
      {
        'logo': logoPath,
        'updatedAt': now.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateShopSettings(String id, Map<String, dynamic> settings) async {
    final now = DateTime.now();
    
    await database.update(
      tableName,
      {
        'settings': settings.toString(),
        'updatedAt': now.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateBusinessHours(String id, Map<String, dynamic> businessHours) async {
    final now = DateTime.now();
    
    await database.update(
      tableName,
      {
        'businessHours': businessHours.toString(),
        'updatedAt': now.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<String> getCurrency() async {
    final shop = await getShopInfo();
    if (shop != null && shop.settings != null && shop.settings!.containsKey('currency')) {
      return shop.settings!['currency'] as String;
    }
    return 'BDT'; // Default currency
  }

  Future<double> getTaxRate() async {
    final shop = await getShopInfo();
    if (shop != null && shop.settings != null && shop.settings!.containsKey('taxRate')) {
      return double.parse(shop.settings!['taxRate'].toString());
    }
    return 5.0; // Default tax rate
  }
}