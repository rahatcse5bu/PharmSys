// app/data/repositories/supplier_repository.dart

import 'package:pharma_sys/app/data/models/supplier_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class SupplierRepository {
  final Database database;
  final String tableName = 'suppliers';
  final Uuid uuid = Uuid();
  
  SupplierRepository({required this.database});

  Future<void> createTable() async {
    await database.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        address TEXT NOT NULL,
        phone TEXT NOT NULL,
        email TEXT,
        contactPersonName TEXT,
        contactPersonPhone TEXT,
        logo TEXT,
        website TEXT,
        taxId TEXT,
        licenseNumber TEXT,
        accountNumber TEXT,
        bankName TEXT,
        bankBranch TEXT,
        totalPurchase REAL NOT NULL,
        dueAmount REAL NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        isActive INTEGER NOT NULL
      )
    ''');
  }

  Future<List<SupplierModel>> getAllSuppliers() async {
    final List<Map<String, dynamic>> maps = await database.query(tableName);
    
    return List.generate(maps.length, (i) {
      return SupplierModel(
        id: maps[i]['id'],
        name: maps[i]['name'],
        address: maps[i]['address'],
        phone: maps[i]['phone'],
        email: maps[i]['email'],
        contactPersonName: maps[i]['contactPersonName'],
        contactPersonPhone: maps[i]['contactPersonPhone'],
        logo: maps[i]['logo'],
        website: maps[i]['website'],
        taxId: maps[i]['taxId'],
        licenseNumber: maps[i]['licenseNumber'],
        accountNumber: maps[i]['accountNumber'],
        bankName: maps[i]['bankName'],
        bankBranch: maps[i]['bankBranch'],
        totalPurchase: maps[i]['totalPurchase'],
        dueAmount: maps[i]['dueAmount'],
        createdAt: DateTime.parse(maps[i]['createdAt']),
        updatedAt: DateTime.parse(maps[i]['updatedAt']),
        isActive: maps[i]['isActive'] == 1,
      );
    });
  }

  Future<SupplierModel?> getSupplierById(String id) async {
    final List<Map<String, dynamic>> maps = await database.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      return SupplierModel(
        id: maps[0]['id'],
        name: maps[0]['name'],
        address: maps[0]['address'],
        phone: maps[0]['phone'],
        email: maps[0]['email'],
        contactPersonName: maps[0]['contactPersonName'],
        contactPersonPhone: maps[0]['contactPersonPhone'],
        logo: maps[0]['logo'],
        website: maps[0]['website'],
        taxId: maps[0]['taxId'],
        licenseNumber: maps[0]['licenseNumber'],
        accountNumber: maps[0]['accountNumber'],
        bankName: maps[0]['bankName'],
        bankBranch: maps[0]['bankBranch'],
        totalPurchase: maps[0]['totalPurchase'],
        dueAmount: maps[0]['dueAmount'],
        createdAt: DateTime.parse(maps[0]['createdAt']),
        updatedAt: DateTime.parse(maps[0]['updatedAt']),
        isActive: maps[0]['isActive'] == 1,
      );
    }
    return null;
  }

  Future<List<SupplierModel>> getActiveSuppliers() async {
    final List<Map<String, dynamic>> maps = await database.query(
      tableName,
      where: 'isActive = ?',
      whereArgs: [1],
    );
    
    return List.generate(maps.length, (i) {
      return SupplierModel(
        id: maps[i]['id'],
        name: maps[i]['name'],
        address: maps[i]['address'],
        phone: maps[i]['phone'],
        email: maps[i]['email'],
        contactPersonName: maps[i]['contactPersonName'],
        contactPersonPhone: maps[i]['contactPersonPhone'],
        logo: maps[i]['logo'],
        website: maps[i]['website'],
        taxId: maps[i]['taxId'],
        licenseNumber: maps[i]['licenseNumber'],
        accountNumber: maps[i]['accountNumber'],
        bankName: maps[i]['bankName'],
        bankBranch: maps[i]['bankBranch'],
        totalPurchase: maps[i]['totalPurchase'],
        dueAmount: maps[i]['dueAmount'],
        createdAt: DateTime.parse(maps[i]['createdAt']),
        updatedAt: DateTime.parse(maps[i]['updatedAt']),
        isActive: true,
      );
    });
  }

  Future<String> addSupplier(SupplierModel supplier) async {
    final String id = uuid.v4();
    final now = DateTime.now();
    
    await database.insert(
      tableName,
      {
        'id': id,
        'name': supplier.name,
        'address': supplier.address,
        'phone': supplier.phone,
        'email': supplier.email,
        'contactPersonName': supplier.contactPersonName,
        'contactPersonPhone': supplier.contactPersonPhone,
        'logo': supplier.logo,
        'website': supplier.website,
        'taxId': supplier.taxId,
        'licenseNumber': supplier.licenseNumber,
        'accountNumber': supplier.accountNumber,
        'bankName': supplier.bankName,
        'bankBranch': supplier.bankBranch,
        'totalPurchase': supplier.totalPurchase,
        'dueAmount': supplier.dueAmount,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
        'isActive': supplier.isActive ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    return id;
  }

  Future<void> updateSupplier(SupplierModel supplier) async {
    final now = DateTime.now();
    
    await database.update(
      tableName,
      {
        'name': supplier.name,
        'address': supplier.address,
        'phone': supplier.phone,
        'email': supplier.email,
        'contactPersonName': supplier.contactPersonName,
        'contactPersonPhone': supplier.contactPersonPhone,
        'logo': supplier.logo,
        'website': supplier.website,
        'taxId': supplier.taxId,
        'licenseNumber': supplier.licenseNumber,
        'accountNumber': supplier.accountNumber,
        'bankName': supplier.bankName,
        'bankBranch': supplier.bankBranch,
        'totalPurchase': supplier.totalPurchase,
        'dueAmount': supplier.dueAmount,
        'updatedAt': now.toIso8601String(),
        'isActive': supplier.isActive ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [supplier.id],
    );
  }

  Future<void> updateSupplierStatus(String id, bool isActive) async {
    final now = DateTime.now();
    
    await database.update(
      tableName,
      {
        'isActive': isActive ? 1 : 0,
        'updatedAt': now.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteSupplier(String id) async {
    await database.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateDueAmount(String id, double amount) async {
    final now = DateTime.now();
    final supplier = await getSupplierById(id);
    
    if (supplier != null) {
      final newDueAmount = supplier.dueAmount + amount;
      
      await database.update(
        tableName,
        {
          'dueAmount': newDueAmount,
          'updatedAt': now.toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  Future<void> updateTotalPurchase(String id, double amount) async {
    final now = DateTime.now();
    final supplier = await getSupplierById(id);
    
    if (supplier != null) {
      final newTotalPurchase = supplier.totalPurchase + amount;
      
      await database.update(
        tableName,
        {
          'totalPurchase': newTotalPurchase,
          'updatedAt': now.toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  Future<void> payDue(String id, double amount) async {
    final now = DateTime.now();
    final supplier = await getSupplierById(id);
    
    if (supplier != null) {
      final newDueAmount = supplier.dueAmount - amount;
      
      await database.update(
        tableName,
        {
          'dueAmount': newDueAmount < 0 ? 0 : newDueAmount,
          'updatedAt': now.toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }
}