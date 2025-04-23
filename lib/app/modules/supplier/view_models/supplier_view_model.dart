// app/modules/suppliers/view_models/supplier_view_model.dart

import 'package:get/get.dart';
import '../../../data/models/supplier_model.dart';
import '../../../data/repositories/supplier_repository.dart';

class SupplierViewModel extends GetxController {
  final SupplierRepository _supplierRepository;
  
  // Observable variables
  final RxList<SupplierModel> suppliers = <SupplierModel>[].obs;
  final RxList<SupplierModel> filteredSuppliers = <SupplierModel>[].obs;
  final RxList<SupplierModel> activeSuppliers = <SupplierModel>[].obs;
  
  final RxBool isLoading = false.obs;
  final RxBool isSearching = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedFilter = 'All'.obs;
  final RxString selectedSortBy = 'Name'.obs;
  final RxBool isSortAscending = true.obs;

  // For supplier details
  final Rx<SupplierModel?> selectedSupplier = Rx<SupplierModel?>(null);
  
  SupplierViewModel({required SupplierRepository supplierRepository})
      : _supplierRepository = supplierRepository;

  @override
  void onInit() {
    super.onInit();
    fetchAllSuppliers();
    
    // Listen to search query changes
    ever(searchQuery, (_) => filterSuppliers());
    ever(selectedFilter, (_) => filterSuppliers());
    ever(selectedSortBy, (_) => sortSuppliers());
    ever(isSortAscending, (_) => sortSuppliers());
  }

  // Fetch all suppliers from repository
  Future<void> fetchAllSuppliers() async {
    try {
      isLoading.value = true;
      final result = await _supplierRepository.getAllSuppliers();
      suppliers.value = result;
      filteredSuppliers.value = result;
      
      // Get active suppliers
      activeSuppliers.value = result.where((supplier) => supplier.isActive).toList();
      
      sortSuppliers();
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to load suppliers: ${e.toString()}');
    }
  }
  
  // Search suppliers
  void searchSuppliers(String query) {
    searchQuery.value = query;
    isSearching.value = query.isNotEmpty;
    filterSuppliers();
  }
  
  // Filter suppliers based on selected filter
  void filterSuppliers() {
    if (searchQuery.isNotEmpty) {
      filteredSuppliers.value = suppliers.where((supplier) =>
          supplier.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          (supplier.email != null && supplier.email!.toLowerCase().contains(searchQuery.toLowerCase())) ||
          supplier.phone.toLowerCase().contains(searchQuery.toLowerCase()) ||
          (supplier.contactPersonName != null && supplier.contactPersonName!.toLowerCase().contains(searchQuery.toLowerCase()))
      ).toList();
    } else {
      switch (selectedFilter.value) {
        case 'All':
          filteredSuppliers.value = suppliers;
          break;
        case 'Active':
          filteredSuppliers.value = suppliers.where((supplier) => supplier.isActive).toList();
          break;
        case 'Inactive':
          filteredSuppliers.value = suppliers.where((supplier) => !supplier.isActive).toList();
          break;
        case 'Has Due':
          filteredSuppliers.value = suppliers.where((supplier) => supplier.dueAmount > 0).toList();
          break;
        default:
          filteredSuppliers.value = suppliers;
      }
    }
    
    sortSuppliers();
  }
  
  // Sort suppliers based on selected sort by option
  void sortSuppliers() {
    switch (selectedSortBy.value) {
      case 'Name':
        if (isSortAscending.value) {
          filteredSuppliers.sort((a, b) => a.name.compareTo(b.name));
        } else {
          filteredSuppliers.sort((a, b) => b.name.compareTo(a.name));
        }
        break;
      case 'Total Purchase':
        if (isSortAscending.value) {
          filteredSuppliers.sort((a, b) => a.totalPurchase.compareTo(b.totalPurchase));
        } else {
          filteredSuppliers.sort((a, b) => b.totalPurchase.compareTo(a.totalPurchase));
        }
        break;
      case 'Due Amount':
        if (isSortAscending.value) {
          filteredSuppliers.sort((a, b) => a.dueAmount.compareTo(b.dueAmount));
        } else {
          filteredSuppliers.sort((a, b) => b.dueAmount.compareTo(a.dueAmount));
        }
        break;
      case 'Date Added':
        if (isSortAscending.value) {
          filteredSuppliers.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        } else {
          filteredSuppliers.sort((a, b) => b.createdAt.compareTo(a.createdAt));
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
  
  // Get supplier details
  Future<void> getSupplierDetails(String id) async {
    try {
      isLoading.value = true;
      final supplier = await _supplierRepository.getSupplierById(id);
      selectedSupplier.value = supplier;
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to load supplier details: ${e.toString()}');
    }
  }
  
  // Add new supplier
  Future<bool> addSupplier(SupplierModel supplier) async {
    try {
      isLoading.value = true;
      final id = await _supplierRepository.addSupplier(supplier);
      await fetchAllSuppliers(); // Refresh the list
      isLoading.value = false;
      Get.snackbar('Success', 'Supplier added successfully');
      return true;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to add supplier: ${e.toString()}');
      return false;
    }
  }
  
  // Update supplier
  Future<bool> updateSupplier(SupplierModel supplier) async {
    try {
      isLoading.value = true;
      await _supplierRepository.updateSupplier(supplier);
      await fetchAllSuppliers(); // Refresh the list
      isLoading.value = false;
      Get.snackbar('Success', 'Supplier updated successfully');
      return true;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to update supplier: ${e.toString()}');
      return false;
    }
  }
  
  // Delete supplier
  Future<bool> deleteSupplier(String id) async {
    try {
      isLoading.value = true;
      await _supplierRepository.deleteSupplier(id);
      await fetchAllSuppliers(); // Refresh the list
      isLoading.value = false;
      Get.snackbar('Success', 'Supplier deleted successfully');
      return true;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to delete supplier: ${e.toString()}');
      return false;
    }
  }
  
  // Update supplier status
  Future<bool> updateSupplierStatus(String id, bool isActive) async {
    try {
      isLoading.value = true;
      await _supplierRepository.updateSupplierStatus(id, isActive);
      await fetchAllSuppliers(); // Refresh the list
      isLoading.value = false;
      Get.snackbar(
        'Success', 
        'Supplier ${isActive ? 'activated' : 'deactivated'} successfully'
      );
      return true;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to update supplier status: ${e.toString()}');
      return false;
    }
  }
  
  // Pay due amount
  Future<bool> payDue(String id, double amount) async {
    try {
      isLoading.value = true;
      await _supplierRepository.payDue(id, amount);
      await fetchAllSuppliers(); // Refresh the list
      isLoading.value = false;
      Get.snackbar('Success', 'Due payment recorded successfully');
      return true;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to record payment: ${e.toString()}');
      return false;
    }
  }
  
  // Update due amount
  Future<bool> updateDueAmount(String id, double amount) async {
    try {
      isLoading.value = true;
      await _supplierRepository.updateDueAmount(id, amount);
      await fetchAllSuppliers(); // Refresh the list
      isLoading.value = false;
      Get.snackbar('Success', 'Due amount updated successfully');
      return true;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to update due amount: ${e.toString()}');
      return false;
    }
  }
  
  // Get total due amount
  double getTotalDueAmount() {
    return suppliers.fold(0.0, (sum, supplier) => sum + supplier.dueAmount);
  }
}