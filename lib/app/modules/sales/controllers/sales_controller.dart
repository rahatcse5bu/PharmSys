// app/modules/sales/controllers/sales_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/customer_model.dart';
import '../view_models/sales_view_model.dart';
import '../../../data/models/sale_model.dart';
import '../../../data/models/medicine_model.dart';

class SalesController extends GetxController {
  final SalesViewModel salesViewModel;

  // Observable variables
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxBool isSearching = false.obs;

  // Date filter
  final Rx<DateTime> startDate = DateTime.now().subtract(const Duration(days: 30)).obs;
  final Rx<DateTime> endDate = DateTime.now().obs;
  final RxBool isDateFiltered = false.obs;

  // For new sale
  final RxList<SaleItemModel> cartItems = <SaleItemModel>[].obs;
  final RxDouble subtotal = 0.0.obs;
  final RxDouble totalDiscount = 0.0.obs;
  final RxDouble totalTax = 0.0.obs;
  final RxDouble grandTotal = 0.0.obs;

  final Rx<CustomerModel?> selectedCustomer = Rx<CustomerModel?>(null);
  final RxString paymentMethod = 'cash'.obs;
  final RxString paymentStatus = 'paid'.obs;
  final RxDouble paidAmount = 0.0.obs;
  final RxDouble dueAmount = 0.0.obs;

  // Form controllers
  final notesController = TextEditingController();
  final searchMedicineController = TextEditingController();
  final quantityController = TextEditingController();
  final discountController = TextEditingController();
  final paidAmountController = TextEditingController();

  // For invoice details
  final Rx<SaleModel?> selectedSale = Rx<SaleModel?>(null);

  // Form keys
  final formKey = GlobalKey<FormState>();

  SalesController({required this.salesViewModel});

  @override
  void onInit() {
    super.onInit();
    fetchSales();

    // Listeners
    ever(searchQuery, (_) => searchSales(searchQuery.value));
    ever(startDate, (_) => applyDateFilter());
    ever(endDate, (_) => applyDateFilter());
    ever(cartItems, (_) => calculateTotals());
    ever(paidAmount, (_) => calculateDueAmount());
    ever(paymentStatus, (_) => updatePaidAmount());
  }

  @override
  void onClose() {
    notesController.dispose();
    searchMedicineController.dispose();
    quantityController.dispose();
    discountController.dispose();
    paidAmountController.dispose();
    super.onClose();
  }

  // Fetch all sales
  Future<void> fetchSales() async {
    isLoading.value = true;
    await salesViewModel.fetchAllSales();
    isLoading.value = false;
  }

  // Search sales
  void searchSales(String query) {
    searchQuery.value = query;
    isSearching.value = query.isNotEmpty;
    salesViewModel.searchSales(query);
  }

  // Apply date filter
  void applyDateFilter() {
    isDateFiltered.value = true;
    salesViewModel.filterSalesByDateRange(startDate.value, endDate.value);
  }

  // Clear date filter
  void clearDateFilter() {
    isDateFiltered.value = false;
    salesViewModel.clearFilters();
  }

