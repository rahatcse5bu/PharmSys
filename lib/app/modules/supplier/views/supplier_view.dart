// app/modules/suppliers/views/suppliers_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/widgets/custom_app_bar.dart';
import '../controllers/supplier_controller.dart';
import '../../../data/models/supplier_model.dart';
import '../../../core/widgets/custom_drawer.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/utils/date_formatter.dart';

class SuppliersView extends GetView<SupplierController> {
  const SuppliersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Suppliers',
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddEditSupplierForm(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refreshSuppliers(),
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: Column(
        children: [
          _buildSearchFilterBar(),
          Expanded(
            child: Obx(() {
              if (controller.supplierViewModel.isLoading.value) {
                return const LoadingWidget();
              }

              if (controller.supplierViewModel.filteredSuppliers.isEmpty) {
                return Center(
                  child: Text(
                    controller.supplierViewModel.searchQuery.isEmpty
                        ? 'No suppliers found'
                        : 'No suppliers match your search',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.refreshSuppliers,
                child: ListView.builder(
                  itemCount: controller.supplierViewModel.filteredSuppliers.length,
                  itemBuilder: (context, index) {
                    final supplier = controller.supplierViewModel.filteredSuppliers[index];
                    return _buildSupplierCard(context, supplier);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchFilterBar() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Get.theme.primaryColor.withOpacity(0.1),
      child: Column(
        children: [
          TextField(
            onChanged: controller.searchSuppliers,
            decoration: InputDecoration(
              hintText: 'Search suppliers...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: Obx(() => controller.supplierViewModel.searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => controller.searchSuppliers(''),
                    )
                  : const SizedBox.shrink()),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Obx(() {
                  return DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Filter',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    value: controller.supplierViewModel.selectedFilter.value,
                    items: ['All', 'Active', 'Inactive', 'Has Due'].map((filter) {
                      return DropdownMenuItem<String>(
                        value: filter,
                        child: Text(filter),
                      );
                    }).toList(),
                    onChanged: (value) => controller.setFilter(value!),
                  );
                }),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Obx(() {
                  return DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Sort By',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    value: controller.supplierViewModel.selectedSortBy.value,
                    items: ['Name', 'Total Purchase', 'Due Amount', 'Date Added'].map((sort) {
                      return DropdownMenuItem<String>(
                        value: sort,
                        child: Text(sort),
                      );
                    }).toList(),
                    onChanged: (value) => controller.setSortBy(value!),
                  );
                }),
              ),
              IconButton(
                icon: Obx(() => Icon(
                  controller.supplierViewModel.isSortAscending.value
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                )),
                onPressed: controller.toggleSortOrder,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSupplierCard(BuildContext context, SupplierModel supplier) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        title: Row(
          children: [
            Text(
              supplier.name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: supplier.isActive ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                supplier.isActive ? 'Active' : 'Inactive',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            if (supplier.dueAmount > 0)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Due: \$${supplier.dueAmount.toStringAsFixed(2)}',
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
                const Icon(Icons.phone, size: 16),
                const SizedBox(width: 4),
                Text(supplier.phone),
                const SizedBox(width: 16),
                if (supplier.email != null && supplier.email!.isNotEmpty) ...[
                  const Icon(Icons.email, size: 16),
                  const SizedBox(width: 4),
                  Text(supplier.email!),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Purchase: \$${supplier.totalPurchase.toStringAsFixed(2)}'),
                Text('Added: ${DateFormatter.formatDateOnly(supplier.createdAt)}'),
              ],
            ),
          ],
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            switch (value) {
              case 'view':
                await controller.supplierViewModel.getSupplierDetails(supplier.id);
                _showSupplierDetails(context, supplier);
                break;
              case 'edit':
                await controller.supplierViewModel.getSupplierDetails(supplier.id);
                _showAddEditSupplierForm(context, supplier: supplier);
                break;
              case 'toggle':
                await controller.toggleSupplierStatus(
                  supplier.id,
                  supplier.isActive,
                );
                break;
              case 'pay':
                if (supplier.dueAmount > 0) {
                  await controller.showPayDueDialog(
                    supplier.id,
                    supplier.dueAmount,
                    supplier.name,
                  );
                } else {
                  Get.snackbar('Info', 'This supplier has no due amount.');
                }
                break;
              case 'delete':
                await controller.showDeleteConfirmation(
                  supplier.id,
                  supplier.name,
                );
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
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'toggle',
              child: Row(
                children: [
                  Icon(supplier.isActive ? Icons.block : Icons.check_circle),
                  const SizedBox(width: 8),
                  Text(supplier.isActive ? 'Deactivate' : 'Activate'),
                ],
              ),
            ),
            if (supplier.dueAmount > 0)
              const PopupMenuItem(
                value: 'pay',
                child: Row(
                  children: [
                    Icon(Icons.payment),
                    SizedBox(width: 8),
                    Text('Pay Due'),
                  ],
                ),
              ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSupplierDetails(BuildContext context, SupplierModel supplier) {
    Get.dialog(
      AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Supplier Details'),
            Text(
              supplier.isActive ? 'Active' : 'Inactive',
              style: TextStyle(
                fontSize: 14,
                color: supplier.isActive ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(),
              _buildDetailRow('Name', supplier.name),
              _buildDetailRow('Address', supplier.address),
              _buildDetailRow('Phone', supplier.phone),
              if (supplier.email != null)
                _buildDetailRow('Email', supplier.email!),
              if (supplier.contactPersonName != null)
                _buildDetailRow('Contact Person', supplier.contactPersonName!),
              if (supplier.contactPersonPhone != null)
                _buildDetailRow('Contact Phone', supplier.contactPersonPhone!),
              if (supplier.website != null)
                _buildDetailRow('Website', supplier.website!),
              if (supplier.taxId != null)
                _buildDetailRow('Tax ID', supplier.taxId!),
              if (supplier.licenseNumber != null)
                _buildDetailRow('License Number', supplier.licenseNumber!),
              if (supplier.accountNumber != null)
                _buildDetailRow('Account Number', supplier.accountNumber!),
              if (supplier.bankName != null)
                _buildDetailRow('Bank Name', supplier.bankName!),
              if (supplier.bankBranch != null)
                _buildDetailRow('Bank Branch', supplier.bankBranch!),
              const Divider(),
              _buildDetailRow(
                'Total Purchase',
                '\$${supplier.totalPurchase.toStringAsFixed(2)}',
              ),
              _buildDetailRow(
                'Due Amount',
                '\$${supplier.dueAmount.toStringAsFixed(2)}',
                valueColor: supplier.dueAmount > 0 ? Colors.red : null,
              ),
              const Divider(),
              _buildDetailRow(
                'Added On',
                DateFormatter.formatDate(supplier.createdAt),
              ),
              _buildDetailRow(
                'Last Updated',
                DateFormatter.formatDate(supplier.updatedAt),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
          if (supplier.dueAmount > 0)
            TextButton(
              onPressed: () {
                Get.back();
                controller.showPayDueDialog(
                  supplier.id,
                  supplier.dueAmount,
                  supplier.name,
                );
              },
              child: const Text('Pay Due'),
            ),
          TextButton(
            onPressed: () {
              Get.back();
              _showAddEditSupplierForm(context, supplier: supplier);
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: valueColor),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddEditSupplierForm(BuildContext context, {SupplierModel? supplier}) {
    final isEditing = supplier != null;

    if (isEditing) {
      controller.initEditForm(supplier);
    } else {
      controller.initAddForm();
    }

    Get.dialog(
      Dialog(
        child: Container(
          width: double.maxFinite,
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(16),
          child: Form(
            key: controller.formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEditing ? 'Edit Supplier' : 'Add New Supplier',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    'Basic Information',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  // Basic Information
                  TextFormField(
                    controller: controller.nameController,
                    decoration: const InputDecoration(
                      labelText: 'Supplier Name*',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter supplier name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: controller.addressController,
                    decoration: const InputDecoration(
                      labelText: 'Address*',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: controller.phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number*',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: controller.emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Contact Information',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  // Contact Information
                  TextFormField(
                    controller: controller.contactPersonNameController,
                    decoration: const InputDecoration(
                      labelText: 'Contact Person Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: controller.contactPersonPhoneController,
                    decoration: const InputDecoration(
                      labelText: 'Contact Person Phone',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: controller.websiteController,
                    decoration: const InputDecoration(
                      labelText: 'Website',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Business Information',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  // Business Information
                  TextFormField(
                    controller: controller.taxIdController,
                    decoration: const InputDecoration(
                      labelText: 'Tax ID',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: controller.licenseNumberController,
                    decoration: const InputDecoration(
                      labelText: 'License Number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Banking Information',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  // Banking Information
                  TextFormField(
                    controller: controller.accountNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Account Number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: controller.bankNameController,
                    decoration: const InputDecoration(
                      labelText: 'Bank Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: controller.bankBranchController,
                    decoration: const InputDecoration(
                      labelText: 'Bank Branch',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          controller.clearForm();
                          Get.back();
                        },
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () async {
                          bool success;
                          if (isEditing) {
                            success = await controller.updateSupplier(supplier.id);
                          } else {
                            success = await controller.saveSupplier();
                          }

                          if (success) {
                            Get.back();
                          }
                        },
                        child: Text(isEditing ? 'Update' : 'Save'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}