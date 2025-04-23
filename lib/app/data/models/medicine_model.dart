// app/data/models/medicine_model.dart

class MedicineModel {
  final String id;
  final String name;
  final String genericName;
  final String type; // 'tablet', 'capsule', 'syrup', 'injection', etc.
  final String strength; // e.g., '500mg', '250ml', etc.
  final int stripQuantity; // Number of tablets/capsules per strip
  final int quantity; // Total quantity in stock
  final double purchasePrice; // Price per unit when purchased
  final double sellingPrice; // Price per unit when sold
  final String? image;
  final DateTime manufacturingDate;
  final DateTime expiryDate;
  final String manufacturerName;
  final String? importerName;
  final String? importerAddress;
  final String? importerPhone;
  final String? sellerName;
  final String? sellerPhone;
  final DateTime addedDate;
  final DateTime updatedDate;
  final String? batchNumber;
  final int alertThreshold; // Alert when stock falls below this
  final bool isActive;
  final String? location; // Shelf/rack location in the pharmacy

  // Add getter for stockQuantity
  int get stockQuantity => quantity;

  MedicineModel({
    required this.id,
    required this.name,
    required this.genericName,
    required this.type,
    required this.strength,
    required this.stripQuantity,
    required this.quantity,
    required this.purchasePrice,
    required this.sellingPrice,
    this.image,
    required this.manufacturingDate,
    required this.expiryDate,
    required this.manufacturerName,
    this.importerName,
    this.importerAddress,
    this.importerPhone,
    this.sellerName,
    this.sellerPhone,
    required this.addedDate,
    required this.updatedDate,
    this.batchNumber,
    required this.alertThreshold,
    this.isActive = true,
    this.location,
  });

  factory MedicineModel.fromJson(Map<String, dynamic> json) {
    return MedicineModel(
      id: json['id'],
      name: json['name'],
      genericName: json['genericName'],
      type: json['type'],
      strength: json['strength'],
      stripQuantity: json['stripQuantity'],
      quantity: json['quantity'],
      purchasePrice: json['purchasePrice'].toDouble(),
      sellingPrice: json['sellingPrice'].toDouble(),
      image: json['image'],
      manufacturingDate: DateTime.parse(json['manufacturingDate']),
      expiryDate: DateTime.parse(json['expiryDate']),
      manufacturerName: json['manufacturerName'],
      importerName: json['importerName'],
      importerAddress: json['importerAddress'],
      importerPhone: json['importerPhone'],
      sellerName: json['sellerName'],
      sellerPhone: json['sellerPhone'],
      addedDate: DateTime.parse(json['addedDate']),
      updatedDate: DateTime.parse(json['updatedDate']),
      batchNumber: json['batchNumber'],
      alertThreshold: json['alertThreshold'],
      isActive: json['isActive'] ?? true,
      location: json['location'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'genericName': genericName,
      'type': type,
      'strength': strength,
      'stripQuantity': stripQuantity,
      'quantity': quantity,
      'purchasePrice': purchasePrice,
      'sellingPrice': sellingPrice,
      'image': image,
      'manufacturingDate': manufacturingDate.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
      'manufacturerName': manufacturerName,
      'importerName': importerName,
      'importerAddress': importerAddress,
      'importerPhone': importerPhone,
      'sellerName': sellerName,
      'sellerPhone': sellerPhone,
      'addedDate': addedDate.toIso8601String(),
      'updatedDate': updatedDate.toIso8601String(),
      'batchNumber': batchNumber,
      'alertThreshold': alertThreshold,
      'isActive': isActive,
      'location': location,
    };
  }

  MedicineModel copyWith({
    String? id,
    String? name,
    String? genericName,
    String? type,
    String? strength,
    int? stripQuantity,
    int? quantity,
    double? purchasePrice,
    double? sellingPrice,
    String? image,
    DateTime? manufacturingDate,
    DateTime? expiryDate,
    String? manufacturerName,
    String? importerName,
    String? importerAddress,
    String? importerPhone,
    String? sellerName,
    String? sellerPhone,
    DateTime? addedDate,
    DateTime? updatedDate,
    String? batchNumber,
    int? alertThreshold,
    bool? isActive,
    String? location,
  }) {
    return MedicineModel(
      id: id ?? this.id,
      name: name ?? this.name,
      genericName: genericName ?? this.genericName,
      type: type ?? this.type,
      strength: strength ?? this.strength,
      stripQuantity: stripQuantity ?? this.stripQuantity,
      quantity: quantity ?? this.quantity,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      image: image ?? this.image,
      manufacturingDate: manufacturingDate ?? this.manufacturingDate,
      expiryDate: expiryDate ?? this.expiryDate,
      manufacturerName: manufacturerName ?? this.manufacturerName,
      importerName: importerName ?? this.importerName,
      importerAddress: importerAddress ?? this.importerAddress,
      importerPhone: importerPhone ?? this.importerPhone,
      sellerName: sellerName ?? this.sellerName,
      sellerPhone: sellerPhone ?? this.sellerPhone,
      addedDate: addedDate ?? this.addedDate,
      updatedDate: updatedDate ?? this.updatedDate,
      batchNumber: batchNumber ?? this.batchNumber,
      alertThreshold: alertThreshold ?? this.alertThreshold,
      isActive: isActive ?? this.isActive,
      location: location ?? this.location,
    );
  }
}