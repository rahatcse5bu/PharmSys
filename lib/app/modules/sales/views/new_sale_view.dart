// app/modules/sales/views/new_sale_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/loading_widget.dart';
import '../controllers/sales_controller.dart';
import '../../../data/models/medicine_model.dart';
import '../../../data/models/customer_model.dart';
import '../../../utils/widgets/custom_app_bar.dart';

class NewSaleView extends GetView<SalesController> {
  const NewSaleView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.initNewSale();
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'New Sale',
        showBackButton: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget();
        }
        return Column(
          children: [
            _buildSearchMedicineBar(),
            _buildMedicinesList(),
            const Divider(height: 1),
            Expanded(child: _buildCart()),
            const Divider(height: 1),
            _buildSaleSummary(context),
          ],
        );
      }),
    );
  }

  Widget _buildSearchMedicineBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: controller.searchMedicineController,
        onChanged: (value) {
          controller.salesViewModel.searchMedicines(value);
        },
        decoration: InputDecoration(
          hintText: 'Search medicines...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              controller.searchMedicineController.clear();
              controller.salesViewModel.searchMedicines('');
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildMedicinesList() {
    return Container(
      height: 140,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Obx(() {
        final medicines = controller.salesViewModel.filteredMedicines;
        if (medicines.isEmpty) {
          return const Center(child: Text('No medicines found or stock is empty'));
        }
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: medicines.length,
          itemBuilder: (context, index) {
            final medicine = medicines[index];
            return _buildMedicineCard(medicine);
          },
        );
      }),
    );
  }

  Widget _buildMedicineCard(MedicineModel medicine) {
    return InkWell(
      onTap: () => controller.addItemToCart(medicine),
      child: Card(
        margin: const EdgeInsets.only(right: 8),
        child: Container(
          width: 160,
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                medicine.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${medicine.type} | ${medicine.strength}',
                style: const TextStyle(fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$${medicine.sellingPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: medicine.stockQuantity > 10 ? Colors.green : Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Stock: ${medicine.stockQuantity}',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ElevatedButton(
                onPressed: () => controller.addItemToCart(medicine),
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(30), padding: EdgeInsets.zero),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_shopping_cart, size: 16),
                    SizedBox(width: 4),
                    Text('Add to Cart'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCart() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          color: Colors.grey.shade100,
          child: Row(
            children: [
              const Icon(Icons.shopping_cart),
              const SizedBox(width: 8),
              const Text('Cart Items', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const Spacer(),
              Obx(() => Text(
                    '${controller.cartItems.length} items',
                    style: const TextStyle(color: Colors.grey),
                  )),
            ],
          ),
        ),
        Expanded(
          child: Obx(() {
            if (controller.cartItems.isEmpty) {
              return const Center(child: Text('Cart is empty. Add medicines to proceed.'));
            }
            return ListView.builder(
              itemCount: controller.cartItems.length,
              itemBuilder: (context, index) {
                final item = controller.cartItems[index];
                return _buildCartItem(context, item, index);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCartItem(BuildContext context, dynamic item, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        title: Text(item.medicineName, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${item.medicineType} | ${item.medicineStrength}'),
            const SizedBox(height: 4),
            Row(
              children: [
                Text('Price: \$${item.unitPrice.toStringAsFixed(2)}'),
                const SizedBox(width: 8),
                if (item.discount > 0)
                  Text(
                    'Discount: \$${item.discount.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.green),
                  ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: () => controller.updateItemQuantity(index, item.quantity - 1),
            ),
            Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => controller.updateItemQuantity(index, item.quantity + 1),
            ),
            Text('\$${item.finalPrice.toStringAsFixed(2)}'),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'discount') {
                  controller.showItemDiscountDialog(index);
                } else if (value == 'remove') {
                  controller.removeItemFromCart(index);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'discount',
                  child: Row(
                    children: [
                      Icon(Icons.discount),
                      SizedBox(width: 8),
                      Text('Discount'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'remove',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Remove', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildSaleSummary(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade100,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Sale Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Obx(() => Text(
                    'Total Items: ${controller.cartItems.length}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal:'),
              Obx(() => Text('\$${controller.subtotal.value.toStringAsFixed(2)}')),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Discount:'),
              Obx(() => Text(
                    '- \$${controller.totalDiscount.value.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  )),
            ],
          ),
          if (controller.totalTax.value > 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tax:'),
                Obx(() => Text('\$${controller.totalTax.value.toStringAsFixed(2)}')),
              ],
            ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Grand Total:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Obx(() => Text(
                    '\$${controller.grandTotal.value.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue),
                  )),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: controller.cartItems.isEmpty ? null : () => _showCustomerSelectionDialog(context),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                  child: const Text('Select Customer'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: controller.cartItems.isEmpty ? null : () => _showPaymentDialog(context),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 12)),
                  child: const Text('Proceed to Payment'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Obx(() => controller.selectedCustomer.value != null
              ? Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Customer: ${controller.selectedCustomer.value!.name}',
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text('Phone: ${controller.selectedCustomer.value!.phone}'),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.blue),
                        onPressed: () => controller.selectedCustomer.value = null,
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  void _showCustomerSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(16),
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Select Customer',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back()),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                onChanged: (value) => controller.salesViewModel.searchCustomers(value),
                decoration: InputDecoration(
                  hintText: 'Search customers...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.person_add),
                label: const Text('Continue as Walk-in Customer'),
                onPressed: () {
                  controller.selectedCustomer.value = null;
                  Get.back();
                },
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              ),
              const SizedBox(height: 8),
              const Divider(),
              const Text('Customers:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Expanded(
                child: Obx(() {
                  final customers = controller.salesViewModel.filteredCustomers;
                  if (customers.isEmpty) {
                    return const Center(child: Text('No customers found'));
                  }
                  return ListView.builder(
                    itemCount: customers.length,
                    itemBuilder: (context, index) {
                      final customer = customers[index];
                      return ListTile(
                        title: Text(customer.name),
                        subtitle: Text(customer.phone),
                        trailing: customer.dueAmount > 0
                            ? Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Due: \$${customer.dueAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              )
                            : null,
                        onTap: () {
                          controller.selectCustomer(customer);
                          Get.back();
                        },
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPaymentDialog(BuildContext context) {
    controller.updatePaidAmount();
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(16),
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Complete Sale', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back()),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                margin: EdgeInsets.zero,
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Amount:'),
                          Obx(() => Text(
                                '\$${controller.grandTotal.value.toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              )),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Obx(() => controller.selectedCustomer.value != null
                          ? Row(
                              children: [
                                const Icon(Icons.person, size: 16),
                                const SizedBox(width: 8),
                                Text(controller.selectedCustomer.value!.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            )
                          : const Text('Walk-in Customer')),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Payment Method:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Obx(() => ElevatedButton(
                          onPressed: () => controller.setPaymentMethod('cash'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: controller.paymentMethod.value == 'cash'
                                ? Get.theme.primaryColor
                                : Colors.grey.shade300,
                            foregroundColor: controller.paymentMethod.value == 'cash' ? Colors.white : Colors.black,
                          ),
                          child: const Text('Cash'),
                        )),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Obx(() => ElevatedButton(
                          onPressed: () => controller.setPaymentMethod('card'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: controller.paymentMethod.value == 'card'
                                ? Get.theme.primaryColor
                                : Colors.grey.shade300,
                            foregroundColor: controller.paymentMethod.value == 'card' ? Colors.white : Colors.black,
                          ),
                          child: const Text('Card'),
                        )),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Obx(() => ElevatedButton(
                          onPressed: () => controller.setPaymentMethod('mobile'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: controller.paymentMethod.value == 'mobile'
                                ? Get.theme.primaryColor
                                : Colors.grey.shade300,
                            foregroundColor: controller.paymentMethod.value == 'mobile' ? Colors.white : Colors.black,
                          ),
                          child: const Text('Mobile'),
                        )),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Payment Status:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Obx(() => ElevatedButton(
                          onPressed: () => controller.setPaymentStatus('paid'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: controller.paymentStatus.value == 'paid'
                                ? Colors.green
                                : Colors.grey.shade300,
                            foregroundColor: controller.paymentStatus.value == 'paid' ? Colors.white : Colors.black,
                          ),
                          child: const Text('Paid'),
                        )),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Obx(() => ElevatedButton(
                          onPressed: controller.selectedCustomer.value != null
                              ? () => controller.setPaymentStatus('partial')
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: controller.paymentStatus.value == 'partial'
                                ? Colors.orange
                                : Colors.grey.shade300,
                            foregroundColor: controller.paymentStatus.value == 'partial' ? Colors.white : Colors.black,
                          ),
                          child: const Text('Partial'),
                        )),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Obx(() => ElevatedButton(
                          onPressed: controller.selectedCustomer.value != null
                              ? () => controller.setPaymentStatus('due')
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: controller.paymentStatus.value == 'due'
                                ? Colors.red
                                : Colors.grey.shade300,
                            foregroundColor: controller.paymentStatus.value == 'due' ? Colors.white : Colors.black,
                          ),
                          child: const Text('Due'),
                        )),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Obx(() => controller.paymentStatus.value == 'partial'
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Paid Amount:', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: controller.paidAmountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          onChanged: controller.updatePaidAmountFromTextField,
                          decoration: InputDecoration(
                            prefixText: '\$ ',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Due Amount:'),
                            Text(
                              '\$${controller.dueAmount.value.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                            ),
                          ],
                        ),
                      ],
                    )
                  : const SizedBox.shrink()),
              const SizedBox(height: 16),
              TextField(
                controller: controller.notesController,
                decoration: InputDecoration(
                  labelText: 'Notes (Optional)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if ((controller.paymentStatus.value == 'partial' || controller.paymentStatus.value == 'due') &&
                      controller.selectedCustomer.value == null) {
                    Get.snackbar(
                      'Error',
                      'Please select a customer for partial or due payment',
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                    return;
                  }
                  // Replace with actual logic to get current user details
                  const String employeeId = 'current-user-id';
                  const String employeeName = 'Current User';
                  final success = await controller.createSale(employeeId, employeeName);
                  if (success) {
                    Get.back(); // Close payment dialog
                    Get.back(); // Return to previous screen
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text(
                  'Complete Sale',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}