  // Show date range picker
  Future<void> showDateRangePicker(BuildContext context) async {
    final initialDateRange = DateTimeRange(
      start: startDate.value,
      end: endDate.value,
    );

    final pickedDateRange = await showDatePicker(
      context: context,
      initialDate: initialDateRange.start,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (pickedDateRange != null) {
      startDate.value = pickedDateRange;
      // Set end date to the end of the day
      endDate.value = DateTime(
        pickedDateRange.year,
        pickedDateRange.month,
        pickedDateRange.day,
        23, 59, 59,
      );
      applyDateFilter();
    }
  }

  // Refresh sales
  Future<void> refreshSales() async {
    await fetchSales();
    if (isDateFiltered.value) {
      applyDateFilter();
    }
  }

  // Get sale details
  Future<void> getSaleDetails(String id) async {
    isLoading.value = true;
    final sale = await salesViewModel.getSaleById(id);
    selectedSale.value = sale;
    isLoading.value = false;
  }

  // New Sale Functions

  // Initialize new sale
  void initNewSale() {
    cartItems.clear();
    selectedCustomer.value = null;
    paymentMethod.value = 'cash';
    paymentStatus.value = 'paid';
    paidAmount.value = 0.0;
    dueAmount.value = 0.0;
    notesController.clear();

    calculateTotals();
  }

  // Add item to cart
  void addItemToCart(MedicineModel medicine) {
    // Check if medicine already in cart
    final existingItemIndex = cartItems.indexWhere(
      (item) => item.medicineId == medicine.id,
    );

    if (existingItemIndex >= 0) {
      // Update quantity for existing item
      final existingItem = cartItems[existingItemIndex];
      final newQuantity = existingItem.quantity + 1;

      cartItems[existingItemIndex] = SaleItemModel(
        medicineId: existingItem.medicineId,
        medicineName: existingItem.medicineName,
        medicineType: existingItem.medicineType,
        medicineStrength: existingItem.medicineStrength,
        unitPrice: existingItem.unitPrice,
        quantity: newQuantity,
        totalPrice: existingItem.unitPrice * newQuantity,
        discount: existingItem.discount,
        finalPrice: (existingItem.unitPrice * newQuantity) - existingItem.discount,
      );
    } else {
      // Add new item to cart
      cartItems.add(SaleItemModel(
        medicineId: medicine.id,
        medicineName: medicine.name,
        medicineType: medicine.type,
        medicineStrength: medicine.strength,
        unitPrice: medicine.sellingPrice,
        quantity: 1,
        totalPrice: medicine.sellingPrice,
        discount: 0.0,
        finalPrice: medicine.sellingPrice,
      ));
    }

    calculateTotals();
  }

  // Update item quantity
  void updateItemQuantity(int index, int quantity) {
    if (quantity <= 0) {
      cartItems.removeAt(index);
    } else {
      final item = cartItems[index];
      cartItems[index] = SaleItemModel(
        medicineId: item.medicineId,
        medicineName: item.medicineName,
        medicineType: item.medicineType,
        medicineStrength: item.medicineStrength,
        unitPrice: item.unitPrice,
        quantity: quantity,
        totalPrice: item.unitPrice * quantity,
        discount: item.discount,
        finalPrice: (item.unitPrice * quantity) - item.discount,
      );
    }

    calculateTotals();
  }

  // Update item discount
  void updateItemDiscount(int index, double discount) {
    final item = cartItems[index];
    final totalPrice = item.unitPrice * item.quantity;

    // Ensure discount doesn't exceed total price
    final finalDiscount = discount > totalPrice ? totalPrice : discount;

    cartItems[index] = SaleItemModel(
      medicineId: item.medicineId,
      medicineName: item.medicineName,
      medicineType: item.medicineType,
      medicineStrength: item.medicineStrength,
      unitPrice: item.unitPrice,
      quantity: item.quantity,
      totalPrice: totalPrice,
      discount: finalDiscount,
      finalPrice: totalPrice - finalDiscount,
    );

    calculateTotals();
  }

  // Remove item from cart
  void removeItemFromCart(int index) {
    cartItems.removeAt(index);
    calculateTotals();
  }

  // Calculate totals
  void calculateTotals() {
    subtotal.value = cartItems.fold(
      0.0,
      (sum, item) => sum + item.totalPrice,
    );

    totalDiscount.value = cartItems.fold(
      0.0,
      (sum, item) => sum + item.discount,
    );

    // Assuming tax is calculated after discount
    totalTax.value = 0.0; // Set your tax calculation logic here if needed

    grandTotal.value = subtotal.value - totalDiscount.value + totalTax.value;

    // Update due amount
    calculateDueAmount();
  }

  // Set payment method
  void setPaymentMethod(String method) {
    paymentMethod.value = method;
  }

  // Set payment status
  void setPaymentStatus(String status) {
    paymentStatus.value = status;
    updatePaidAmount();
  }

  // Update paid amount based on payment status
  void updatePaidAmount() {
    switch (paymentStatus.value) {
      case 'paid':
        paidAmount.value = grandTotal.value;
        paidAmountController.text = grandTotal.value.toStringAsFixed(2);
        break;
      case 'due':
        paidAmount.value = 0.0;
        paidAmountController.text = '0.00';
        break;
      case 'partial':
        // Keep existing paid amount or set to 0 if it's more than grand total
        if (paidAmount.value > grandTotal.value) {
          paidAmount.value = grandTotal.value;
          paidAmountController.text = grandTotal.value.toStringAsFixed(2);
        } else if (paidAmount.value == 0.0) {
          paidAmountController.text = '0.00';
        } else {
          paidAmountController.text = paidAmount.value.toStringAsFixed(2);
        }
        break;
    }

    calculateDueAmount();
  }

  // Update paid amount from text field
  void updatePaidAmountFromTextField(String value) {
    final amount = double.tryParse(value) ?? 0.0;

    // Ensure paid amount doesn't exceed grand total
    paidAmount.value = amount > grandTotal.value ? grandTotal.value : amount;

    // Adjust payment status based on paid amount
    if (paidAmount.value >= grandTotal.value) {
      paymentStatus.value = 'paid';
      paidAmount.value = grandTotal.value;
    } else if (paidAmount.value > 0) {
      paymentStatus.value = 'partial';
    } else {
      paymentStatus.value = 'due';
    }

    calculateDueAmount();
  }

  // Calculate due amount
  void calculateDueAmount() {
    dueAmount.value = grandTotal.value - paidAmount.value;
  }

  // Select customer
  void selectCustomer(CustomerModel customer) {
    selectedCustomer.value = customer;
    update(); // trigger UI update
  }

  // Create new sale
  Future<bool> createSale(String employeeId, String employeeName) async {
    if (cartItems.isEmpty) {
      Get.snackbar('Error', 'Please add items to the cart');
      return false;
    }

    if (paymentStatus.value != 'paid' && selectedCustomer.value == null) {
      Get.snackbar('Error', 'Please select a customer for due/partial payment');
      return false;
    }

    final sale = SaleModel(
      id: '', // Will be generated in repository
      invoiceNumber: '', // Will be generated in repository
      saleDate: DateTime.now(),
      customerId: selectedCustomer.value?.id ?? 'walk-in',
      customerName: selectedCustomer.value?.name,
      customerPhone: selectedCustomer.value?.phone,
      employeeId: employeeId,
      employeeName: employeeName,
      items: cartItems.toList(),
      subtotal: subtotal.value,
      discount: totalDiscount.value,
      tax: totalTax.value,
      total: grandTotal.value,
      paymentMethod: paymentMethod.value,
      paymentStatus: paymentStatus.value,
      paidAmount: paidAmount.value,
      dueAmount: dueAmount.value,
      notes: notesController.text.isEmpty ? null : notesController.text,
    );

    isLoading.value = true;
    final success = await salesViewModel.createSale(sale);

    if (success) {
      Get.snackbar('Success', 'Sale completed successfully');
      initNewSale();
    } else {
      Get.snackbar('Error', 'Failed to complete sale');
    }

    isLoading.value = false;
    return success;
  }

  // Delete sale
  Future<bool> deleteSale(String id) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Sale'),
        content: const Text('Are you sure you want to delete this sale? This action cannot be undone.'),
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
    ) ?? false;

