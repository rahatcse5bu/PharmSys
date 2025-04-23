// app/data/models/customer_model.dart

class CustomerModel {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? address;
  final String? customerType;  // 'regular', 'wholesale', etc.
  final String? contactPersonName;
  final String? contactPersonPhone;
  final double dueAmount;
  final double totalPurchase;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  CustomerModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.address,
    this.customerType,
    this.contactPersonName,
    this.contactPersonPhone,
    this.dueAmount = 0.0,
    this.totalPurchase = 0.0,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      customerType: json['customerType'],
      contactPersonName: json['contactPersonName'],
      contactPersonPhone: json['contactPersonPhone'],
      dueAmount: json['dueAmount']?.toDouble() ?? 0.0,
      totalPurchase: json['totalPurchase']?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'customerType': customerType,
      'contactPersonName': contactPersonName,
      'contactPersonPhone': contactPersonPhone,
      'dueAmount': dueAmount,
      'totalPurchase': totalPurchase,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  CustomerModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    String? customerType,
    String? contactPersonName,
    String? contactPersonPhone,
    double? dueAmount,
    double? totalPurchase,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      customerType: customerType ?? this.customerType,
      contactPersonName: contactPersonName ?? this.contactPersonName,
      contactPersonPhone: contactPersonPhone ?? this.contactPersonPhone,
      dueAmount: dueAmount ?? this.dueAmount,
      totalPurchase: totalPurchase ?? this.totalPurchase,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}