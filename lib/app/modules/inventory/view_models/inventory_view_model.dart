// app/modules/inventory/view_models/inventory_view_model.dart

import 'package:get/get.dart';
import 'package:pharma_sys/app/data/models/medicine_model.dart';
import 'package:pharma_sys/app/data/repositories/medicine_repository.dart';

class InventoryViewModel extends GetxController {
  final MedicineRepository _medicineRepository;
  
  // Observable variables
  final RxList<MedicineModel> medicines = <MedicineModel>[].obs;
  final RxList<MedicineModel> filteredMedicines = <MedicineModel>[].obs;
  final RxList<MedicineModel> lowStockMedicines = <MedicineModel>[].obs;
  final RxList<MedicineModel> expiringMedicines = <MedicineModel>[].obs;
  
  final RxBool isLoading = false.obs;
  final RxBool isSearching = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedFilter = 'All'.obs;
  final RxString selectedSortBy = 'Name'.obs;
  final RxBool isSortAscending = true.obs;

  // For medicine details
  final Rx<MedicineModel?> selectedMedicine = Rx<MedicineModel?>(null);
  
  InventoryViewModel({required MedicineRepository medicineRepository})
      : _medicineRepository = medicineRepository;

  @override
  void onInit() {
    super.onInit();
    fetchAllMedicines();
    fetchLowStockMedicines();
    fetchExpiringMedicines();
    
    // Listen to search query changes
    ever(searchQuery, (_) => filterMedicines());
    ever(selectedFilter, (_) => filterMedicines());
    ever(selectedSortBy, (_) => sortMedicines());
    ever(isSortAscending, (_) => sortMedicines());
  }

  // Fetch all medicines from repository
  Future<void> fetchAllMedicines() async {
    try {
      isLoading.value = true;
      final result = await _medicineRepository.getAllMedicines();
      medicines.value = result;
      filterMedicines();
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to load medicines: ${e.toString()}');
    }
  }

  // Fetch low stock medicines
  Future<void> fetchLowStockMedicines() async {
    try {
      final result = await _medicineRepository.getLowStockMedicines();
      lowStockMedicines.value = result;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load low stock medicines: ${e.toString()}');
    }
  }

  // Fetch expiring medicines
  Future<void> fetchExpiringMedicines({int daysThreshold = 30}) async {
    try {
      final result = await _medicineRepository.getExpiringMedicines(daysThreshold: daysThreshold);
      expiringMedicines.value = result;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load expiring medicines: ${e.toString()}');
    }
  }
  
  // Search medicines
  Future<void> searchMedicines(String query) async {
    searchQuery.value = query;
    if (query.isEmpty) {
      isSearching.value = false;
      filterMedicines();
      return;
    }
    
    try {
      isSearching.value = true;
      final result = await _medicineRepository.searchMedicines(query);
      filteredMedicines.value = result;
    } catch (e) {
      Get.snackbar('Error', 'Search failed: ${e.toString()}');
    } finally {
      isSearching.value = false;
    }
  }
  
  // Filter medicines based on selected filter
  void filterMedicines() {
    if (searchQuery.isNotEmpty) {
      filteredMedicines.value = medicines.where((medicine) =>
          medicine.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          medicine.genericName.toLowerCase().contains(searchQuery.toLowerCase()) ||
          medicine.manufacturerName.toLowerCase().contains(searchQuery.toLowerCase())
      ).toList();
    } else {
      switch (selectedFilter.value) {
        case 'All':
          filteredMedicines.value = medicines;
          break;
        case 'Tablets':
          filteredMedicines.value = medicines.where((medicine) => medicine.type == 'tablet').toList();
          break;
        case 'Capsules':
          filteredMedicines.value = medicines.where((medicine) => medicine.type == 'capsule').toList();
          break;
        case 'Syrups':
          filteredMedicines.value = medicines.where((medicine) => medicine.type == 'syrup').toList();
          break;
        case 'Injections':
          filteredMedicines.value = medicines.where((medicine) => medicine.type == 'injection').toList();
          break;
        case 'Low Stock':
          filteredMedicines.value = lowStockMedicines;
          break;
        case 'Expiring Soon':
          filteredMedicines.value = expiringMedicines;
          break;
        default:
          filteredMedicines.value = medicines;
      }
    }
    
    sortMedicines();
  }
  
