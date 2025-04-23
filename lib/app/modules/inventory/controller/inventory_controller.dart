// app/modules/inventory/controllers/inventory_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharma_sys/app/data/models/medicine_model.dart';
import 'package:pharma_sys/app/modules/inventory/view_models/inventory_view_model.dart';
import 'package:pharma_sys/app/routes/app_routes.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class InventoryController extends GetxController {
  final InventoryViewModel _viewModel;
  
  // Form controllers
  final nameController = TextEditingController();
  final genericNameController = TextEditingController();
  final strengthController = TextEditingController();
  final stripQuantityController = TextEditingController();
  final quantityController = TextEditingController();
  final purchasePriceController = TextEditingController();
  final sellingPriceController = TextEditingController();
  final manufacturerNameController = TextEditingController();
  final importerNameController = TextEditingController();
  final importerAddressController = TextEditingController();
  final importerPhoneController = TextEditingController();
  final sellerNameController = TextEditingController();
  final sellerPhoneController = TextEditingController();
  final batchNumberController = TextEditingController();
  final alertThresholdController = TextEditingController();
  final locationController = TextEditingController();
  
  // Form keys
  final formKey = GlobalKey<FormState>();
  
  // Date selection
  final Rx<DateTime?> manufacturingDate = Rx<DateTime?>(null);
  final Rx<DateTime?> expiryDate = Rx<DateTime?>(null);
  
  // Image selection
  final Rx<String?> selectedImagePath = Rx<String?>(null);
  
  // Dropdown selected values
  final RxString selectedType = 'tablet'.obs;
  
  // Getters for view model properties
  RxList<MedicineModel> get medicines => _viewModel.medicines;
  RxList<MedicineModel> get filteredMedicines => _viewModel.filteredMedicines;
  RxList<MedicineModel> get lowStockMedicines => _viewModel.lowStockMedicines;
  RxList<MedicineModel> get expiringMedicines => _viewModel.expiringMedicines;
  RxBool get isLoading => _viewModel.isLoading;
  RxBool get isSearching => _viewModel.isSearching;
  RxString get searchQuery => _viewModel.searchQuery;
  RxString get selectedFilter => _viewModel.selectedFilter;
  RxString get selectedSortBy => _viewModel.selectedSortBy;
  RxBool get isSortAscending => _viewModel.isSortAscending;
  Rx<MedicineModel?> get selectedMedicine => _viewModel.selectedMedicine;

  // List of medicine types for dropdown
  final List<String> medicineTypes = [
    'tablet',
    'capsule',
    'syrup',
    'injection',
    'cream',
    'ointment',
    'lotion',
    'suspension',
    'drops',
    'powder',
    'inhaler',
    'spray',
    'suppository',
    'patch',
    'gel',
    'solution',
  ];
  
  InventoryController({required InventoryViewModel viewModel})
      : _viewModel = viewModel;

  @override
  void onInit() {
    super.onInit();
    // Set default values
    manufacturingDate.value = DateTime.now().subtract(const Duration(days: 30));
    expiryDate.value = DateTime.now().add(const Duration(days: 365));
    alertThresholdController.text = '10';
  }

  @override
  void onClose() {
    // Dispose text controllers
    nameController.dispose();
    genericNameController.dispose();
    strengthController.dispose();
    stripQuantityController.dispose();
    quantityController.dispose();
    purchasePriceController.dispose();
    sellingPriceController.dispose();
    manufacturerNameController.dispose();
    importerNameController.dispose();
    importerAddressController.dispose();
    importerPhoneController.dispose();
    sellerNameController.dispose();
    sellerPhoneController.dispose();
    batchNumberController.dispose();
    alertThresholdController.dispose();
    locationController.dispose();
    super.onClose();
  }
  
  // Delegate methods to view model
  Future<void> fetchAllMedicines() => _viewModel.fetchAllMedicines();
  Future<void> fetchLowStockMedicines() => _viewModel.fetchLowStockMedicines();
  Future<void> fetchExpiringMedicines({int daysThreshold = 30}) => _viewModel.fetchExpiringMedicines(daysThreshold: daysThreshold);
  Future<void> searchMedicines(String query) => _viewModel.searchMedicines(query);
  void filterMedicines() => _viewModel.filterMedicines();
  void sortMedicines() => _viewModel.sortMedicines();
  void toggleSortOrder() => _viewModel.toggleSortOrder();
  void setFilter(String filter) => _viewModel.setFilter(filter);
  void setSortBy(String sortBy) => _viewModel.setSortBy(sortBy);
  Future<void> getMedicineDetails(String id) => _viewModel.getMedicineDetails(id);
  
  // Navigate to add medicine screen
  void goToAddMedicine() {
    // Clear form fields
    clearForm();
    Get.toNamed(Routes.ADD_MEDICINE);
  }

  // Navigate to medicine details screen
  void goToMedicineDetails(String id) async {
    await getMedicineDetails(id);
    Get.toNamed(Routes.MEDICINE_DETAILS);
  }

  // Navigate to low stock alert screen
  void goToLowStockAlert() {
    Get.toNamed(Routes.LOW_STOCK_ALERT);
  }

  // Pick image from gallery
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      // Save the image to app directory
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = '${const Uuid().v4()}.jpg';
      final savedImage = File('${appDir.path}/$fileName');
      
      await File(pickedFile.path).copy(savedImage.path);
      selectedImagePath.value = savedImage.path;
    }
  }

  // Select manufacturing date
  Future<void> selectManufacturingDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: manufacturingDate.value ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != manufacturingDate.value) {
      manufacturingDate.value = picked;
    }
  }

  // Select expiry date
  Future<void> selectExpiryDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: expiryDate.value ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    
    if (picked != null && picked != expiryDate.value) {
      expiryDate.value = picked;
    }
  }

  // Clear form fields
  void clearForm() {
    nameController.clear();
    genericNameController.clear();
    strengthController.clear();
    stripQuantityController.clear();
    quantityController.clear();
    purchasePriceController.clear();
    sellingPriceController.clear();
    manufacturerNameController.clear();
    importerNameController.clear();
    importerAddressController.clear();
    importerPhoneController.clear();
    sellerNameController.clear();
    sellerPhoneController.clear();
    batchNumberController.clear();
    alertThresholdController.text = '10';
    locationController.clear();
    selectedType.value = 'tablet';
    manufacturingDate.value = DateTime.now().subtract(const Duration(days: 30));
    expiryDate.value = DateTime.now().add(const Duration(days: 365));
    selectedImagePath.value = null;
  }

  // Populate form for editing
  void populateFormForEdit(MedicineModel medicine) {
    nameController.text = medicine.name;
    genericNameController.text = medicine.genericName;
    strengthController.text = medicine.strength;
    stripQuantityController.text = medicine.stripQuantity.toString();
    quantityController.text = medicine.quantity.toString();
    purchasePriceController.text = medicine.purchasePrice.toString();
    sellingPriceController.text = medicine.sellingPrice.toString();
    manufacturerNameController.text = medicine.manufacturerName;
    importerNameController.text = medicine.importerName ?? '';
    importerAddressController.text = medicine.importerAddress ?? '';
    importerPhoneController.text = medicine.importerPhone ?? '';
    sellerNameController.text = medicine.sellerName ?? '';
    sellerPhoneController.text = medicine.sellerPhone ?? '';
    batchNumberController.text = medicine.batchNumber ?? '';
    alertThresholdController.text = medicine.alertThreshold.toString();
    locationController.text = medicine.location ?? '';
    selectedType.value = medicine.type;
    manufacturingDate.value = medicine.manufacturingDate;
    expiryDate.value = medicine.expiryDate;
    selectedImagePath.value = medicine.image;
  }

  // Save medicine
  Future<bool> saveMedicine() async {
    if (!formKey.currentState!.validate()) {
      return false;
    }
    
    if (manufacturingDate.value == null || expiryDate.value == null) {
      Get.snackbar('Error', 'Please select manufacturing and expiry dates');
      return false;
    }
    
    if (selectedMedicine.value == null) {
      Get.snackbar('Error', 'Medicine not found');
      return false;
    }
    
    try {
      final medicine = selectedMedicine.value!.copyWith(
        name: nameController.text.trim(),
        genericName: genericNameController.text.trim(),
        type: selectedType.value,
        strength: strengthController.text.trim(),
        stripQuantity: int.parse(stripQuantityController.text.trim()),
        quantity: int.parse(quantityController.text.trim()),
        purchasePrice: double.parse(purchasePriceController.text.trim()),
        sellingPrice: double.parse(sellingPriceController.text.trim()),
        image: selectedImagePath.value,
        manufacturingDate: manufacturingDate.value!,
        expiryDate: expiryDate.value!,
        manufacturerName: manufacturerNameController.text.trim(),
        importerName: importerNameController.text.trim().isNotEmpty ? importerNameController.text.trim() : null,
        importerAddress: importerAddressController.text.trim().isNotEmpty ? importerAddressController.text.trim() : null,
        importerPhone: importerPhoneController.text.trim().isNotEmpty ? importerPhoneController.text.trim() : null,
        sellerName: sellerNameController.text.trim().isNotEmpty ? sellerNameController.text.trim() : null,
        sellerPhone: sellerPhoneController.text.trim().isNotEmpty ? sellerPhoneController.text.trim() : null,
        updatedDate: DateTime.now(),
        batchNumber: batchNumberController.text.trim().isNotEmpty ? batchNumberController.text.trim() : null,
        alertThreshold: int.parse(alertThresholdController.text.trim()),
        location: locationController.text.trim().isNotEmpty ? locationController.text.trim() : null,
      );
      
      final result = await _viewModel.updateMedicine(medicine);
      if (result) {
        Get.back();
      }
      return result;
    } catch (e) {
      Get.snackbar('Error', 'Failed to update medicine: ${e.toString()}');
      return false;
    }
  }
  
  // Delete medicine
  Future<bool> deleteMedicineData(String id) async {
    try {
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this medicine? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
      
      if (confirmed == true) {
        final result = await _viewModel.deleteMedicine(id);
        if (result) {
          Get.back();
        }
        return result;
      }
      return false;
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete medicine: ${e.toString()}');
      return false;
    }
  }
  
  // Update medicine quantity
  Future<bool> updateQuantity(String id, int newQuantity) async {
    if (newQuantity < 0) {
      Get.snackbar('Error', 'Quantity cannot be negative');
      return false;
    }
    
    return await _viewModel.updateMedicineQuantity(id, newQuantity);
  }
  
  // Validate form fields
  String? validateRequired(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }
  
  String? validateNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    if (int.tryParse(value) == null) {
      return 'Please enter a valid number';
    }
    return null;
  }
  
  String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    if (double.tryParse(value) == null) {
      return 'Please enter a valid price';
    }
    return null;
  }
}

    try {
      final medicine = MedicineModel(
        id: '', // Will be generated by repository
        name: nameController.text.trim(),
        genericName: genericNameController.text.trim(),
        type: selectedType.value,
        strength: strengthController.text.trim(),
        stripQuantity: int.parse(stripQuantityController.text.trim()),
        quantity: int.parse(quantityController.text.trim()),
        purchasePrice: double.parse(purchasePriceController.text.trim()),
        sellingPrice: double.parse(sellingPriceController.text.trim()),
        image: selectedImagePath.value,
        manufacturingDate: manufacturingDate.value!,
        expiryDate: expiryDate.value!,
        manufacturerName: manufacturerNameController.text.trim(),
        importerName: importerNameController.text.trim().isNotEmpty ? importerNameController.text.trim() : null,
        importerAddress: importerAddressController.text.trim().isNotEmpty ? importerAddressController.text.trim() : null,
        importerPhone: importerPhoneController.text.trim().isNotEmpty ? importerPhoneController.text.trim() : null,
        sellerName: sellerNameController.text.trim().isNotEmpty ? sellerNameController.text.trim() : null,
        sellerPhone: sellerPhoneController.text.trim().isNotEmpty ? sellerPhoneController.text.trim() : null,
        addedDate: DateTime.now(),
        updatedDate: DateTime.now(),
        batchNumber: batchNumberController.text.trim().isNotEmpty ? batchNumberController.text.trim() : null,
        alertThreshold: int.parse(alertThresholdController.text.trim()),
        isActive: true,
        location: locationController.text.trim().isNotEmpty ? locationController.text.trim() : null,
      );
      
      final result = await _viewModel.addMedicine(medicine);
      if (result) {
        clearForm();
        Get.back();
      }
      return result;
    } catch (e) {
      Get.snackbar('Error', 'Failed to save medicine: ${e.toString()}');
      return false;
    }
  }

  // Update medicine
  Future<bool> updateMedicineData() async {
    if (!formKey.currentState!.validate()) {
      return false;
    }
    
    if (manufacturingDate.value == null || expiryDate.value == null) {
      Get.snackbar('Error', 'Please select manufacturing and expiry dates');
      return false;
    }