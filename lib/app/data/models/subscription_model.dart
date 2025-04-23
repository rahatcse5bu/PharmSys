// app/data/models/subscription_model.dart

class SubscriptionModel {
  final String id;
  final String userId;
  final String planType; // 'monthly', 'yearly', etc.
  final double amount;
  final String currency; // 'BDT', 'USD', etc.
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final String? transactionId;
  final String? paymentMethod; // 'bKash', 'Nagad', 'Credit Card', etc.
  final DateTime createdAt;
  final DateTime updatedAt;

  SubscriptionModel({
    required this.id,
    required this.userId,
    required this.planType,
    required this.amount,
    required this.currency,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    this.transactionId,
    this.paymentMethod,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'],
      userId: json['userId'],
      planType: json['planType'],
      amount: json['amount'].toDouble(),
      currency: json['currency'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      isActive: json['isActive'],
      transactionId: json['transactionId'],
      paymentMethod: json['paymentMethod'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'planType': planType,
      'amount': amount,
      'currency': currency,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isActive': isActive,
      'transactionId': transactionId,
      'paymentMethod': paymentMethod,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  SubscriptionModel copyWith({
    String? id,
    String? userId,
    String? planType,
    double? amount,
    String? currency,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    String? transactionId,
    String? paymentMethod,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SubscriptionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      planType: planType ?? this.planType,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      transactionId: transactionId ?? this.transactionId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool isExpired() {
    return DateTime.now().isAfter(endDate) || !isActive;
  }

  int daysLeft() {
    final now = DateTime.now();
    if (now.isAfter(endDate)) return 0;
    return endDate.difference(now).inDays;
  }
}