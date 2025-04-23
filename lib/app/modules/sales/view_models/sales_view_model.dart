// app/modules/sales/view_models/sales_view_model.dart

import 'package:get/get.dart';
import '../../../data/models/sale_model.dart';
import '../../../data/repositories/sale_repository.dart';
import '../../../data/repositories/medicine_repository.dart';
import '../../../data/repositories/customer_repository.dart';
import '../../../data/models/medicine_model.dart';
import '../../../data/models/customer_model.dart';

class SalesViewModel extends GetxController {
  final SaleRepository _saleRepository;
  final MedicineRepository _medicineRepository;
  final CustomerRepository _customerRepository;
  
  // Observable variables
  final RxList<SaleModel> sales = <SaleModel>[].obs;
  final RxList<SaleModel> filteredSales = <SaleModel>[].obs;
  final RxList<MedicineModel> medicines = <MedicineModel>[].obs;
  final RxList<MedicineModel> filteredMedicines = <MedicineModel>[].obs;
  final RxList<CustomerModel> customers = <CustomerModel>[].obs;
  final RxList<CustomerModel> filteredCustomers = <CustomerModel>[].obs;
  
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  
  // Statistics
  final RxInt totalSales = 0.obs;
  final RxDouble totalRevenue = 0.0.obs;
  final RxInt totalItems = 0.obs;
  final RxDouble averageSaleValue = 0.0.obs;
  final RxMap<String, int> paymentMethods = <String, int>{}.obs;
  
  SalesViewModel({
    required SaleRepository saleRepository,
    required MedicineRepository medicineRepository,
    required CustomerRepository customerRepository,
  }) : _saleRepository = saleRepository,
       _medicineRepository = medicineRepository,
       _customerRepository = customerRepository;

  @override
  void onInit() {
    super.onInit();
    fetchAllSales();
    fetchAllMedicines();
    fetchAllCustomers();
    
    // Listen to search query changes
    ever(searchQuery, (_) => searchSales(searchQuery.value));
  }
  
  // Fetch all sales from repository
  Future<void> fetchAllSales() async {
    try {
      isLoading.value = true;
      final result = await _saleRepository.getAllSales();
      sales.value = result;
      filteredSales.value = result;
      await updateStatistics();
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to load sales: ${e.toString()}');
    }
  }
  
  // Fetch all medicines from repository
  Future<void> fetchAllMedicines() async {
    try {
      final result = await _medicineRepository.getAllMedicines();
      medicines.value = result;
      filteredMedicines.value = result;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load medicines: ${e.toString()}');
    }
  }
  
  // Fetch all customers from repository
  Future<void> fetchAllCustomers() async {
    try {
      final result = await _customerRepository.getAllCustomers();
      customers.value = result;
      filteredCustomers.value = result;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load customers: ${e.toString()}');
    }
  }
  
  // Get active medicines
  List<MedicineModel> getActiveMedicines() {
    return medicines.where((medicine) => medicine.isActive && medicine.quantity > 0).toList();
  }
  
  // Search sales
  void searchSales(String query) {
    if (query.isNotEmpty) {
      filteredSales.value = sales.where((sale) =>
          sale.invoiceNumber.toLowerCase().contains(query.toLowerCase()) ||
          (sale.customerName != null && sale.customerName!.toLowerCase().contains(query.toLowerCase())) ||
          (sale.customerPhone != null && sale.customerPhone!.toLowerCase().contains(query.toLowerCase())) ||
          sale.employeeName.toLowerCase().contains(query.toLowerCase())
      ).toList();
    } else {
      filteredSales.value = sales;
    }
  }
  
  // Search medicines
  void searchMedicines(String query) {
    if (query.isNotEmpty) {
      filteredMedicines.value = getActiveMedicines().where((medicine) =>
          medicine.name.toLowerCase().contains(query.toLowerCase()) ||
          medicine.genericName.toLowerCase().contains(query.toLowerCase()) ||
          medicine.type.toLowerCase().contains(query.toLowerCase()) ||
          medicine.strength.toLowerCase().contains(query.toLowerCase())
      ).toList();
    } else {
      filteredMedicines.value = getActiveMedicines();
    }
  }
  
