// app/modules/inventory/views/low_stock_alert_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pharma_sys/app/modules/inventory/controllers/inventory_controller.dart';
import 'package:pharma_sys/app/utils/theme.dart';
import 'package:pharma_sys/app/data/models/medicine_model.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class LowStockAlertView extends GetView<InventoryController> {
  const LowStockAlertView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Inventory Alerts'),
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(
                icon: Icon(Icons.warning_amber_outlined, size: 18.r),
                text: 'Low Stock',
              ),
              Tab(
                icon: Icon(Icons.access_time, size: 18.r),
                text: 'Expiring Soon',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildLowStockTab(),
            _buildExpiringMedicinesTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildLowStockTab() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      if (controller.lowStockMedicines.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 80.r,
                color: AppTheme.successColor,
              ),
              SizedBox(height: 16.h),
              Text(
                'All Good!',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'No medicines are low in stock',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.all(16.r),
        itemCount: controller.lowStockMedicines.length,
        itemBuilder: (context, index) {
          return _buildLowStockItem(controller.lowStockMedicines[index]);
        },
      );
    });
  }

  Widget _buildExpiringMedicinesTab() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      if (controller.expiringMedicines.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 80.r,
                color: AppTheme.successColor,
              ),
              SizedBox(height: 16.h),
              Text(
                'All Good!',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'No medicines are expiring soon',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.all(16.r),
        itemCount: controller.expiringMedicines.length,
        itemBuilder: (context, index) {
          return _buildExpiringMedicineItem(controller.expiringMedicines[index]);
        },
      );
    });
  }

  Widget _buildLowStockItem(MedicineModel medicine) {
    final percentageOfThreshold = (medicine.quantity / medicine.alertThreshold) * 100;
    final progressColor = percentageOfThreshold <= 50
        ? AppTheme.errorColor
        : percentageOfThreshold <= 75
            ? AppTheme.warningColor
            : AppTheme.infoColor;

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        onTap: () {
          controller.goToMedicineDetails(medicine.id);
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Medicine Image or Icon
              Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(8.r),
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
                        size: 30.r,
                        color: AppTheme.warningColor,
                      )
                    : null,
              ),
              SizedBox(width: 16.w),
              // Medicine Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            medicine.name,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimaryColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          Icons.warning_amber_outlined,
                          color: AppTheme.warningColor,
                          size: 18.r,
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      medicine.genericName,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppTheme.textSecondaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Text(
                          'Stock: ${medicine.quantity}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: progressColor,
                          ),
                        ),
                        Text(
                          ' / Threshold: ${medicine.alertThreshold}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4.r),
                      child: LinearProgressIndicator(
                        value: medicine.quantity / medicine.alertThreshold > 1
                            ? 1
                            : medicine.quantity / medicine.alertThreshold,
                        backgroundColor: Colors.grey[300],
                        color: progressColor,
                        minHeight: 8.h,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    // Buttons row
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              _showUpdateStockDialog(context, medicine.id, medicine.quantity);
                            },
                            icon: Icon(Icons.edit, size: 16.r),
                            label: const Text('Update Stock'),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              controller.goToMedicineDetails(medicine.id);
                            },
                            icon: Icon(Icons.visibility, size: 16.r),
                            label: const Text('View Details'),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpiringMedicineItem(MedicineModel medicine) {
    final daysRemaining = medicine.expiryDate.difference(DateTime.now()).inDays;
    final textColor = daysRemaining <= 10
        ? AppTheme.errorColor
        : daysRemaining <= 20
            ? AppTheme.warningColor
            : AppTheme.infoColor;

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        onTap: () {
          controller.goToMedicineDetails(medicine.id);
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Medicine Image or Icon
              Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(8.r),
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
                        size: 30.r,
                        color: textColor,
                      )
                    : null,
              ),
              SizedBox(width: 16.w),
              // Medicine Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            medicine.name,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimaryColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          Icons.access_time,
                          color: textColor,
                          size: 18.r,
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      medicine.genericName,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppTheme.textSecondaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Icon(
                          Icons.event_outlined,
                          size: 16.r,
                          color: textColor,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'Expires on: ',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                        Text(
                          DateFormat('MMM dd, yyyy').format(medicine.expiryDate),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: textColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Text(
                        '$daysRemaining days remaining',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: textColor,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    // Stock info
                    Row(
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 16.r,
                          color: AppTheme.textSecondaryColor,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'Current Stock: ${medicine.quantity} units',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    // Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          controller.goToMedicineDetails(medicine.id);
                        },
                        icon: Icon(Icons.visibility, size: 16.r),
                        label: const Text('View Details'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          backgroundColor: textColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
}