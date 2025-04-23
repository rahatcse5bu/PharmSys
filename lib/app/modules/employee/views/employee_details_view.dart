// app/modules/employees/views/employee_details_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pharma_sys/app/modules/employees/controllers/employee_controller.dart';
import 'package:pharma_sys/app/utils/theme.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class EmployeeDetailsView extends GetView<EmployeeController> {
  const EmployeeDetailsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Populate form for editing
              if (controller.selectedEmployee.value != null) {
                controller.populateFormForEdit(controller.selectedEmployee.value!);
                Get.toNamed('/add-employee');
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              if (controller.selectedEmployee.value != null) {
                controller.deleteEmployeeData(controller.selectedEmployee.value!.id);
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

        if (controller.selectedEmployee.value == null) {
          return const Center(
            child: Text('Employee not found'),
          );
        }

        final employee = controller.selectedEmployee.value!;

        return SingleChildScrollView(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Employee Profile Header
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 60.r,
                      backgroundColor: AppTheme.backgroundColor,
                      backgroundImage: employee.profileImage != null
                          ? FileImage(File(employee.profileImage!))
                          : null,
                      child: employee.profileImage == null
                          ? Icon(
                              Icons.person_outline,
                              size: 60.r,
                              color: AppTheme.primaryColor,
                            )
                          : null,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      employee.name,
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Text(
                        employee.role.replaceAll('_', ' ').toUpperCase(),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          employee.isActive
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: employee.isActive
                              ? AppTheme.successColor
                              : AppTheme.errorColor,
                          size: 16.r,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          employee.isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: employee.isActive
                                ? AppTheme.successColor
                                : AppTheme.errorColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32.h),

              // Contact Information
              _buildSectionTitle('Contact Information'),
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
                        'Email',
                        employee.email,
                        icon: Icons.email_outlined,
                      ),
                      Divider(height: 24.h),
                      _buildInfoRow(
                        'Phone',
                        employee.phone,
                        icon: Icons.phone_outlined,
                      ),
                      Divider(height: 24.h),
                      _buildInfoRow(
                        'Address',
                        employee.address,
                        icon: Icons.location_on_outlined,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              // Employment Information
              _buildSectionTitle('Employment Information'),
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
                        'Role',
                        employee.role.replaceAll('_', ' ').toUpperCase(),
                        icon: Icons.work_outline,
                      ),
                      Divider(height: 24.h),
                      _buildInfoRow(
                        'Joining Date',
                        DateFormat('MMMM dd, yyyy').format(employee.joiningDate),
                        icon: Icons.calendar_today_outlined,
                      ),
                      Divider(height: 24.h),
                      _buildInfoRow(
                        'Salary',
                        '${employee.salary.toStringAsFixed(0)} BDT',
                        icon: Icons.monetization_on_outlined,
                      ),
                      Divider(height: 24.h),
                      _buildInfoRow(
                        'Last Active',
                        employee.lastActiveDate != null
                            ? DateFormat('MMMM dd, yyyy').format(employee.lastActiveDate!)
                            : 'Not available',
                        icon: Icons.access_time,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              // Status Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showStatusUpdateDialog(context, employee.id, !employee.isActive);
                  },
                  icon: Icon(
                    employee.isActive ? Icons.cancel : Icons.check_circle,
                  ),
                  label: Text(
                    employee.isActive ? 'Deactivate Employee' : 'Activate Employee',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: employee.isActive
                        ? AppTheme.errorColor
                        : AppTheme.successColor,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
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

  Widget _buildInfoRow(String label, String value, {required IconData icon}) {
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
                color: AppTheme.textPrimaryColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showStatusUpdateDialog(BuildContext context, String id, bool newStatus) {
    Get.dialog(
      AlertDialog(
        title: Text(newStatus ? 'Activate Employee' : 'Deactivate Employee'),
        content: Text(
          newStatus
              ? 'Are you sure you want to activate this employee?'
              : 'Are you sure you want to deactivate this employee?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.updateStatus(id, newStatus);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: newStatus
                  ? AppTheme.successColor
                  : AppTheme.errorColor,
            ),
            child: Text(newStatus ? 'Activate' : 'Deactivate'),
          ),
        ],
      ),
    );
  }
}