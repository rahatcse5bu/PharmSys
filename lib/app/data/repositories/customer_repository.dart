// app/data/repositories/customer_repository.dart

import 'package:pharma_sys/app/data/models/customer_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class CustomerRepository {
  final Database database;
  final String tableName = 'customers';
  final Uuid uuid = Uuid();
  
  CustomerRepository({required this.database});

  Future<void> createTable() async {
    await database.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        email TEXT,
        address TEXT,
        customerType TEXT,
        contactPersonName TEXT,
        contactPersonPhone TEXT,
        dueAmount REAL NOT NULL,
        totalPurchase REAL NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        isActive INTEGER NOT NULL
      )
    ''');
  }

  Future<List<CustomerModel>> getAllCustomers() async {
    final List<Map<String, dynamic>> maps = await database.query(tableName);
    
    return List.generate(maps.length, (i) {
      return CustomerModel.fromJson(maps[i]);
    });
  }

  Future<CustomerModel?> getCustomerById(String id) async {
    final List<Map<String, dynamic>> maps = await database.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      return CustomerModel.fromJson(maps[0]);
    }
    return null;
  }

  Future<List<CustomerModel>> getActiveCustomers() async {
    final List<Map<String, dynamic>> maps = await database.query(
      tableName,
      where: 'isActive = ?',
      whereArgs: [1],
    );
    
    return List.generate(maps.length, (i) {
      return CustomerModel.fromJson(maps[i]);
    });
  }

  Future<String> addCustomer(CustomerModel customer) async {
    final String id = uuid.v4();
    final now = DateTime.now();
    
    await database.insert(
      tableName,
      {
        'id': id,
        'name': customer.name,
        'phone': customer.phone,
        'email': customer.email,
        'address': customer.address,
        'customerType': customer.customerType,
        'contactPersonName': customer.contactPersonName,
        'contactPersonPhone': customer.contactPersonPhone,
        'dueAmount': customer.dueAmount,
        'totalPurchase': customer.totalPurchase,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
        'isActive': customer.isActive ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    return id;
  }

  Future<void> updateCustomer(CustomerModel customer) async {
    final now = DateTime.now();
    
    await database.update(
      tableName,
      {
        'name': customer.name,
        'phone': customer.phone,
        'email': customer.email,
        'address': customer.address,
        'customerType': customer.customerType,
        'contactPersonName': customer.contactPersonName,
        'contactPersonPhone': customer.contactPersonPhone,
        'dueAmount': customer.dueAmount,
        'totalPurchase': customer.totalPurchase,
        'updatedAt': now.toIso8601String(),
        'isActive': customer.isActive ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  Future<void> updateCustomerStatus(String id, bool isActive) async {
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

  Future<void> deleteCustomer(String id) async {
    await database.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateDueAmount(String id, double amount) async {
    final now = DateTime.now();
    final customer = await getCustomerById(id);
    
    if (customer != null) {
      final newDueAmount = customer.dueAmount + amount;
      
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
    final customer = await getCustomerById(id);
    
    if (customer != null) {
      final newTotalPurchase = customer.totalPurchase + amount;
      
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
    final customer = await getCustomerById(id);
    
    if (customer != null) {
      final newDueAmount = customer.dueAmount - amount;
      
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

  Future<List<CustomerModel>> searchCustomers(String query) async {
    final List<Map<String, dynamic>> maps = await database.query(
      tableName,
      where: 'name LIKE ? OR phone LIKE ? OR email LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
    );
    
    return List.generate(maps.length, (i) {
      return CustomerModel.fromJson(maps[i]);
    });
  }

  Future<List<CustomerModel>> getCustomersWithDue() async {
    final List<Map<String, dynamic>> maps = await database.query(
      tableName,
      where: 'dueAmount > ?',
      whereArgs: [0],
    );
    
    return List.generate(maps.length, (i) {
      return CustomerModel.fromJson(maps[i]);
    });
  }
}