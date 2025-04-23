// app/data/repositories/employee_repository.dart

import 'package:pharma_sys/app/data/models/employee_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class EmployeeRepository {
  final Database database;
  final String tableName = 'employees';
  final Uuid uuid = Uuid();
  
  EmployeeRepository({required this.database});

  Future<void> createTable() async {
    await database.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        phone TEXT NOT NULL,
        address TEXT NOT NULL,
        role TEXT NOT NULL,
        salary REAL NOT NULL,
        profileImage TEXT,
        joiningDate TEXT NOT NULL,
        lastActiveDate TEXT,
        isActive INTEGER NOT NULL,
        permissions TEXT
      )
    ''');
  }

  Future<List<EmployeeModel>> getAllEmployees() async {
    final List<Map<String, dynamic>> maps = await database.query(tableName);
    
    return List.generate(maps.length, (i) {
      final permissions = maps[i]['permissions'];
      
      return EmployeeModel(
        id: maps[i]['id'],
        name: maps[i]['name'],
        email: maps[i]['email'],
        phone: maps[i]['phone'],
        address: maps[i]['address'],
        role: maps[i]['role'],
        salary: maps[i]['salary'],
        profileImage: maps[i]['profileImage'],
        joiningDate: DateTime.parse(maps[i]['joiningDate']),
        lastActiveDate: maps[i]['lastActiveDate'] != null 
            ? DateTime.parse(maps[i]['lastActiveDate']) 
            : null,
        isActive: maps[i]['isActive'] == 1,
        permissions: permissions != null 
            ? Map<String, dynamic>.from(maps[i]['permissions']) 
            : null,
      );
    });
  }

  Future<EmployeeModel?> getEmployeeById(String id) async {
    final List<Map<String, dynamic>> maps = await database.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      final permissions = maps[0]['permissions'];
      
      return EmployeeModel(
        id: maps[0]['id'],
        name: maps[0]['name'],
        email: maps[0]['email'],
        phone: maps[0]['phone'],
        address: maps[0]['address'],
        role: maps[0]['role'],
        salary: maps[0]['salary'],
        profileImage: maps[0]['profileImage'],
        joiningDate: DateTime.parse(maps[0]['joiningDate']),
        lastActiveDate: maps[0]['lastActiveDate'] != null 
            ? DateTime.parse(maps[0]['lastActiveDate']) 
            : null,
        isActive: maps[0]['isActive'] == 1,
        permissions: permissions != null 
            ? Map<String, dynamic>.from(permissions) 
            : null,
      );
    }
    return null;
  }

  Future<List<EmployeeModel>> getActiveEmployees() async {
    final List<Map<String, dynamic>> maps = await database.query(
      tableName,
      where: 'isActive = ?',
      whereArgs: [1],
    );
    
    return List.generate(maps.length, (i) {
      final permissions = maps[i]['permissions'];
      
      return EmployeeModel(
        id: maps[i]['id'],
        name: maps[i]['name'],
        email: maps[i]['email'],
        phone: maps[i]['phone'],
        address: maps[i]['address'],
        role: maps[i]['role'],
        salary: maps[i]['salary'],
        profileImage: maps[i]['profileImage'],
        joiningDate: DateTime.parse(maps[i]['joiningDate']),
        lastActiveDate: maps[i]['lastActiveDate'] != null 
            ? DateTime.parse(maps[i]['lastActiveDate']) 
            : null,
        isActive: true,
        permissions: permissions != null 
            ? Map<String, dynamic>.from(permissions) 
            : null,
      );
    });
  }

  Future<List<EmployeeModel>> getEmployeesByRole(String role) async {
    final List<Map<String, dynamic>> maps = await database.query(
      tableName,
      where: 'role = ?',
      whereArgs: [role],
    );
    
    return List.generate(maps.length, (i) {
      final permissions = maps[i]['permissions'];
      
      return EmployeeModel(
        id: maps[i]['id'],
        name: maps[i]['name'],
        email: maps[i]['email'],
        phone: maps[i]['phone'],
        address: maps[i]['address'],
        role: maps[i]['role'],
        salary: maps[i]['salary'],
        profileImage: maps[i]['profileImage'],
        joiningDate: DateTime.parse(maps[i]['joiningDate']),
        lastActiveDate: maps[i]['lastActiveDate'] != null 
            ? DateTime.parse(maps[i]['lastActiveDate']) 
            : null,
        isActive: maps[i]['isActive'] == 1,
        permissions: permissions != null 
            ? Map<String, dynamic>.from(permissions) 
            : null,
      );
    });
  }

  Future<String> addEmployee(EmployeeModel employee) async {
    final String id = uuid.v4();
    
    await database.insert(
      tableName,
      {
        'id': id,
        'name': employee.name,
        'email': employee.email,
        'phone': employee.phone,
        'address': employee.address,
        'role': employee.role,
        'salary': employee.salary,
        'profileImage': employee.profileImage,
        'joiningDate': employee.joiningDate.toIso8601String(),
        'lastActiveDate': employee.lastActiveDate?.toIso8601String(),
        'isActive': employee.isActive ? 1 : 0,
        'permissions': employee.permissions != null 
            ? employee.permissions.toString() 
            : null,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    return id;
  }

  Future<void> updateEmployee(EmployeeModel employee) async {
    await database.update(
      tableName,
      {
        'name': employee.name,
        'email': employee.email,
        'phone': employee.phone,
        'address': employee.address,
        'role': employee.role,
        'salary': employee.salary,
        'profileImage': employee.profileImage,
        'joiningDate': employee.joiningDate.toIso8601String(),
        'lastActiveDate': employee.lastActiveDate?.toIso8601String(),
        'isActive': employee.isActive ? 1 : 0,
        'permissions': employee.permissions != null 
            ? employee.permissions.toString() 
            : null,
      },
      where: 'id = ?',
      whereArgs: [employee.id],
    );
  }

  Future<void> updateEmployeeStatus(String id, bool isActive) async {
    await database.update(
      tableName,
      {
        'isActive': isActive ? 1 : 0,
        'lastActiveDate': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteEmployee(String id) async {
    await database.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateEmployeeLastActiveDate(String id) async {
    await database.update(
      tableName,
      {
        'lastActiveDate': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateEmployeePermissions(String id, Map<String, dynamic> permissions) async {
    await database.update(
      tableName,
      {
        'permissions': permissions.toString(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}