// app/data/models/shop_model.dart

class ShopModel {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String? email;
  final String? website;
  final String? logo;
  final String? licenseNumber;
  final String? taxId;
  final String? ownerName;
  final String? ownerPhone;
  final String? ownerEmail;
  final Map<String, dynamic>? businessHours;
  final Map<String, dynamic>? settings;
  final DateTime createdAt;
  final DateTime updatedAt;

  ShopModel({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    this.email,
    this.website,
    this.logo,
    this.licenseNumber,
    this.taxId,
    this.ownerName,
    this.ownerPhone,
    this.ownerEmail,
    this.businessHours,
    this.settings,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    return ShopModel(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      phone: json['phone'],
      email: json['email'],
      website: json['website'],
      logo: json['logo'],
      licenseNumber: json['licenseNumber'],
      taxId: json['taxId'],
      ownerName: json['ownerName'],
      ownerPhone: json['ownerPhone'],
      ownerEmail: json['ownerEmail'],
      businessHours: json['businessHours'] != null 
          ? Map<String, dynamic>.from(json['businessHours']) 
          : null,
      settings: json['settings'] != null 
          ? Map<String, dynamic>.from(json['settings']) 
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'email': email,
      'website': website,
      'logo': logo,
      'licenseNumber': licenseNumber,
      'taxId': taxId,
      'ownerName': ownerName,
      'ownerPhone': ownerPhone,
      'ownerEmail': ownerEmail,
      'businessHours': businessHours,
      'settings': settings,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  ShopModel copyWith({
    String? id,
    String? name,
    String? address,
    String? phone,
    String? email,
    String? website,
    String? logo,
    String? licenseNumber,
    String? taxId,
    String? ownerName,
    String? ownerPhone,
    String? ownerEmail,
    Map<String, dynamic>? businessHours,
    Map<String, dynamic>? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? currency,
  }) {
    Map<String, dynamic>? updatedSettings;
    
    if (currency != null && settings != null) {
      updatedSettings = Map<String, dynamic>.from(settings);
      updatedSettings['currency'] = currency;
    } else if (currency != null) {
      updatedSettings = {'currency': currency};
    } else {
      updatedSettings = settings;
    }
    
    return ShopModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      logo: logo ?? this.logo,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      taxId: taxId ?? this.taxId,
      ownerName: ownerName ?? this.ownerName,
      ownerPhone: ownerPhone ?? this.ownerPhone,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      businessHours: businessHours ?? this.businessHours,
      settings: updatedSettings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  String? get currency {
    return settings != null && settings!.containsKey('currency')
        ? settings!['currency'] as String
        : null;
  }
  
  double? get taxRate {
    return settings != null && settings!.containsKey('taxRate')
        ? double.parse(settings!['taxRate'].toString())
        : null;
  }
  
  String? get language {
    return settings != null && settings!.containsKey('language')
        ? settings!['language'] as String
        : null;
  }
  
  String? get timezone {
    return settings != null && settings!.containsKey('timezone')
        ? settings!['timezone'] as String
        : null;
  }
}