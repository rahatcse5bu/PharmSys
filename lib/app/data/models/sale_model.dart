// app/data/models/sale_model.dart

class SaleItemModel {
  final String medicineId;
  final String medicineName;
  final String medicineType;
  final String medicineStrength;
  final double unitPrice;
  final int quantity;
  final double totalPrice;
  final double discount;
  final double finalPrice;

  SaleItemModel({
    required this.medicineId,
    required this.medicineName,
    required this.medicineType,
    required this.medicineStrength,
    required this.unitPrice,
    required this.quantity,
    required this.totalPrice,
    required this.discount,
    required this.finalPrice,
  });

  factory SaleItemModel.fromJson(Map<String, dynamic> json) {
    return SaleItemModel(
      medicineId: json['medicineId'],
      medicineName: json['medicineName'],
      medicineType: json['medicineType'],
      medicineStrength: json['medicineStrength'],
      unitPrice: json['unitPrice'].toDouble(),
      quantity: json['quantity'],
      totalPrice: json['totalPrice'].toDouble(),
      discount: json['discount'].toDouble(),
      finalPrice: json['finalPrice'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'medicineId': medicineId,
      'medicineName': medicineName,
      'medicineType': medicineType,
      'medicineStrength': medicineStrength,
      'unitPrice': unitPrice,
      'quantity': quantity,
      'totalPrice': totalPrice,
      'discount': discount,
      'finalPrice': finalPrice,
    };
  }
}

class SaleModel {
  final String id;
  final String invoiceNumber;
  final DateTime saleDate;
  final String customerId;
  final String? customerName;
  final String? customerPhone;
  final String employeeId;
  final String employeeName;
  final List<SaleItemModel> items;
  final double subtotal;
  final double discount;
  final double tax;
  final double total;
  final String paymentMethod; // 'cash', 'card', 'mobile'
  final String paymentStatus; // 'paid', 'due', 'partial'
  final double paidAmount;
  final double dueAmount;
  final String? notes;

  SaleModel({
    required this.id,
    required this.invoiceNumber,
    required this.saleDate,
    required this.customerId,
    this.customerName,
    this.customerPhone,
    required this.employeeId,
    required this.employeeName,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.total,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.paidAmount,
    required this.dueAmount,
    this.notes,
  });

  factory SaleModel.fromJson(Map<String, dynamic> json) {
    return SaleModel(
      id: json['id'],
      invoiceNumber: json['invoiceNumber'],
      saleDate: DateTime.parse(json['saleDate']),
      customerId: json['customerId'],
      customerName: json['customerName'],
      customerPhone: json['customerPhone'],
      employeeId: json['employeeId'],
      employeeName: json['employeeName'],
      items: (json['items'] as List)
          .map((item) => SaleItemModel.fromJson(item))
          .toList(),
      subtotal: json['subtotal'].toDouble(),
      discount: json['discount'].toDouble(),
      tax: json['tax'].toDouble(),
      total: json['total'].toDouble(),
      paymentMethod: json['paymentMethod'],
      paymentStatus: json['paymentStatus'],
      paidAmount: json['paidAmount'].toDouble(),
      dueAmount: json['dueAmount'].toDouble(),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoiceNumber': invoiceNumber,
      'saleDate': saleDate.toIso8601String(),
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'discount': discount,
      'tax': tax,
      'total': total,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'paidAmount': paidAmount,
      'dueAmount': dueAmount,
      'notes': notes,
    };
  }

  SaleModel copyWith({
    String? id,
    String? invoiceNumber,
    DateTime? saleDate,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? employeeId,
    String? employeeName,
    List<SaleItemModel>? items,
    double? subtotal,
    double? discount,
    double? tax,
    double? total,
    String? paymentMethod,
    String? paymentStatus,
    double? paidAmount,
    double? dueAmount,
    String? notes,
  }) {
    return SaleModel(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      saleDate: saleDate ?? this.saleDate,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paidAmount: paidAmount ?? this.paidAmount,
      dueAmount: dueAmount ?? this.dueAmount,
      notes: notes ?? this.notes,
    );
  }
}