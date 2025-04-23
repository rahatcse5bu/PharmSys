// app/modules/employees/view_models/employee_view_model.dart

import 'package:get/get.dart';
import 'package:pharmacy_inventory_app/app/data/models/employee_model.dart';
import 'package:pharmacy_inventory_app/app/data/repositories/employee_repository.dart';

class EmployeeViewModel extends GetxController {
  final EmployeeRepository _employeeRepository;
  
  // Observable variables
  final RxList<EmployeeModel> employees = <EmployeeModel>[].obs;
  final RxList<EmployeeModel> filteredEmployees = <EmployeeModel>[].obs;
  final RxList<EmployeeModel> activeEmployees = <EmployeeModel>[].obs;
  
  final RxBool isLoading = false.obs;
  final RxBool isSearching = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedFilter = 'All'.obs;
  final RxString selectedSortBy = 'Name'.obs;
  final RxBool isSortAscending = true.obs;

  // For employee details
  final Rx<EmployeeModel?> selectedEmployee = Rx<EmployeeModel?>(null);
  
  EmployeeViewModel({required EmployeeRepository employeeRepository})
      : _employeeRepository = employeeRepository;

  @override
  void onInit() {
    super.onInit();
    fetchAllEmployees();
    
    // Listen to search query changes
    ever(searchQuery, (_) => filterEmployees());
    ever(selectedFilter, (_) => filterEmployees());
    ever(selectedSortBy, (_) => sortEmployees());
    ever(isSortAscending, (_) => sortEmployees());
  }

  // Fetch all employees from repository
  Future<void> fetchAllEmployees() async {
    try {
      isLoading.value = true;
      final result = await _employeeRepository.getAllEmployees();
      employees.value = result;
      filteredEmployees.value = result;
      
      // Get active employees
      activeEmployees.value = result.where((emp) => emp.isActive).toList();
      
      sortEmployees();
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to load employees: ${e.toString()}');
    }
  }
  
  // Search employees
  void searchEmployees(String query) {
    searchQuery.value = query;
    isSearching.value = query.isNotEmpty;
    filterEmployees();
  }
  
  // Filter employees based on selected filter
  void filterEmployees() {
    if (searchQuery.isNotEmpty) {
      filteredEmployees.value = employees.where((employee) =>
          employee.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          employee.email.toLowerCase().contains(searchQuery.toLowerCase()) ||
          employee.phone.toLowerCase().contains(searchQuery.toLowerCase())
      ).toList();
    } else {
      switch (selectedFilter.value) {
        case 'All':
          filteredEmployees.value = employees;
          break;
        case 'Active':
          filteredEmployees.value = employees.where((employee) => employee.isActive).toList();
          break;
        case 'Inactive':
          filteredEmployees.value = employees.where((employee) => !employee.isActive).toList();
          break;
        default:
          // Filter by role
          filteredEmployees.value = employees.where((employee) => employee.role == selectedFilter.value).toList();
      }
    }
    
    sortEmployees();
  }
  
  // Sort employees based on selected sort by option
  void sortEmployees() {
    switch (selectedSortBy.value) {
      case 'Name':
        if (isSortAscending.value) {
          filteredEmployees.sort((a, b) => a.name.compareTo(b.name));
        } else {
          filteredEmployees.sort((a, b) => b.name.compareTo(a.name));
        }
        break;
      case 'Role':
        if (isSortAscending.value) {
          filteredEmployees.sort((a, b) => a.role.compareTo(b.role));
        } else {
          filteredEmployees.sort((a, b) => b.role.compareTo(a.role));
        }
        break;
      case 'Joining Date':
        if (isSortAscending.value) {
          filteredEmployees.sort((a, b) => a.joiningDate.compareTo(b.joiningDate));
        } else {
          filteredEmployees.sort((a, b) => b.joiningDate.compareTo(a.joiningDate));
        }
        break;
      case 'Salary':
        if (isSortAscending.value) {
          filteredEmployees.sort((a, b) => a.salary.compareTo(b.salary));
        } else {
          filteredEmployees.sort((a, b) => b.salary.compareTo(a.salary));
        }
        break;
    }
  }
  
  // Toggle sort order
  void toggleSortOrder() {
    isSortAscending.value = !isSortAscending.value;
  }
  
  // Set selected filter
  void setFilter(String filter) {
    selectedFilter.value = filter;
  }
  
  // Set selected sort by option
  void setSortBy(String sortBy) {
    selectedSortBy.value = sortBy;
  }
  
  // Get employee details
  Future<void> getEmployeeDetails(String id) async {
    try {
      isLoading.value = true;
      final employee = await _employeeRepository.getEmployeeById(id);
      selectedEmployee.value = employee;
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to load employee details: ${e.toString()}');
    }
  }
  
  // Add new employee
  Future<bool> addEmployee(EmployeeModel employee) async {
    try {
      isLoading.value = true;
      final id = await _employeeRepository.addEmployee(employee);
      await fetchAllEmployees(); // Refresh the list
      isLoading.value = false;
      Get.snackbar('Success', 'Employee added successfully');
      return true;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to add employee: ${e.toString()}');
      return false;
    }
  }
  
  // Update employee
  Future<bool> updateEmployee(EmployeeModel employee) async {
    try {
      isLoading.value = true;
      await _employeeRepository.updateEmployee(employee);
      await fetchAllEmployees(); // Refresh the list
      isLoading.value = false;
      Get.snackbar('Success', 'Employee updated successfully');
      return true;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to update employee: ${e.toString()}');
      return false;
    }
  }
  
  // Delete employee
  Future<bool> deleteEmployee(String id) async {
    try {
      isLoading.value = true;
      await _employeeRepository.deleteEmployee(id);
      await fetchAllEmployees(); // Refresh the list
      isLoading.value = false;
      Get.snackbar('Success', 'Employee deleted successfully');
      return true;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to delete employee: ${e.toString()}');
      return false;
    }
  }
  
  // Update employee status
  Future<bool> updateEmployeeStatus(String id, bool isActive) async {
    try {
      isLoading.value = true;
      await _employeeRepository.updateEmployeeStatus(id, isActive);
      await fetchAllEmployees(); // Refresh the list
      isLoading.value = false;
      Get.snackbar(
        'Success', 
        'Employee ${isActive ? 'activated' : 'deactivated'} successfully'
      );
      return true;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to update employee status: ${e.toString()}');
      return false;
    }
  }
  
  // Get employees by role
  List<EmployeeModel> getEmployeesByRole(String role) {
    return employees.where((emp) => emp.role == role).toList();
  }
  
  // Get employee count by role
  int getEmployeeCountByRole(String role) {
    return employees.where((emp) => emp.role == role).length;
  }
}