  // Search customers
  void searchCustomers(String query) {
    if (query.isNotEmpty) {
      filteredCustomers.value = customers.where((customer) =>
          customer.name.toLowerCase().contains(query.toLowerCase()) ||
          customer.phone.toLowerCase().contains(query.toLowerCase()) ||
          (customer.email?.toLowerCase().contains(query.toLowerCase()) ?? false)
      ).toList();
    } else {
      filteredCustomers.value = customers;
    }
  }
  
  // Filter sales by date range
  Future<void> filterSalesByDateRange(DateTime startDate, DateTime endDate) async {
    filteredSales.value = sales.where((sale) =>
        sale.saleDate.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
        sale.saleDate.isBefore(endDate.add(const Duration(seconds: 1)))
    ).toList();
    
    await updateStatistics(startDate: startDate, endDate: endDate);
  }
  
  // Clear all filters
  Future<void> clearFilters() async {
    filteredSales.value = sales;
    await updateStatistics();
  }
  
  // Get sale by ID
  Future<SaleModel?> getSaleById(String id) async {
    try {
      return await _saleRepository.getSaleById(id);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load sale details: ${e.toString()}');
      return null;
    }
  }
  
  // Create a new sale
  Future<bool> createSale(SaleModel sale) async {
    try {
      await _saleRepository.createSale(sale);
      
      // Update medicine stock quantities
      for (final item in sale.items) {
        await _medicineRepository.updateStock(
          item.medicineId,
          -item.quantity, // Subtract quantity
        );
      }
      
      // Update customer due amount if applicable
      if (sale.dueAmount > 0 && sale.customerId != 'walk-in') {
        await _customerRepository.updateDueAmount(
          sale.customerId,
          sale.dueAmount,
        );
      }
      
      await fetchAllSales(); // Refresh the list
      await fetchAllMedicines(); // Refresh medicine stocks
      
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to create sale: ${e.toString()}');
      return false;
    }
  }
  
  // Delete a sale
  Future<bool> deleteSale(String id) async {
    try {
      final sale = await getSaleById(id);
      
      if (sale != null) {
        // Restore medicine stock quantities
        for (final item in sale.items) {
          await _medicineRepository.updateStock(
            item.medicineId,
            item.quantity, // Add quantity back
          );
        }
        
        // Adjust customer due amount if applicable
        if (sale.dueAmount > 0 && sale.customerId != 'walk-in') {
          await _customerRepository.updateDueAmount(
            sale.customerId,
            -sale.dueAmount, // Subtract due amount
          );
        }
        
        await _saleRepository.deleteSale(id);
        await fetchAllSales(); // Refresh the list
        await fetchAllMedicines(); // Refresh medicine stocks
        
        return true;
      }
      
      return false;
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete sale: ${e.toString()}');
      return false;
    }
  }
  
  // Update statistics
  Future<void> updateStatistics({DateTime? startDate, DateTime? endDate}) async {
    try {
      final stats = await _saleRepository.getSalesStatistics(
        startDate: startDate,
        endDate: endDate,
      );
      
      totalSales.value = stats['totalSales'] as int;
      totalRevenue.value = stats['totalRevenue'] as double;
      totalItems.value = stats['totalItems'] as int;
      averageSaleValue.value = stats['averageSaleValue'] as double;
      paymentMethods.value = (stats['paymentMethods'] as Map<String, int>);
    } catch (e) {
      Get.snackbar('Error', 'Failed to update statistics: ${e.toString()}');
    }
  }
  
  // Get recent sales
  Future<List<SaleModel>> getRecentSales({int limit = 10}) async {
    try {
      return await _saleRepository.getRecentSales(limit: limit);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load recent sales: ${e.toString()}');
      return [];
    }
  }
  
  // Get sales by employee
  Future<List<SaleModel>> getSalesByEmployee(String employeeId) async {
    try {
      return await _saleRepository.getSalesByEmployee(employeeId);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load employee sales: ${e.toString()}');
      return [];
    }
  }
}