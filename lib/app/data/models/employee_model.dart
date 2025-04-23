// app/data/models/employee_model.dart

class EmployeeModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String role; // 'pharmacist', 'assistant', 'salesperson', etc.
  final double salary;
  final String? profileImage;
  final DateTime joiningDate;
  final DateTime? lastActiveDate;
  final bool isActive;
  final Map<String, dynamic>? permissions;

  EmployeeModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.role,
    required this.salary,
    this.profileImage,
    required this.joiningDate,
    this.lastActiveDate,
    this.isActive = true,
    this.permissions,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      role: json['role'],
      salary: json['salary'].toDouble(),
      profileImage: json['profileImage'],
      joiningDate: DateTime.parse(json['joiningDate']),
      lastActiveDate: json['lastActiveDate'] != null 
          ? DateTime.parse(json['lastActiveDate']) 
          : null,
      isActive: json['isActive'] ?? true,
      permissions: json['permissions'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'role': role,
      'salary': salary,
      'profileImage': profileImage,
      'joiningDate': joiningDate.toIso8601String(),
      'lastActiveDate': lastActiveDate?.toIso8601String(),
      'isActive': isActive,
      'permissions': permissions,
    };
  }

  EmployeeModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? role,
    double? salary,
    String? profileImage,
    DateTime? joiningDate,
    DateTime? lastActiveDate,
    bool? isActive,
    Map<String, dynamic>? permissions,
  }) {
    return EmployeeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      role: role ?? this.role,
      salary: salary ?? this.salary,
      profileImage: profileImage ?? this.profileImage,
      joiningDate: joiningDate ?? this.joiningDate,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      isActive: isActive ?? this.isActive,
      permissions: permissions ?? this.permissions,
    );
  }
}