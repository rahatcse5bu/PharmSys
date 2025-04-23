// app/modules/employees/views/add_employee_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pharmacy_inventory_app/app/modules/employees/controllers/employee_controller.dart';
import 'package:pharmacy_inventory_app/app/utils/theme.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class AddEmployeeView extends GetView<EmployeeController> {
  const AddEmployeeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isEditMode = controller.selectedEmployee.value != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Employee' : 'Add Employee'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: SafeArea(
        child: Form(
          key: controller.formKey,
          child: ListView(
            padding: EdgeInsets.all(16.r),
            children: [
              // Employee Profile Image
              Center(
                child: Obx(() {
                  return Stack(
                    children: [
                      CircleAvatar(
                        radius: 60.r,
                        backgroundColor: AppTheme.backgroundColor,
                        backgroundImage: controller.selectedImagePath.value != null
                            ? FileImage(File(controller.selectedImagePath.value!))
                            : null,
                        child: controller.selectedImagePath.value == null
                            ? Icon(
                                Icons.person_outline,
                                size: 60.r,
                                color: AppTheme.primaryColor,
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              controller.pickImage();
                            },
                            iconSize: 20.r,
                            constraints: BoxConstraints(
                              minHeight: 40.r,
                              minWidth: 40.r,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
              SizedBox(height: 24.h),

              // Personal Information
              _buildSectionTitle('Personal Information'),
              SizedBox(height: 16.h),
              TextFormField(
                controller: controller.nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name*',
                  hintText: 'Enter employee full name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: controller.validateRequired,
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: controller.emailController,
                decoration: const InputDecoration(
                  labelText: 'Email*',
                  hintText: 'Enter employee email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: controller.validateEmail,
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: controller.phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number*',
                  hintText: 'Enter employee phone number',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                keyboardType: TextInputType.phone,
                validator: controller.validatePhone,
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: controller.addressController,
                decoration: const InputDecoration(
                  labelText: 'Address*',
                  hintText: 'Enter employee address',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                maxLines: 2,
                validator: controller.validateRequired,
              ),
              SizedBox(height: 24.h),

              // Employment Details
              _buildSectionTitle('Employment Details'),
              SizedBox(height: 16.h),
              DropdownButtonFormField<String>(
                value: controller.selectedRole.value,
                decoration: const InputDecoration(
                  labelText: 'Role*',
                  prefixIcon: Icon(Icons.work_outline),
                ),
                items: controller.employeeRoles
                    .map((role) => DropdownMenuItem(
                          value: role,
                          child: Text(role.replaceAll('_', ' ').toUpperCase()),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    controller.selectedRole.value = value;
                  }
                },
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: controller.salaryController,
                decoration: const InputDecoration(
                  labelText: 'Salary (BDT)*',
                  hintText: 'Enter employee salary',
                  prefixIcon: Icon(Icons.monetization_on_outlined),
                ),
                keyboardType: TextInputType.number,
                validator: controller.validateSalary,
              ),
              SizedBox(height: 16.h),
              Obx(() {
                final joiningDateText = controller.joiningDate.value != null
                    ? DateFormat('MMM dd, yyyy').format(controller.joiningDate.value!)
                    : 'Select Date';
                return InkWell(
                  onTap: () {
                    controller.selectJoiningDate(context);
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Joining Date*',
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(joiningDateText),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                );
              }),
              SizedBox(height: 16.h),
              // Status
              Row(
                children: [
                  SizedBox(width: 8.w),
                  Obx(() => Checkbox(
                        value: controller.isActive.value,
                        onChanged: (value) {
                          controller.isActive.value = value ?? true;
                        },
                        activeColor: AppTheme.primaryColor,
                      )),
                  Text(
                    'Active Employee',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32.h),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: Obx(() => ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : () {
                              if (isEditMode) {
                                controller.updateEmployeeData();
                              } else {
                                controller.saveEmployee();
                              }
                            },
                      child: controller.isLoading.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(isEditMode ? 'Update Employee' : 'Save Employee'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                      ),
                    )),
              ),
              SizedBox(height: 16.h),
              // Cancel Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: const Text('Cancel'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
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
}