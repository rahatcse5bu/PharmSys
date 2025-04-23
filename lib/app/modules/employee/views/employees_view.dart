// app/modules/employees/views/employees_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:intl/intl.dart';
import 'dart:io';

import '../../../data/models/employee_model.dart';
import '../../../utils/theme.dart';
import '../controllers/employee_controller.dart';

class EmployeesView extends GetView<EmployeeController> {
  const EmployeesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Management'),
        actions: [
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
          // Search Bar
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search employees...',
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
                      controller.searchEmployees(value);
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
                _buildCategoryChip('All', Icons.people_alt_outlined),
                _buildCategoryChip('Active', Icons.check_circle_outline),
                _buildCategoryChip('Inactive', Icons.cancel_outlined),
                _buildCategoryChip('pharmacist', Icons.medical_services_outlined),
                _buildCategoryChip('salesperson', Icons.store),
                _buildCategoryChip('manager', Icons.admin_panel_settings_outlined),
                _buildCategoryChip('cashier', Icons.point_of_sale_outlined),
              ],
            ),
          ),

          // Employee List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (controller.filteredEmployees.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 80.r,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'No employees found',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Add new employees to your team',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppTheme.textTertiaryColor,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      ElevatedButton.icon(
                        onPressed: () {
                          controller.goToAddEmployee();
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Employee'),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 8.r),
                itemCount: controller.filteredEmployees.length,
                itemBuilder: (context, index) {
                  final employee = controller.filteredEmployees[index];
                  return _buildEmployeeCard(context, employee);
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.goToAddEmployee();
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

  Widget _buildEmployeeCard(BuildContext context, EmployeeModel employee) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        onTap: () {
          controller.goToEmployeeDetails(employee.id);
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Employee Image or Icon
              CircleAvatar(
                radius: 30.r,
                backgroundColor: AppTheme.backgroundColor,
                backgroundImage: employee.profileImage != null
                    ? FileImage(File(employee.profileImage!))
                    : null,
                child: employee.profileImage == null
                    ? Icon(
                        Icons.person_outline,
                        size: 30.r,
                        color: AppTheme.primaryColor,
                      )
                    : null,
              ),
              SizedBox(width: 16.w),
              // Employee Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            employee.name,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimaryColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!employee.isActive)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red[100],
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              'Inactive',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: Colors.red,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      employee.role.replaceAll('_', ' ').toUpperCase(),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(
                          Icons.email_outlined,
                          size: 14.r,
                          color: AppTheme.textSecondaryColor,
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            employee.email,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppTheme.textSecondaryColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(
                          Icons.phone_outlined,
                          size: 14.r,
                          color: AppTheme.textSecondaryColor,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          employee.phone,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        _buildInfoChip(
                          'Joined: ${DateFormat('MMM dd, yyyy').format(employee.joiningDate)}',
                          Icons.calendar_today_outlined,
                        ),
                        SizedBox(width: 8.w),
                        _buildInfoChip(
                          'Salary: ${employee.salary.toStringAsFixed(0)} BDT',
                          Icons.monetization_on_outlined,
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

  Widget _buildInfoChip(String label, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12.r,
            color: AppTheme.primaryColor,
          ),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppTheme.primaryColor,
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
                  _buildSortOption('Role'),
                  _buildSortOption('Joining Date'),
                  _buildSortOption('Salary'),
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
                  _buildFilterOption('All', Icons.people_alt_outlined),
                  _buildFilterOption('Active', Icons.check_circle_outline),
                  _buildFilterOption('Inactive', Icons.cancel_outlined),
                  _buildFilterOption('pharmacist', Icons.medical_services_outlined),
                  _buildFilterOption('salesperson', Icons.store),
                  _buildFilterOption('manager', Icons.admin_panel_settings_outlined),
                  _buildFilterOption('cashier', Icons.point_of_sale_outlined),
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