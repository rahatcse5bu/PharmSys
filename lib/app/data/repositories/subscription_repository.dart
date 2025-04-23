// app/data/repositories/subscription_repository.dart

import 'package:pharma_sys/app/data/models/subscription_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class SubscriptionRepository {
  final Database database;
  final String tableName = 'subscriptions';
  final Uuid uuid = Uuid();

  SubscriptionRepository({required this.database});

  Future<void> createTable() async {
    await database.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        planType TEXT NOT NULL,
        amount REAL NOT NULL,
        currency TEXT NOT NULL,
        startDate TEXT NOT NULL,
        endDate TEXT NOT NULL,
        isActive INTEGER NOT NULL,
        transactionId TEXT,
        paymentMethod TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
  }

  Future<SubscriptionModel?> getCurrentSubscription(String userId) async {
    final List<Map<String, dynamic>> maps = await database.query(
      tableName,
      where: 'userId = ? AND isActive = 1',
      whereArgs: [userId],
      orderBy: 'endDate DESC',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return SubscriptionModel.fromJson(maps.first);
    }
    return null;
  }

  Future<List<SubscriptionModel>> getSubscriptionHistory(String userId) async {
    final List<Map<String, dynamic>> maps = await database.query(
      tableName,
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'endDate DESC',
    );

    return List.generate(maps.length, (i) {
      return SubscriptionModel.fromJson(maps[i]);
    });
  }

  Future<String> createSubscription(SubscriptionModel subscription) async {
    String id = uuid.v4();
    final now = DateTime.now();
    
    // Deactivate any existing active subscriptions
    await database.update(
      tableName,
      {'isActive': 0, 'updatedAt': now.toIso8601String()},
      where: 'userId = ? AND isActive = 1',
      whereArgs: [subscription.userId],
    );
    
    // Create new subscription
    final subscriptionMap = subscription.copyWith(
      id: id,
      createdAt: now,
      updatedAt: now,
      isActive: true,
    ).toJson();
    
    await database.insert(
      tableName,
      subscriptionMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    return id;
  }

  Future<void> renewSubscription(String subscriptionId, DateTime newEndDate) async {
    final now = DateTime.now();
    
    await database.update(
      tableName,
      {
        'endDate': newEndDate.toIso8601String(),
        'isActive': 1,
        'updatedAt': now.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [subscriptionId],
    );
  }

  Future<void> cancelSubscription(String subscriptionId) async {
    final now = DateTime.now();
    
    await database.update(
      tableName,
      {
        'isActive': 0,
        'updatedAt': now.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [subscriptionId],
    );
  }

  Future<bool> hasActiveSubscription(String userId) async {
    final now = DateTime.now().toIso8601String();
    
    final List<Map<String, dynamic>> maps = await database.query(
      tableName,
      where: 'userId = ? AND isActive = 1 AND endDate > ?',
      whereArgs: [userId, now],
      limit: 1,
    );
    
    return maps.isNotEmpty;
  }

  Future<void> checkAndUpdateExpiredSubscriptions() async {
    final now = DateTime.now().toIso8601String();
    
    // Update all expired subscriptions to inactive
    await database.update(
      tableName,
      {
        'isActive': 0,
        'updatedAt': now,
      },
      where: 'endDate < ? AND isActive = 1',
      whereArgs: [now],
    );
  }

  // Create a trial subscription for new users
  Future<String> createTrialSubscription(String userId) async {
    final now = DateTime.now();
    final trialEnd = now.add(const Duration(days: 7)); // 7-day trial
    
    final trialSubscription = SubscriptionModel(
      id: '',
      userId: userId,
      planType: 'trial',
      amount: 0,
      currency: 'BDT',
      startDate: now,
      endDate: trialEnd,
      isActive: true,
      transactionId: 'trial-${uuid.v4()}',
      paymentMethod: 'trial',
      createdAt: now,
      updatedAt: now,
    );
    
    return await createSubscription(trialSubscription);
  }

  // Create a monthly subscription (500 BDT)
  Future<String> createMonthlySubscription(
    String userId, 
    String transactionId, 
    String paymentMethod
  ) async {
    final now = DateTime.now();
    final subscriptionEnd = now.add(const Duration(days: 30)); // 30-day subscription
    
    final monthlySubscription = SubscriptionModel(
      id: '',
      userId: userId,
      planType: 'monthly',
      amount: 500,
      currency: 'BDT',
      startDate: now,
      endDate: subscriptionEnd,
      isActive: true,
      transactionId: transactionId,
      paymentMethod: paymentMethod,
      createdAt: now,
      updatedAt: now,
    );
    
    return await createSubscription(monthlySubscription);
  }
}