    if (confirmed) {
      isLoading.value = true;
      final success = await salesViewModel.deleteSale(id);

      if (success) {
        Get.snackbar('Success', 'Sale deleted successfully');
        await fetchSales();
      } else {
        Get.snackbar('Error', 'Failed to delete sale');
      }

      isLoading.value = false;
      return success;
    }

    return false;
  }

  // Print invoice
  void printInvoice(SaleModel sale) {
    // Implement invoice printing functionality
    Get.snackbar('Info', 'Printing invoice...');
  }

  // Show item quantity dialog
  Future<void> showItemQuantityDialog(int index) async {
    final item = cartItems[index];
    quantityController.text = item.quantity.toString();

    await Get.dialog(
      AlertDialog(
        title: const Text('Update Quantity'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${item.medicineName} (${item.medicineStrength})'),
            const SizedBox(height: 16),
            TextFormField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final quantity = int.tryParse(quantityController.text) ?? 0;
              updateItemQuantity(index, quantity);
              Get.back();
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  // Show item discount dialog
  Future<void> showItemDiscountDialog(int index) async {
    final item = cartItems[index];
    discountController.text = item.discount.toStringAsFixed(2);

    await Get.dialog(
      AlertDialog(
        title: const Text('Apply Discount'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${item.medicineName} (${item.medicineStrength})'),
            const SizedBox(height: 8),
            Text('Price: \$${item.totalPrice.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            TextFormField(
              controller: discountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Discount Amount',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final discount = double.tryParse(discountController.text) ?? 0.0;
              updateItemDiscount(index, discount);
              Get.back();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}