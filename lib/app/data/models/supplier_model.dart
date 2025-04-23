// app/data/models/supplier_model.dart

class SupplierModel {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String? email;
  final String? contactPersonName;
  final String? contactPersonPhone;
  final String? logo;
  final String? website;
  final String? taxId;
  final String? licenseNumber;
  final String? accountNumber;
  final String? bankName;
  final String? bankBranch;
  final double totalPurchase;
  final double dueAmount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  SupplierModel({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    this.email,
    this.contactPersonName,
    this.contactPersonPhone,
    this.logo,
    this.website,
    this.taxId,
    this.licenseNumber,
    this.accountNumber,
    this.bankName,
    this.bankBranch,
    this.totalPurchase = 0.0,
    this.dueAmount = 0.0,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    return SupplierModel(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      phone: json['phone'],
      email: json['email'],
      contactPersonName: json['contactPersonName'],
      contactPersonPhone: json['contactPersonPhone'],
      logo: json['logo'],
      website: json['website'],
      taxId: json['taxId'],
      licenseNumber: json['licenseNumber'],
      accountNumber: json['accountNumber'],
      bankName: json['bankName'],
      bankBranch: json['bankBranch'],
      totalPurchase: json['totalPurchase']?.toDouble() ?? 0.0,
      dueAmount: json['dueAmount']?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'email': email,
      'contactPersonName': contactPersonName,
      'contactPersonPhone': contactPersonPhone,
      'logo': logo,
      'website': website,
      'taxId': taxId,
      'licenseNumber': licenseNumber,
      'accountNumber': accountNumber,
      'bankName': bankName,
      'bankBranch': bankBranch,
      'totalPurchase': totalPurchase,
      'dueAmount': dueAmount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  SupplierModel copyWith({
    String? id,
    String? name,
    String? address,
    String? phone,
    String? email,
    String? contactPersonName,
    String? contactPersonPhone,
    String? logo,
    String? website,
    String? taxId,
    String? licenseNumber,
    String? accountNumber,
    String? bankName,
    String? bankBranch,
    double? totalPurchase,
    double? dueAmount,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return SupplierModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      contactPersonName: contactPersonName ?? this.contactPersonName,
      contactPersonPhone: contactPersonPhone ?? this.contactPersonPhone,
      logo: logo ?? this.logo,
      website: website ?? this.website,
      taxId: taxId ?? this.taxId,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      accountNumber: accountNumber ?? this.accountNumber,
      bankName: bankName ?? this.bankName,
      bankBranch: bankBranch ?? this.bankBranch,
      totalPurchase: totalPurchase ?? this.totalPurchase,
      dueAmount: dueAmount ?? this.dueAmount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}