  // Sort medicines based on selected sort by option
  void sortMedicines() {
    switch (selectedSortBy.value) {
      case 'Name':
        if (isSortAscending.value) {
          filteredMedicines.sort((a, b) => a.name.compareTo(b.name));
        } else {
          filteredMedicines.sort((a, b) => b.name.compareTo(a.name));
        }
        break;
      case 'Generic Name':
        if (isSortAscending.value) {
          filteredMedicines.sort((a, b) => a.genericName.compareTo(b.genericName));
        } else {
          filteredMedicines.sort((a, b) => b.genericName.compareTo(a.genericName));
        }
        break;
      case 'Expiry Date':
        if (isSortAscending.value) {
          filteredMedicines.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
        } else {
          filteredMedicines.sort((a, b) => b.expiryDate.compareTo(a.expiryDate));
        }
        break;
      case 'Stock':
        if (isSortAscending.value) {
          filteredMedicines.sort((a, b) => a.quantity.compareTo(b.quantity));
        } else {
          filteredMedicines.sort((a, b) => b.quantity.compareTo(a.quantity));
        }
        break;
      case 'Price':
        if (isSortAscending.value) {
          filteredMedicines.sort((a, b) => a.sellingPrice.compareTo(b.sellingPrice));
        } else {
          filteredMedicines.sort((a, b) => b.sellingPrice.compareTo(a.sellingPrice));
        }
        break;
    }
  }
  
  // Toggle sort order
  void toggleSortOrder() {
    isSortAscending.value = !isSortAscending.value;
  }
  
  // Set selected filter
  void setFilter(String filter) {
    selectedFilter.value = filter;
  }
  
  // Set selected sort by option
  void setSortBy(String sortBy) {
    selectedSortBy.value = sortBy;
  }
  
  // Get medicine details
  Future<void> getMedicineDetails(String id) async {
    try {
      isLoading.value = true;
      final medicine = await _medicineRepository.getMedicineById(id);
      selectedMedicine.value = medicine;
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to load medicine details: ${e.toString()}');
    }
  }
  
  // Add new medicine
  Future<bool> addMedicine(MedicineModel medicine) async {
    try {
      isLoading.value = true;
      final id = await _medicineRepository.insertMedicine(medicine);
      await fetchAllMedicines(); // Refresh the list
      isLoading.value = false;
      Get.snackbar('Success', 'Medicine added successfully');
      return true;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to add medicine: ${e.toString()}');
      return false;
    }
  }
  
  // Update medicine
  Future<bool> updateMedicine(MedicineModel medicine) async {
    try {
      isLoading.value = true;
      await _medicineRepository.updateMedicine(medicine);
      await fetchAllMedicines(); // Refresh the list
      isLoading.value = false;
      Get.snackbar('Success', 'Medicine updated successfully');
      return true;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to update medicine: ${e.toString()}');
      return false;
    }
  }
  
  // Delete medicine
  Future<bool> deleteMedicine(String id) async {
    try {
      isLoading.value = true;
      await _medicineRepository.deleteMedicine(id);
      await fetchAllMedicines(); // Refresh the list
      isLoading.value = false;
      Get.snackbar('Success', 'Medicine deleted successfully');
      return true;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to delete medicine: ${e.toString()}');
      return false;
    }
  }
  
  // Update medicine quantity
  Future<bool> updateMedicineQuantity(String id, int newQuantity) async {
    try {
      await _medicineRepository.updateMedicineQuantity(id, newQuantity);
      await fetchAllMedicines(); // Refresh the list
      await fetchLowStockMedicines(); // Refresh low stock medicines
      Get.snackbar('Success', 'Quantity updated successfully');
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to update quantity: ${e.toString()}');
      return false;
    }
  }
}