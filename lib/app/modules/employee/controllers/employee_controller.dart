// app/modules/employees/controllers/employee_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pharma_sys/app/data/models/employee_model.dart';
import 'package:pharma_sys/app/modules/employees/view_models/employee_view_model.dart';
import 'package:pharma_sys/app/routes/app_routes.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';

class EmployeeController extends GetxController {
  final EmployeeViewModel _viewModel;
  
  // Form controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final salaryController = TextEditingController();
  
  // Form keys
  final formKey = GlobalKey<FormState>();
  
  // Date selection
  final Rx<DateTime?> joiningDate = Rx<DateTime?>(DateTime.now());
  
  // Image selection
  final Rx<String?> selectedImagePath = Rx<String?>(null);
  
  // Dropdown selected values
  final RxString selectedRole = 'pharmacist'.obs;
  final RxBool isActive = true.obs;
  
  // List of employee roles
  final List<String> employeeRoles = [
    'pharmacist',
    'salesperson',
    'cashier',
    'manager',
    'inventory_manager',
    'delivery_person',
  ];
  
  // Getters from view model
  RxList<EmployeeModel> get employees => _viewModel.employees;
  RxList<EmployeeModel> get filteredEmployees => _viewModel.filteredEmployees;
  RxList<EmployeeModel> get activeEmployees => _viewModel.activeEmployees;
  RxBool get isLoading => _viewModel.isLoading;
  RxBool get isSearching => _viewModel.isSearching;
  RxString get searchQuery => _viewModel.searchQuery;
  RxString get selectedFilter => _viewModel.selectedFilter;
  RxString get selectedSortBy => _viewModel.selectedSortBy;
  RxBool get isSortAscending => _viewModel.isSortAscending;
  Rx<EmployeeModel?> get selectedEmployee => _viewModel.selectedEmployee;
  
  EmployeeController({required EmployeeViewModel viewModel})
      : _viewModel = viewModel;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    // Dispose text controllers
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    salaryController.dispose();
    super.onClose();
  }
  
  // Delegate methods to view model
  Future<void> fetchAllEmployees() => _viewModel.fetchAllEmployees();
  void searchEmployees(String query) => _viewModel.searchEmployees(query);
  void filterEmployees() => _viewModel.filterEmployees();
  void sortEmployees() => _viewModel.sortEmployees();
  void toggleSortOrder() => _viewModel.toggleSortOrder();
  void setFilter(String filter) => _viewModel.setFilter(filter);
  void setSortBy(String sortBy) => _viewModel.setSortBy(sortBy);
  Future<void> getEmployeeDetails(String id) => _viewModel.getEmployeeDetails(id);
  
  // Navigate to add employee screen
  void goToAddEmployee() {
    // Clear form fields
    clearForm();
    Get.toNamed(Routes.ADD_EMPLOYEE);
  }

  // Navigate to employee details screen
  void goToEmployeeDetails(String id) async {
    await getEmployeeDetails(id);
    Get.toNamed(Routes.EMPLOYEE_DETAILS);
  }

  // Pick image from gallery
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      // Save the image to app directory
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = '${const Uuid().v4()}.jpg';
      final savedImage = File('${appDir.path}/$fileName');
      
      await File(pickedFile.path).copy(savedImage.path);
      selectedImagePath.value = savedImage.path;
    }
  }

  // Select joining date
  Future<void> selectJoiningDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: joiningDate.value ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != joiningDate.value) {
      joiningDate.value = picked;
    }
  }

  // Clear form fields
  void clearForm() {
    nameController.clear();
    emailController.clear();
    phoneController.clear();
    addressController.clear();
    salaryController.clear();
    selectedRole.value = 'pharmacist';
    joiningDate.value = DateTime.now();
    selectedImagePath.value = null;
    isActive.value = true;
  }

  // Populate form for editing
  void populateFormForEdit(EmployeeModel employee) {
    nameController.text = employee.name;
    emailController.text = employee.email;
    phoneController.text = employee.phone;
    addressController.text = employee.address;
    salaryController.text = employee.salary.toString();
    selectedRole.value = employee.role;
    joiningDate.value = employee.joiningDate;
    selectedImagePath.value = employee.profileImage;
    isActive.value = employee.isActive;
  }

  // Save employee
  Future<bool> saveEmployee() async {
    if (!formKey.currentState!.validate()) {
      return false;
    }
    
    try {
      final employee = EmployeeModel(
        id: '', // Will be generated by repository
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        address: addressController.text.trim(),
        role: selectedRole.value,
        salary: double.parse(salaryController.text.trim()),
        profileImage: selectedImagePath.value,
        joiningDate: joiningDate.value!,
        lastActiveDate: isActive.value ? DateTime.now() : null,
        isActive: isActive.value,
        permissions: null, // Default permissions
      );
      
      final result = await _viewModel.addEmployee(employee);
      if (result) {
        clearForm();
        Get.back();
      }
      return result;
    } catch (e) {
      Get.snackbar('Error', 'Failed to save employee: ${e.toString()}');
      return false;
    }
  }

  // Update employee
  Future<bool> updateEmployeeData() async {
    if (!formKey.currentState!.validate()) {
      return false;
    }
    
    if (selectedEmployee.value == null) {
      Get.snackbar('Error', 'Employee not found');
      return false;
    }
    
    try {
      final employee = selectedEmployee.value!.copyWith(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        address: addressController.text.trim(),
        role: selectedRole.value,
        salary: double.parse(salaryController.text.trim()),
        profileImage: selectedImagePath.value,
        joiningDate: joiningDate.value!,
        lastActiveDate: isActive.value ? DateTime.now() : selectedEmployee.value!.lastActiveDate,
        isActive: isActive.value,
      );
      
      final result = await _viewModel.updateEmployee(employee);
      if (result) {
        Get.back();
      }
      return result;
    } catch (e) {
      Get.snackbar('Error', 'Failed to update employee: ${e.toString()}');
      return false;
    }
  }
  
  // Delete employee
  Future<bool> deleteEmployeeData(String id) async {
    try {
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this employee? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
      
      if (confirmed == true) {
        final result = await _viewModel.deleteEmployee(id);
        if (result) {
          Get.back();
        }
        return result;
      }
      return false;
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete employee: ${e.toString()}');
      return false;
    }
  }
  
  // Update employee status
  Future<bool> updateStatus(String id, bool isActive) async {
    return await _viewModel.updateEmployeeStatus(id, isActive);
  }
  
  // Validate form fields
  String? validateRequired(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }
  
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegExp = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    if (!emailRegExp.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    
    return null;
  }
  
  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    
    final phoneRegExp = RegExp(r'^\+?[0-9]{10,15}$');
    if (!phoneRegExp.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    
    return null;
  }
  
  String? validateSalary(String? value) {
    if (value == null || value.isEmpty) {
      return 'Salary is required';
    }
    
    final salary = double.tryParse(value);
    if (salary == null) {
      return 'Please enter a valid amount';
    }
    
    if (salary < 0) {
      return 'Salary cannot be negative';
    }
    
    return null;
  }
}