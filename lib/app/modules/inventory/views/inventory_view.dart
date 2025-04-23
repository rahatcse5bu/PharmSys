// app/modules/inventory/views/inventory_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pharmacy_inventory_app/app/modules/inventory/controllers/inventory_controller.dart';
import 'package:pharmacy_inventory_app/app/utils/theme.dart';
import 'package:pharmacy_inventory_app/app/data/models/medicine_model.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class InventoryView extends GetView<InventoryController> {
  const InventoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              controller.goToLowStockAlert();
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterBottomSheet(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search medicines...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 12.h,
                        horizontal: 16.w,
                      ),
                    ),
                    onChanged: (value) {
                      controller.searchMedicines(value);
                    },
                  ),
                ),
                SizedBox(width: 8.w),
                Obx(() => IconButton(
                      icon: Icon(
                        controller.isSortAscending.value
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                      ),
                      onPressed: () {
                        controller.toggleSortOrder();
                      },
                    )),
              ],
            ),
          ),

          // Active Filter Chips
          Obx(() => controller.selectedFilter.value != 'All'
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.r),
                  child: Row(
                    children: [
                      Chip(
                        label: Text(controller.selectedFilter.value),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () {
                          controller.setFilter('All');
                        },
                      ),
                      const Spacer(),
                      Text(
                        'Sort by: ${controller.selectedSortBy.value}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.r),
                  child: Row(
                    children: [
                      const Spacer(),
                      Text(
                        'Sort by: ${controller.selectedSortBy.value}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                )),

          // Category Chips
          SizedBox(
            height: 60.h,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 8.r),
              children: [
                _buildCategoryChip('All', Icons.all_inclusive),
                _buildCategoryChip('Tablets', Icons.medication),
                _buildCategoryChip('Capsules', Icons.medication_outlined),
                _buildCategoryChip('Syrups', Icons.local_drink_outlined),
                _buildCategoryChip('Injections', Icons.vaccines_outlined),
                _buildCategoryChip('Low Stock', Icons.warning_amber_outlined),
                _buildCategoryChip('Expiring Soon', Icons.access_time),
              ],
            ),
          ),

          // Medicine List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (controller.filteredMedicines.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 80.r,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'No medicines found',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Add new medicines to your inventory',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppTheme.textTertiaryColor,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      ElevatedButton.icon(
                        onPressed: () {
                          controller.goToAddMedicine();
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Medicine'),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 8.r),
                itemCount: controller.filteredMedicines.length,
                itemBuilder: (context, index) {
                  final medicine = controller.filteredMedicines[index];
                  return _buildMedicineCard(context, medicine);
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.goToAddMedicine();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategoryChip(String label, IconData icon) {
    return Obx(() {
      final isSelected = controller.selectedFilter.value == label;
      return Padding(
        padding: EdgeInsets.only(right: 8.w),
        child: ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16.r,
                color: isSelected ? Colors.white : AppTheme.primaryColor,
              ),
              SizedBox(width: 4.w),
              Text(label),
            ],
          ),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              controller.setFilter(label);
            }
          },
          backgroundColor: Colors.white,
          selectedColor: AppTheme.primaryColor,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textPrimaryColor,
            fontSize: 12.sp,
          ),
          padding: EdgeInsets.symmetric(horizontal: 8.w),
        ),
      );
    });
  }

  Widget _buildMedicineCard(BuildContext context, MedicineModel medicine) {
    final isLowStock = medicine.quantity <= medicine.alertThreshold;
    final isExpiringSoon = medicine.expiryDate.difference(DateTime.now()).inDays <= 30;

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
                        color: AppTheme.primaryColor,
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
                        if (isLowStock)
                          Padding(
                            padding: EdgeInsets.only(left: 8.w),
                            child: Icon(
                              Icons.warning_amber_outlined,
                              color: AppTheme.warningColor,
                              size: 18.r,
                            ),
                          ),
                        if (isExpiringSoon)
                          Padding(
                            padding: EdgeInsets.only(left: 8.w),
                            child: Icon(
                              Icons.access_time,
                              color: AppTheme.errorColor,
                              size: 18.r,
                            ),
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
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        _buildInfoChip(
                          '${medicine.strength} ${medicine.type}',
                          Icons.medical_information_outlined,
                        ),
                        SizedBox(width: 8.w),
                        _buildInfoChip(
                          '${medicine.quantity} in stock',
                          Icons.inventory_2_outlined,
                          isLowStock ? AppTheme.warningColor : null,
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Text(
                          'Exp: ${DateFormat('MMM dd, yyyy').format(medicine.expiryDate)}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: isExpiringSoon
                                ? AppTheme.errorColor
                                : AppTheme.textTertiaryColor,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '\$${medicine.sellingPrice.toStringAsFixed(2)}',
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
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, IconData icon, [Color? color]) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: (color ?? AppTheme.primaryColor).withOpacity(0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12.r,
            color: color ?? AppTheme.primaryColor,
          ),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: color ?? AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.r),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sort By',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              SizedBox(height: 16.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  _buildSortOption('Name'),
                  _buildSortOption('Generic Name'),
                  _buildSortOption('Expiry Date'),
                  _buildSortOption('Stock'),
                  _buildSortOption('Price'),
                ],
              ),
              SizedBox(height: 24.h),
              Text(
                'Filter By',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              SizedBox(height: 16.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  _buildFilterOption('All', Icons.all_inclusive),
                  _buildFilterOption('Tablets', Icons.medication),
                  _buildFilterOption('Capsules', Icons.medication_outlined),
                  _buildFilterOption('Syrups', Icons.local_drink_outlined),
                  _buildFilterOption('Injections', Icons.vaccines_outlined),
                  _buildFilterOption('Low Stock', Icons.warning_amber_outlined),
                  _buildFilterOption('Expiring Soon', Icons.access_time),
                ],
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: Text('Apply Filters'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(String option) {
    return Obx(() {
      final isSelected = controller.selectedSortBy.value == option;
      return ChoiceChip(
        label: Text(option),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            controller.setSortBy(option);
          }
        },
        backgroundColor: Colors.white,
        selectedColor: AppTheme.primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppTheme.textPrimaryColor,
          fontSize: 14.sp,
        ),
      );
    });
  }

  Widget _buildFilterOption(String label, IconData icon) {
    return Obx(() {
      final isSelected = controller.selectedFilter.value == label;
      return ChoiceChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16.r,
              color: isSelected ? Colors.white : AppTheme.primaryColor,
            ),
            SizedBox(width: 4.w),
            Text(label),
          ],
        ),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            controller.setFilter(label);
            Get.back();
          }
        },
        backgroundColor: Colors.white,
        selectedColor: AppTheme.primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppTheme.textPrimaryColor,
          fontSize: 14.sp,
        ),
      );
    });
  }
}