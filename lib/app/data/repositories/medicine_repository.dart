// app/data/repositories/medicine_repository.dart

import 'package:pharmacy_inventory_app/app/data/models/medicine_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class MedicineRepository {
  final Database database;
  final String tableName = 'medicines';
  final Uuid uuid = Uuid();

  MedicineRepository({required this.database});

  Future<List<MedicineModel>> getAllMedicines() async {
    final List<Map<String, dynamic>> maps = await database.query(tableName);
    return List.generate(maps.length, (i) {
      return MedicineModel.fromJson(maps[i]);
    });
  }

  Future<MedicineModel?> getMedicineById(String id) async {
    final List<Map<String, dynamic>> maps = await database.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return MedicineModel.fromJson(maps.first);
    }
    return null;
  }

  Future<List<MedicineModel>> getMedicinesByGenericName(String genericName) async {
    final List<Map<String, dynamic>> maps = await database.query(
      tableName,
      where: 'genericName LIKE ?',
      whereArgs: ['%$genericName%'],
    );

    return List.generate(maps.length, (i) {
      return MedicineModel.fromJson(maps[i]);
    });
  }

  Future<List<MedicineModel>> searchMedicines(String query) async {
    final List<Map<String, dynamic>> maps = await database.query(
      tableName,
      where: 'name LIKE ? OR genericName LIKE ? OR manufacturerName LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
    );

    return List.generate(maps.length, (i) {
      return MedicineModel.fromJson(maps[i]);
    });
  }

  Future<List<MedicineModel>> getLowStockMedicines() async {
    final List<Map<String, dynamic>> maps = await database.query(
      tableName,
      where: 'quantity <= alertThreshold',
    );

    return List.generate(maps.length, (i) {
      return MedicineModel.fromJson(maps[i]);
    });
  }

  Future<List<MedicineModel>> getExpiringMedicines({int daysThreshold = 30}) async {
    final now = DateTime.now();
    final thresholdDate = now.add(Duration(days: daysThreshold));
    
    final List<Map<String, dynamic>> maps = await database.query(
      tableName,
      where: 'expiryDate <= ?',
      whereArgs: [thresholdDate.toIso8601String()],
    );

    return List.generate(maps.length, (i) {
      return MedicineModel.fromJson(maps[i]);
    });
  }

  Future<String> insertMedicine(MedicineModel medicine) async {
    String id = uuid.v4();
    final medicineMap = medicine.copyWith(
      id: id,
      addedDate: DateTime.now(),
      updatedDate: DateTime.now(),
    ).toJson();
    
    await database.insert(
      tableName,
      medicineMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    return id;
  }

  Future<void> updateMedicine(MedicineModel medicine) async {
    final medicineMap = medicine.copyWith(
      updatedDate: DateTime.now(),
    ).toJson();
    
    await database.update(
      tableName,
      medicineMap,
      where: 'id = ?',
      whereArgs: [medicine.id],
    );
  }

  Future<void> updateMedicineQuantity(String id, int newQuantity) async {
    await database.update(
      tableName,
      {'quantity': newQuantity, 'updatedDate': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteMedicine(String id) async {
    await database.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> createTable() async {
    await database.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        genericName TEXT NOT NULL,
        type TEXT NOT NULL,
        strength TEXT NOT NULL,
        stripQuantity INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        purchasePrice REAL NOT NULL,
        sellingPrice REAL NOT NULL,
        image TEXT,
        manufacturingDate TEXT NOT NULL,
        expiryDate TEXT NOT NULL,
        manufacturerName TEXT NOT NULL,
        importerName TEXT,
        importerAddress TEXT,
        importerPhone TEXT,
        sellerName TEXT,
        sellerPhone TEXT,
        addedDate TEXT NOT NULL,
        updatedDate TEXT NOT NULL,
        batchNumber TEXT,
        alertThreshold INTEGER NOT NULL,
        isActive INTEGER NOT NULL,
        location TEXT
      )
    ''');
  }
}