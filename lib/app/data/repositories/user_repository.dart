// app/data/repositories/user_repository.dart

import 'package:pharma_sys/app/data/models/user_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserRepository {
  final Database database;
  final String tableName = 'users';
  final Uuid uuid = Uuid();
  
  UserRepository({required this.database});

  Future<void> createTable() async {
    await database.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        phone TEXT NOT NULL,
        password TEXT NOT NULL,
        role TEXT NOT NULL,
        profileImage TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        isActive INTEGER NOT NULL
      )
    ''');
  }

  Future<UserModel?> getUserById(String id) async {
    final List<Map<String, dynamic>> maps = await database.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      return UserModel.fromJson(maps.first);
    }
    return null;
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final List<Map<String, dynamic>> maps = await database.query(
      tableName,
      where: 'email = ?',
      whereArgs: [email],
    );
    
    if (maps.isNotEmpty) {
      return UserModel.fromJson(maps.first);
    }
    return null;
  }

  Future<List<UserModel>> getAllUsers() async {
    final List<Map<String, dynamic>> maps = await database.query(tableName);
    
    return List.generate(maps.length, (i) {
      return UserModel.fromJson(maps[i]);
    });
  }

  Future<String> createUser(UserModel user) async {
    final String id = uuid.v4();
    final now = DateTime.now();
    
    final userMap = user.copyWith(
      id: id,
      createdAt: now,
      updatedAt: now,
    ).toJson();
    
    await database.insert(
      tableName,
      userMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    return id;
  }

  Future<void> updateUser(UserModel user) async {
    final now = DateTime.now();
    
    final userMap = user.copyWith(
      updatedAt: now,
    ).toJson();
    
    await database.update(
      tableName,
      userMap,
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<void> deleteUser(String id) async {
    await database.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<bool> authenticateUser(String email, String password) async {
    final List<Map<String, dynamic>> maps = await database.query(
      tableName,
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    
    if (maps.isNotEmpty) {
      // Save user session
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userId', maps.first['id']);
      await prefs.setString('userEmail', maps.first['email']);
      await prefs.setString('userName', maps.first['name']);
      await prefs.setString('userRole', maps.first['role']);
      
      return true;
    }
    return false;
  }

  Future<void> changePassword(String userId, String newPassword) async {
    final now = DateTime.now();
    
    await database.update(
      tableName,
      {
        'password': newPassword,
        'updatedAt': now.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('userId');
    await prefs.remove('userEmail');
    await prefs.remove('userName');
    await prefs.remove('userRole');
  }

  Future<bool> isValidEmail(String email) async {
    final List<Map<String, dynamic>> maps = await database.query(
      tableName,
      where: 'email = ?',
      whereArgs: [email],
    );
    
    return maps.isEmpty; // Email is valid if not already in use
  }

  Future<bool> createDefaultAdminUser() async {
    // Check if admin user already exists
    final List<Map<String, dynamic>> maps = await database.query(
      tableName,
      where: 'email = ?',
      whereArgs: ['admin@pharmflow.com'],
    );
    
    if (maps.isNotEmpty) {
      return false; // Admin user already exists
    }
    
    // Create default admin user
    final now = DateTime.now();
    final adminUser = UserModel(
      id: '',
      name: 'Admin User',
      email: 'admin@pharmflow.com',
      phone: '+8801700000000',
      password: 'admin123',
      role: 'admin',
      profileImage: null,
      createdAt: now,
      updatedAt: now,
      isActive: true,
    );
    
    await createUser(adminUser);
    return true;
  }
}