// app/modules/inventory/views/medicine_details_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pharma_sys/app/modules/inventory/controllers/inventory_controller.dart';
import 'package:pharma_sys/app/utils/theme.dart';
import 'package:pharma_sys/app/routes/app_routes.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class MedicineDetailsView extends GetView<InventoryController> {
  const MedicineDetailsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Populate form for editing
              if (controller.selectedMedicine.value != null) {
                controller.populateFormForEdit(controller.selectedMedicine.value!);
                Get.toNamed(Routes.ADD_MEDICINE);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              if (controller.selectedMedicine.value != null) {
                controller.deleteMedicineData(controller.selectedMedicine.value!.id);
              }
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.selectedMedicine.value == null) {
          return const Center(
            child: Text('Medicine not found'),
          );
        }

        final medicine = controller.selectedMedicine.value!;
        final isLowStock = medicine.quantity <= medicine.alertThreshold;
        final isExpiringSoon = medicine.expiryDate.difference(DateTime.now()).inDays <= 30;

        return SingleChildScrollView(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Medicine Image and Basic Info
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Medicine Image
                  Container(
                    width: 100.w,
                    height: 100.w,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12.r),
                      image: medicine.image != null
                          ? DecorationImage(
                              image: FileImage(File(medicine.image!)),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: medicine.image == null
                        ? Icon(
                            Icons.medication_outlined,
                            size: 50.r,
                            color: Colors.grey[500],
                          )
                        : null,
                  ),
                  SizedBox(width: 16.w),
                  // Basic Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          medicine.name,
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimaryColor,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          medicine.genericName,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            _buildInfoPill(
                              '${medicine.strength} ${medicine.type}',
                              Icons.medication,
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Icon(
                              Icons.monetization_on_outlined,
                              size: 18.r,
                              color: AppTheme.primaryColor,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'Price: \$${medicine.sellingPrice.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              // Stock Information
              _buildSectionTitle('Stock Information'),
              SizedBox(height: 16.h),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.r),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        'Current Stock',
                        '${medicine.quantity} units',
                        icon: Icons.inventory_2_outlined,
                        valueColor: isLowStock ? AppTheme.warningColor : null,
                      ),
                      Divider(height: 24.h),
                      _buildInfoRow(
                        'Strip Quantity',
                        '${medicine.stripQuantity} units/strip',
                        icon: Icons.grid_view_outlined,
                      ),
                      Divider(height: 24.h),
                      _buildInfoRow(
                        'Alert Threshold',
                        '${medicine.alertThreshold} units',
                        icon: Icons.warning_amber_outlined,
                      ),
                      Divider(height: 24.h),
                      _buildInfoRow(
                        'Storage Location',
                        medicine.location ?? 'Not specified',
                        icon: Icons.location_on_outlined,
                      ),
                      SizedBox(height: 16.h),
                      // Stock update
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                _showUpdateStockDialog(context, medicine.id, medicine.quantity);
                              },
                              icon: const Icon(Icons.edit),
                              label: const Text('Update Stock'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isLowStock ? AppTheme.warningColor : AppTheme.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              // Dates Information
              _buildSectionTitle('Important Dates'),
              SizedBox(height: 16.h),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.r),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        'Manufacturing Date',
                        DateFormat('MMMM dd, yyyy').format(medicine.manufacturingDate),
                        icon: Icons.calendar_today,
                      ),
                      Divider(height: 24.h),
                      _buildInfoRow(
                        'Expiry Date',
                        DateFormat('MMMM dd, yyyy').format(medicine.expiryDate),
                        icon: Icons.event_outlined,
                        valueColor: isExpiringSoon ? AppTheme.errorColor : null,
                      ),
                      if (isExpiringSoon)
                        Padding(
                          padding: EdgeInsets.only(top: 8.h),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning_amber_outlined,
                                color: AppTheme.errorColor,
                                size: 16.r,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'Expires in ${medicine.expiryDate.difference(DateTime.now()).inDays} days',
                                style: TextStyle(
                                  color: AppTheme.errorColor,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      Divider(height: 24.h),
                      _buildInfoRow(
                        'Added Date',
                        DateFormat('MMMM dd, yyyy').format(medicine.addedDate),
                        icon: Icons.add_circle_outline,
                      ),
                      Divider(height: 24.h),
                      _buildInfoRow(
                        'Last Updated',
                        DateFormat('MMMM dd, yyyy').format(medicine.updatedDate),
                        icon: Icons.update,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              // Manufacturer Information
              _buildSectionTitle('Manufacturer Information'),
              SizedBox(height: 16.h),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.r),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        'Manufacturer Name',
                        medicine.manufacturerName,
                        icon: Icons.business_outlined,
                      ),
                      Divider(height: 24.h),
                      _buildInfoRow(
                        'Batch Number',
                        medicine.batchNumber ?? 'Not specified',
                        icon: Icons.numbers_outlined,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              // Importer Information
              if (medicine.importerName != null || medicine.importerAddress != null || medicine.importerPhone != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Importer Information'),
                    SizedBox(height: 16.h),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16.r),
                        child: Column(
                          children: [
                            if (medicine.importerName != null)
                              _buildInfoRow(
                                'Importer Name',
                                medicine.importerName!,
                                icon: Icons.business_center_outlined,
                              ),
                            if (medicine.importerName != null) Divider(height: 24.h),
                            if (medicine.importerAddress != null)
                              _buildInfoRow(
                                'Importer Address',
                                medicine.importerAddress!,
                                icon: Icons.location_on_outlined,
                              ),
                            if (medicine.importerAddress != null) Divider(height: 24.h),
                            if (medicine.importerPhone != null)
                              _buildInfoRow(
                                'Importer Phone',
                                medicine.importerPhone!,
                                icon: Icons.phone_outlined,
                              ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),

              // Seller Information
              if (medicine.sellerName != null || medicine.sellerPhone != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Seller Information'),
                    SizedBox(height: 16.h),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16.r),
                        child: Column(
                          children: [
                            if (medicine.sellerName != null)
                              _buildInfoRow(
                                'Seller Name',
                                medicine.sellerName!,
                                icon: Icons.person_outline,
                              ),
                            if (medicine.sellerName != null) Divider(height: 24.h),
                            if (medicine.sellerPhone != null)
                              _buildInfoRow(
                                'Seller Phone',
                                medicine.sellerPhone!,
                                icon: Icons.phone_outlined,
                              ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),

              // Purchase Information
              _buildSectionTitle('Purchase Information'),
              SizedBox(height: 16.h),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.r),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        'Purchase Price',
                        '\$${medicine.purchasePrice.toStringAsFixed(2)}',
                        icon: Icons.shopping_cart_outlined,
                      ),
                      Divider(height: 24.h),
                      _buildInfoRow(
                        'Selling Price',
                        '\$${medicine.sellingPrice.toStringAsFixed(2)}',
                        icon: Icons.monetization_on_outlined,
                      ),
                      Divider(height: 24.h),
                      _buildInfoRow(
                        'Profit Margin',
                        '${((medicine.sellingPrice - medicine.purchasePrice) / medicine.purchasePrice * 100).toStringAsFixed(2)}%',
                        icon: Icons.trending_up,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 32.h),
            ],
          ),
        );
      }),
    );
  }

  void _showUpdateStockDialog(BuildContext context, String id, int currentQuantity) {
    final TextEditingController quantityController = TextEditingController(text: currentQuantity.toString());
    
    Get.dialog(
      AlertDialog(
        title: const Text('Update Stock'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Current stock: $currentQuantity units',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: quantityController,
              decoration: const InputDecoration(
                labelText: 'New Quantity',
                hintText: 'Enter new quantity',
                prefixIcon: Icon(Icons.inventory_2_outlined),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newQuantity = int.tryParse(quantityController.text.trim());
              if (newQuantity != null) {
                controller.updateQuantity(id, newQuantity);
                Get.back();
              } else {
                Get.snackbar('Error', 'Please enter a valid number');
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Divider(
            color: AppTheme.primaryColor.withOpacity(0.4),
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {required IconData icon, Color? valueColor}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20.r,
          color: AppTheme.primaryColor,
        ),
        SizedBox(width: 12.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: valueColor ?? AppTheme.textPrimaryColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoPill(String text, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16.r,
            color: AppTheme.primaryColor,
          ),
          SizedBox(width: 4.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}