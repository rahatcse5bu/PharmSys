// app/modules/sales/views/sales_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/widgets/custom_app_bar.dart';
import '../controllers/sales_controller.dart';
import '../../../data/models/sale_model.dart';
import '../../../core/widgets/custom_drawer.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/utils/date_formatter.dart';
import 'new_sale_view.dart';

class SalesView extends GetView<SalesController> {
  const SalesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Sales',
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Get.to(() => const NewSaleView()),
          ),
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () => _showDateFilterDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refreshSales(),
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const LoadingWidget();
              }
              
              if (controller.salesViewModel.filteredSales.isEmpty) {
                return Center(
                  child: Text(
                    controller.isSearching.value
                        ? 'No sales match your search'
                        : controller.isDateFiltered.value
                            ? 'No sales found in selected date range'
                            : 'No sales recorded yet',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                );
              }
              
              return RefreshIndicator(
                onRefresh: controller.refreshSales,
                child: ListView.builder(
                  itemCount: controller.salesViewModel.filteredSales.length,
                  itemBuilder: (context, index) {
                    final sale = controller.salesViewModel.filteredSales[index];
                    return _buildSaleCard(context, sale);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        onChanged: controller.searchSales,
        decoration: InputDecoration(
          hintText: 'Search by invoice number, customer, employee...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: Obx(() => controller.isSearching.value
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => controller.searchSales(''),
                )
              : const SizedBox.shrink()),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
  
  Widget _buildFilterChips() {
    return Obx(() => controller.isDateFiltered.value
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Chip(
                  label: Text(
                    'Date: ${DateFormatter.formatDateOnly(controller.startDate.value)} - ${DateFormatter.formatDateOnly(controller.endDate.value)}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Get.theme.primaryColor,
                  deleteIcon: const Icon(Icons.close, color: Colors.white),
                  onDeleted: controller.clearDateFilter,
                ),
              ],
            ),
          )
        : const SizedBox.shrink());
  }
  
  Widget _buildSaleCard(BuildContext context, SaleModel sale) {
    final paymentStatusColor = sale.paymentStatus == 'paid'
        ? Colors.green
        : sale.paymentStatus == 'due'
            ? Colors.red
            : Colors.orange;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        title: Row(
          children: [
            Text(
              sale.invoiceNumber,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: paymentStatusColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _formatPaymentStatus(sale.paymentStatus),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 4),
                Text(DateFormatter.formatDate(sale.saleDate)),
                const SizedBox(width: 16),
                const Icon(Icons.person, size: 16),
                const SizedBox(width: 4),
                Text(sale.customerName ?? 'Walk-in Customer'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total: \${sale.total.toStringAsFixed(2)}'),
                Text('Items: ${sale.items.length}'),
                Text(_formatPaymentMethod(sale.paymentMethod)),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            switch (value) {
              case 'view':
                await controller.getSaleDetails(sale.id);
                _showSaleDetails(context, controller.selectedSale.value!);
                break;
              case 'print':
                controller.printInvoice(sale);
                break;
              case 'delete':
                await controller.deleteSale(sale.id);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility),
                  SizedBox(width: 8),
                  Text('View Details'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'print',
              child: Row(
                children: [
                  Icon(Icons.print),
                  SizedBox(width: 8),
                  Text('Print Invoice'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete Sale', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: () async {
          await controller.getSaleDetails(sale.id);
          _showSaleDetails(context, controller.selectedSale.value!);
        },
      ),
    );
  }
  
  String _formatPaymentStatus(String status) {
    switch (status) {
      case 'paid':
        return 'Paid';
      case 'due':
        return 'Due';
      case 'partial':
        return 'Partial';
      default:
        return status.capitalizeFirst!;
    }
  }
  
  String _formatPaymentMethod(String method) {
    switch (method) {
      case 'cash':
        return 'Cash';
      case 'card':
        return 'Card';
      case 'mobile':
        return 'Mobile Payment';
      default:
        return method.capitalizeFirst!;
    }
  }
  
  void _showDateFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Date'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Today'),
              leading: const Icon(Icons.today),
              onTap: () {
                final now = DateTime.now();
                final start = DateTime(now.year, now.month, now.day);
                final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
                
                controller.startDate.value = start;
                controller.endDate.value = end;
                controller.applyDateFilter();
                
                Get.back();
              },
            ),
            ListTile(
              title: const Text('Yesterday'),
              leading: const Icon(Icons.history),
              onTap: () {
                final now = DateTime.now();
                final yesterday = now.subtract(const Duration(days: 1));
                final start = DateTime(yesterday.year, yesterday.month, yesterday.day);
                final end = DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59);
                
                controller.startDate.value = start;
                controller.endDate.value = end;
                controller.applyDateFilter();
                
                Get.back();
              },
            ),
            ListTile(
              title: const Text('This Week'),
              leading: const Icon(Icons.view_week),
              onTap: () {
                final now = DateTime.now();
                final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
                final start = DateTime(firstDayOfWeek.year, firstDayOfWeek.month, firstDayOfWeek.day);
                final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
                
                controller.startDate.value = start;
                controller.endDate.value = end;
                controller.applyDateFilter();
                
                Get.back();
              },
            ),
            ListTile(
              title: const Text('This Month'),
              leading: const Icon(Icons.calendar_view_month),
              onTap: () {
                final now = DateTime.now();
                final start = DateTime(now.year, now.month, 1);
                final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
                
                controller.startDate.value = start;
                controller.endDate.value = end;
                controller.applyDateFilter();
                
                Get.back();
              },
            ),
            ListTile(
              title: const Text('Custom Range'),
              leading: const Icon(Icons.date_range),
              onTap: () {
                Get.back();
                controller.showDateRangePicker(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.clearDateFilter();
              Get.back();
            },
            child: const Text('Clear Filter'),
          ),
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
  
  void _showSaleDetails(BuildContext context, SaleModel sale) {
    Get.dialog(
      Dialog(
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Invoice: ${sale.invoiceNumber}',
                      style: Theme.of(context).textTheme.titleLarge),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailSection('Sale Information', [
                        _buildDetailItem('Date', DateFormatter.formatDate(sale.saleDate)),
                        _buildDetailItem('Employee', sale.employeeName),
                        _buildDetailItem('Customer', sale.customerName ?? 'Walk-in Customer'),
                        if (sale.customerPhone != null)
                          _buildDetailItem('Customer Phone', sale.customerPhone!),
                        _buildDetailItem('Payment Method', _formatPaymentMethod(sale.paymentMethod)),
                        _buildDetailItem('Payment Status', _formatPaymentStatus(sale.paymentStatus)),
                      ]),
                      const SizedBox(height: 16),
                      _buildDetailSection('Items', [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Table(
                            columnWidths: const {
                              0: FlexColumnWidth(4),
                              1: FlexColumnWidth(1),
                              2: FlexColumnWidth(2),
                              3: FlexColumnWidth(2),
                            },
                            border: TableBorder.all(
                              color: Colors.grey.shade300,
                              width: 1,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            children: [
                              TableRow(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    topRight: Radius.circular(8),
                                  ),
                                ),
                                children: const [
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Item', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Price', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                              ...sale.items.map((item) => TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.medicineName,
                                          style: const TextStyle(fontWeight: FontWeight.w500),
                                        ),
                                        Text(
                                          '${item.medicineType} - ${item.medicineStrength}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('${item.quantity}'),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('\${item.unitPrice.toStringAsFixed(2)}'),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('\${item.finalPrice.toStringAsFixed(2)}'),
                                  ),
                                ],
                              )).toList(),
                            ],
                          ),
                        ),
                      ]),
                      const SizedBox(height: 16),
                      _buildDetailSection('Payment Summary', [
                        _buildPaymentSummaryItem('Subtotal', '\${sale.subtotal.toStringAsFixed(2)}'),
                        if (sale.discount > 0)
                          _buildPaymentSummaryItem('Discount', '- \${sale.discount.toStringAsFixed(2)}'),
                        if (sale.tax > 0)
                          _buildPaymentSummaryItem('Tax', '\${sale.tax.toStringAsFixed(2)}'),
                        const Divider(),
                        _buildPaymentSummaryItem('Total', '\${sale.total.toStringAsFixed(2)}',
                            isBold: true),
                        _buildPaymentSummaryItem('Paid', '\${sale.paidAmount.toStringAsFixed(2)}'),
                        if (sale.dueAmount > 0)
                          _buildPaymentSummaryItem('Due', '\${sale.dueAmount.toStringAsFixed(2)}',
                              textColor: Colors.red),
                      ]),
                      if (sale.notes != null && sale.notes!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildDetailSection('Notes', [
                          Text(sale.notes!),
                        ]),
                      ],
                    ],
                  ),
                ),
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.print),
                    label: const Text('Print Invoice'),
                    onPressed: () {
                      Get.back();
                      controller.printInvoice(sale);
                    },
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }
  
  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPaymentSummaryItem(
    String label,
    String value, {
    bool isBold = false,
    Color? textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: textColor,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}