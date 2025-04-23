// app/modules/inventory/views/add_medicine_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pharma_sys/app/utils/theme.dart';
import 'package:intl/intl.dart';
import 'dart:io';

import '../controller/inventory_controller.dart';

class AddMedicineView extends GetView<InventoryController> {
  const AddMedicineView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Medicine'),
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
              // Medicine Image Picker
              Center(
                child: Obx(() {
                  return Stack(
                    children: [
                      Container(
                        width: 120.w,
                        height: 120.w,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12.r),
                          image: controller.selectedImagePath.value != null
                              ? DecorationImage(
                                  image: FileImage(
                                    File(controller.selectedImagePath.value!),
                                  ),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: controller.selectedImagePath.value == null
                            ? Icon(
                                Icons.medication_outlined,
                                size: 50.r,
                                color: Colors.grey[500],
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
              // Basic Information Section
              _buildSectionTitle('Basic Information'),
              SizedBox(height: 16.h),
              TextFormField(
                controller: controller.nameController,
                decoration: const InputDecoration(
                  labelText: 'Medicine Name*',
                  hintText: 'Enter medicine name',
                  prefixIcon: Icon(Icons.medical_services_outlined),
                ),
                validator: controller.validateRequired,
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: controller.genericNameController,
                decoration: const InputDecoration(
                  labelText: 'Generic Name*',
                  hintText: 'Enter generic name',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                validator: controller.validateRequired,
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: controller.selectedType.value,
                      decoration: const InputDecoration(
                        labelText: 'Type*',
                        prefixIcon: Icon(Icons.medication_liquid_outlined),
                      ),
                      items: controller.medicineTypes
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(type.capitalize!),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          controller.selectedType.value = value;
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: TextFormField(
                      controller: controller.strengthController,
                      decoration: const InputDecoration(
                        labelText: 'Strength*',
                        hintText: 'e.g. 500mg',
                        prefixIcon: Icon(Icons.scale_outlined),
                      ),
                      validator: controller.validateRequired,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: controller.stripQuantityController,
                      decoration: const InputDecoration(
                        labelText: 'Strip Quantity*',
                        hintText: 'e.g. 10',
                        prefixIcon: Icon(Icons.grid_view_outlined),
                      ),
                      keyboardType: TextInputType.number,
                      validator: controller.validateNumber,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: TextFormField(
                      controller: controller.quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Total Quantity*',
                        hintText: 'e.g. 100',
                        prefixIcon: Icon(Icons.inventory_2_outlined),
                      ),
                      keyboardType: TextInputType.number,
                      validator: controller.validateNumber,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: controller.purchasePriceController,
                      decoration: const InputDecoration(
                        labelText: 'Purchase Price*',
                        hintText: 'e.g. 25.50',
                        prefixIcon: Icon(Icons.shopping_cart_outlined),
                      ),
                      keyboardType: TextInputType.number,
                      validator: controller.validatePrice,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: TextFormField(
                      controller: controller.sellingPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Selling Price*',
                        hintText: 'e.g. 35.75',
                        prefixIcon: Icon(Icons.monetization_on_outlined),
                      ),
                      keyboardType: TextInputType.number,
                      validator: controller.validatePrice,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: controller.alertThresholdController,
                decoration: const InputDecoration(
                  labelText: 'Alert Threshold*',
                  hintText: 'Minimum stock level before alert',
                  prefixIcon: Icon(Icons.warning_amber_outlined),
                ),
                keyboardType: TextInputType.number,
                validator: controller.validateNumber,
              ),
              SizedBox(height: 24.h),

              // Dates Section
              _buildSectionTitle('Dates'),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: Obx(() {
                      final mfgDate = controller.manufacturingDate.value;
                      return InkWell(
                        onTap: () {
                          controller.selectManufacturingDate(context);
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Manufacturing Date*',
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            mfgDate != null
                                ? DateFormat('MMM dd, yyyy').format(mfgDate)
                                : 'Select Date',
                          ),
                        ),
                      );
                    }),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Obx(() {
                      final expDate = controller.expiryDate.value;
                      return InkWell(
                        onTap: () {
                          controller.selectExpiryDate(context);
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Expiry Date*',
                            prefixIcon: Icon(Icons.event_outlined),
                          ),
                          child: Text(
                            expDate != null
                                ? DateFormat('MMM dd, yyyy').format(expDate)
                                : 'Select Date',
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              // Manufacturer Details Section
              _buildSectionTitle('Manufacturer Details'),
              SizedBox(height: 16.h),
              TextFormField(
                controller: controller.manufacturerNameController,
                decoration: const InputDecoration(
                  labelText: 'Manufacturer Name*',
                  hintText: 'Enter manufacturer name',
                  prefixIcon: Icon(Icons.business_outlined),
                ),
                validator: controller.validateRequired,
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: controller.batchNumberController,
                decoration: const InputDecoration(
                  labelText: 'Batch Number',
                  hintText: 'Enter batch number',
                  prefixIcon: Icon(Icons.numbers_outlined),
                ),
              ),
              SizedBox(height: 24.h),

              // Importer Details Section
              _buildSectionTitle('Importer Details (Optional)'),
              SizedBox(height: 16.h),
              TextFormField(
                controller: controller.importerNameController,
                decoration: const InputDecoration(
                  labelText: 'Importer Name',
                  hintText: 'Enter importer name',
                  prefixIcon: Icon(Icons.business_center_outlined),
                ),
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: controller.importerAddressController,
                decoration: const InputDecoration(
                  labelText: 'Importer Address',
                  hintText: 'Enter importer address',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                maxLines: 2,
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: controller.importerPhoneController,
                decoration: const InputDecoration(
                  labelText: 'Importer Phone',
                  hintText: 'Enter importer phone',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 24.h),

              // Seller Details Section
              _buildSectionTitle('Seller Details (Optional)'),
              SizedBox(height: 16.h),
              TextFormField(
                controller: controller.sellerNameController,
                decoration: const InputDecoration(
                  labelText: 'Seller Name',
                  hintText: 'Enter seller name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: controller.sellerPhoneController,
                decoration: const InputDecoration(
                  labelText: 'Seller Phone',
                  hintText: 'Enter seller phone',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: controller.locationController,
                decoration: const InputDecoration(
                  labelText: 'Storage Location',
                  hintText: 'Enter storage location in pharmacy',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              SizedBox(height: 32.h),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: Obx(() => ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : () {
                              FocusScope.of(context).unfocus();
                              controller.saveMedicine();
                            },
                      child: controller.isLoading.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Save Medicine'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                      ),
                    )),
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