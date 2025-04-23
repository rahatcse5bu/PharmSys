// app/data/repositories/sale_repository.dart

import 'package:pharma_sys/app/data/models/sale_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class SaleRepository {
  final Database database;
  final String tableName = 'sales';
  final String saleItemsTable = 'sale_items';
  final Uuid uuid = Uuid();
  
  SaleRepository({required this.database});

  Future<void> createTables() async {
    // Create the sales table
    await database.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        id TEXT PRIMARY KEY,
        invoiceNumber TEXT NOT NULL,
        saleDate TEXT NOT NULL,
        customerId TEXT NOT NULL,
        customerName TEXT,
        customerPhone TEXT,
        employeeId TEXT NOT NULL,
        employeeName TEXT NOT NULL,
        subtotal REAL NOT NULL,
        discount REAL NOT NULL,
        tax REAL NOT NULL,
        total REAL NOT NULL,
        paymentMethod TEXT NOT NULL,
        paymentStatus TEXT NOT NULL,
        paidAmount REAL NOT NULL,
        dueAmount REAL NOT NULL,
        notes TEXT
      )
    ''');
    
    // Create the sale items table
    await database.execute('''
      CREATE TABLE IF NOT EXISTS $saleItemsTable (
        id TEXT PRIMARY KEY,
        saleId TEXT NOT NULL,
        medicineId TEXT NOT NULL,
        medicineName TEXT NOT NULL,
        medicineType TEXT NOT NULL,
        medicineStrength TEXT NOT NULL,
        unitPrice REAL NOT NULL,
        quantity INTEGER NOT NULL,
        totalPrice REAL NOT NULL,
        discount REAL NOT NULL,
        finalPrice REAL NOT NULL,
        FOREIGN KEY (saleId) REFERENCES $tableName (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<List<SaleModel>> getAllSales() async {
    final List<Map<String, dynamic>> saleMaps = await database.query(tableName);
    return Future.wait(saleMaps.map((saleMap) async {
      final saleItems = await getSaleItemsForSale(saleMap['id'] as String);
      return SaleModel.fromJson({
        ...saleMap,
        'items': saleItems.map((item) => item.toJson()).toList(),
      });
    }).toList());
  }

  Future<SaleModel?> getSaleById(String id) async {
    final List<Map<String, dynamic>> maps = await database.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      final saleItems = await getSaleItemsForSale(id);
      return SaleModel.fromJson({
        ...maps.first,
        'items': saleItems.map((item) => item.toJson()).toList(),
      });
    }
    return null;
  }

  Future<List<SaleItemModel>> getSaleItemsForSale(String saleId) async {
    final List<Map<String, dynamic>> maps = await database.query(
      saleItemsTable,
      where: 'saleId = ?',
      whereArgs: [saleId],
    );
    
    return List.generate(maps.length, (i) {
      return SaleItemModel.fromJson(maps[i]);
    });
  }

  Future<List<SaleModel>> getSalesByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final List<Map<String, dynamic>> maps = await database.query(
      tableName,
      where: 'saleDate BETWEEN ? AND ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'saleDate DESC',
    );
    
    return Future.wait(maps.map((saleMap) async {
      final saleItems = await getSaleItemsForSale(saleMap['id'] as String);
      return SaleModel.fromJson({
        ...saleMap,
        'items': saleItems.map((item) => item.toJson()).toList(),
      });
    }).toList());
  }

  Future<List<SaleModel>> getSalesByEmployee(String employeeId) async {
    final List<Map<String, dynamic>> maps = await database.query(
      tableName,
      where: 'employeeId = ?',
      whereArgs: [employeeId],
      orderBy: 'saleDate DESC',
    );
    
    return Future.wait(maps.map((saleMap) async {
      final saleItems = await getSaleItemsForSale(saleMap['id'] as String);
      return SaleModel.fromJson({
        ...saleMap,
        'items': saleItems.map((item) => item.toJson()).toList(),
      });
    }).toList());
  }

  Future<List<SaleModel>> getRecentSales({int limit = 10}) async {
    final List<Map<String, dynamic>> maps = await database.query(
      tableName,
      orderBy: 'saleDate DESC',
      limit: limit,
    );
    
    return Future.wait(maps.map((saleMap) async {
      final saleItems = await getSaleItemsForSale(saleMap['id'] as String);
      return SaleModel.fromJson({
        ...saleMap,
        'items': saleItems.map((item) => item.toJson()).toList(),
      });
    }).toList());
  }

  Future<String> createSale(SaleModel sale) async {
    final String id = uuid.v4();
    final Map<String, dynamic> saleMap = sale.copyWith(
      id: id,
      invoiceNumber: 'INV-${DateTime.now().millisecondsSinceEpoch}',
    ).toJson();
    
    // Remove items from the sale map as they go in a separate table
    final items = saleMap.remove('items') as List;
    
    // Insert the sale
    await database.insert(
      tableName,
      saleMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    // Insert each sale item
    for (var itemData in items) {
      final item = SaleItemModel.fromJson(itemData);
      await database.insert(
        saleItemsTable,
        {
          'id': uuid.v4(),
          'saleId': id,
          ...item.toJson(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    
    return id;
  }

  Future<void> updateSale(SaleModel sale) async {
    // Update the sale record
    final saleMap = sale.toJson();
    final items = saleMap.remove('items') as List;
    
    await database.update(
      tableName,
      saleMap,
      where: 'id = ?',
      whereArgs: [sale.id],
    );
    
    // Delete existing items
    await database.delete(
      saleItemsTable,
      where: 'saleId = ?',
      whereArgs: [sale.id],
    );
    
    // Insert updated items
    for (var itemData in items) {
      final item = SaleItemModel.fromJson(itemData);
      await database.insert(
        saleItemsTable,
        {
          'id': uuid.v4(),
          'saleId': sale.id,
          ...item.toJson(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> deleteSale(String id) async {
    // Delete the sale (this will cascade delete the items as well)
    await database.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Map<String, dynamic>> getSalesStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    List<SaleModel> sales;
    
    if (startDate != null && endDate != null) {
      sales = await getSalesByDateRange(
        startDate: startDate,
        endDate: endDate,
      );
    } else {
      sales = await getAllSales();
    }
    
    // Calculate statistics
    final totalSales = sales.length;
    final totalRevenue = sales.fold(0.0, (sum, sale) => sum + sale.total);
    final totalItems = sales.fold(0, (sum, sale) => sum + sale.items.length);
    
    // Average sale value
    final averageSaleValue = totalSales > 0 ? totalRevenue / totalSales : 0.0;
    
    // Payment method distribution
    final paymentMethods = <String, int>{};
    for (final sale in sales) {
      paymentMethods[sale.paymentMethod] = (paymentMethods[sale.paymentMethod] ?? 0) + 1;
    }
    
    return {
      'totalSales': totalSales,
      'totalRevenue': totalRevenue,
      'totalItems': totalItems,
      'averageSaleValue': averageSaleValue,
      'paymentMethods': paymentMethods,
    };
  }
}