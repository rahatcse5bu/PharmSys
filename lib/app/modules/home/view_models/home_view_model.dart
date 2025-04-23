// app/modules/home/view_models/home_view_model.dart

import 'package:get/get.dart';
import 'package:pharmacy_inventory_app/app/data/models/medicine_model.dart';
import 'package:pharmacy_inventory_app/app/data/models/sale_model.dart';
import 'package:pharmacy_inventory_app/app/data/models/employee_model.dart';
import 'package:pharmacy_inventory_app/app/data/models/shop_model.dart';
import 'package:pharmacy_inventory_app/app/data/repositories/medicine_repository.dart';
import 'package:pharmacy_inventory_app/app/data/repositories/sale_repository.dart';
import 'package:pharmacy_inventory_app/app/data/repositories/employee_repository.dart';
import 'package:pharmacy_inventory_app/app/data/repositories/shop_repository.dart';

class HomeViewModel extends GetxController {
  final MedicineRepository _medicineRepository;
  final SaleRepository _saleRepository;
  final EmployeeRepository _employeeRepository;
  final ShopRepository _shopRepository;

  // Observable variables
  final RxString shopName = ''.obs;
  final RxString shopOwnerName = ''.obs;
  final RxString shopLogo = ''.obs;
  final RxString shopAddress = ''.obs;
  final RxString shopPhone = ''.obs;

  final RxDouble totalSales = 0.0.obs;
  final RxInt totalProducts = 0.obs;
  final RxInt lowStockCount = 0.obs;
  final RxInt expiringCount = 0.obs;
  final RxInt employeeCount = 0.obs;
  final RxDouble todaySales = 0.0.obs;
  final RxInt todayTransactions = 0.obs;

  final RxString selectedChartPeriod = 'Weekly'.obs;
  final RxList<double> chartData = <double>[].obs;
  final RxList<String> chartLabels = <String>[].obs;
  final RxDouble periodTotal = 0.0.obs;
  final RxDouble periodAverage = 0.0.obs;
  final RxDouble periodHighest = 0.0.obs;

  final RxList<Map<String, dynamic>> recentActivities = <Map<String, dynamic>>[].obs;

  final RxList<MedicineModel> lowStockMedicines = <MedicineModel>[].obs;
  final RxList<MedicineModel> expiringMedicines = <MedicineModel>[].obs;
  final RxList<SaleModel> recentSales = <SaleModel>[].obs;
  final RxList<EmployeeModel> activeEmployees = <EmployeeModel>[].obs;

  final RxBool isLoading = false.obs;

  HomeViewModel({
    required MedicineRepository medicineRepository,
    required SaleRepository saleRepository,
    required EmployeeRepository employeeRepository,
    required ShopRepository shopRepository,
  })  : _medicineRepository = medicineRepository,
        _saleRepository = saleRepository,
        _employeeRepository = employeeRepository,
        _shopRepository = shopRepository;

  @override
  void onInit() {
    super.onInit();
    loadShopInfo();
    loadDashboardData();
  }

  Future<void> loadShopInfo() async {
    try {
      isLoading.value = true;
      final ShopModel? shop = await _shopRepository.getShopInfo();
      
      if (shop != null) {
        shopName.value = shop.name;
        shopOwnerName.value = shop.ownerName ?? 'Shop Owner';
        shopLogo.value = shop.logo ?? '';
        shopAddress.value = shop.address;
        shopPhone.value = shop.phone;
      }
      
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      print('Error loading shop info: $e');
      Get.snackbar('Error', 'Failed to load shop information');
    }
  }

  Future<void> loadDashboardData() async {
    try {
      isLoading.value = true;
      
      // Get all medicines
      final medicines = await _medicineRepository.getAllMedicines();
      totalProducts.value = medicines.length;
      
      // Get low stock medicines
      final lowStockMeds = await _medicineRepository.getLowStockMedicines();
      lowStockCount.value = lowStockMeds.length;
      lowStockMedicines.value = lowStockMeds;
      
      // Get expiring medicines
      final expiringMeds = await _medicineRepository.getExpiringMedicines();
      expiringCount.value = expiringMeds.length;
      expiringMedicines.value = expiringMeds;
      
      // Get all employees
      final employees = await _employeeRepository.getAllEmployees();
      employeeCount.value = employees.length;
      
      // Get active employees
      final activeEmps = employees.where((emp) => emp.isActive).toList();
      activeEmployees.value = activeEmps;
      
      // Get all sales
      final sales = await _saleRepository.getAllSales();
      totalSales.value = sales.fold(0, (prev, sale) => prev + sale.total);
      
      // Get today's sales
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      final todayEnd = DateTime(today.year, today.month, today.day, 23, 59, 59);
      
      final todaySalesList = await _saleRepository.getSalesByDateRange(
        startDate: todayStart,
        endDate: todayEnd,
      );
      
      todaySales.value = todaySalesList.fold(0, (prev, sale) => prev + sale.total);
      todayTransactions.value = todaySalesList.length;
      
      // Get recent sales
      final recentSalesList = await _saleRepository.getRecentSales(limit: 5);
      recentSales.value = recentSalesList;
      
      // Load chart data
      await loadChartData();
      
      // Load recent activities
      await loadRecentActivities();
      
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      print('Error loading dashboard data: $e');
      Get.snackbar('Error', 'Failed to load dashboard data');
    }
  }

  Future<void> loadChartData() async {
    try {
      chartData.clear();
      chartLabels.clear();
      
      final now = DateTime.now();
      
      switch (selectedChartPeriod.value) {
        case 'Weekly':
          // Get sales for last 7 days
          for (int i = 6; i >= 0; i--) {
            final date = now.subtract(Duration(days: i));
            final dayStart = DateTime(date.year, date.month, date.day);
            final dayEnd = DateTime(date.year, date.month, date.day, 23, 59, 59);
            
            final daySales = await _saleRepository.getSalesByDateRange(
              startDate: dayStart,
              endDate: dayEnd,
            );
            
            final dailyTotal = daySales.fold(0.0, (prev, sale) => prev + sale.total);
            chartData.add(dailyTotal);
            chartLabels.add(date.day.toString());
          }
          break;
          
        case 'Monthly':
          // Get sales for each week of current month
          final monthStart = DateTime(now.year, now.month, 1);
          final nextMonth = now.month < 12 
              ? DateTime(now.year, now.month + 1, 1)
              : DateTime(now.year + 1, 1, 1);
          final daysInMonth = nextMonth.difference(monthStart).inDays;
          
          for (int week = 0; week < 5; week++) {
            final weekStart = week * 7 + 1;
            if (weekStart > daysInMonth) break;
            
            final weekEnd = (week + 1) * 7;
            final adjustedWeekEnd = weekEnd > daysInMonth ? daysInMonth : weekEnd;
            
            final startDate = DateTime(now.year, now.month, weekStart);
            final endDate = DateTime(now.year, now.month, adjustedWeekEnd, 23, 59, 59);
            
            final weekSales = await _saleRepository.getSalesByDateRange(
              startDate: startDate,
              endDate: endDate,
            );
            
            final weeklyTotal = weekSales.fold(0.0, (prev, sale) => prev + sale.total);
            chartData.add(weeklyTotal);
            chartLabels.add('W${week + 1}');
          }
          break;
          
        case 'Yearly':
          // Get sales for each month of current year
          for (int month = 1; month <= 12; month++) {
            final monthStart = DateTime(now.year, month, 1);
            final monthEnd = month < 12
                ? DateTime(now.year, month + 1, 1).subtract(const Duration(seconds: 1))
                : DateTime(now.year + 1, 1, 1).subtract(const Duration(seconds: 1));
            
            final monthSales = await _saleRepository.getSalesByDateRange(
              startDate: monthStart,
              endDate: monthEnd,
            );
            
            final monthlyTotal = monthSales.fold(0.0, (prev, sale) => prev + sale.total);
            chartData.add(monthlyTotal);
            chartLabels.add(monthStart.month.toString());
          }
          break;
      }
      
      // Calculate summary statistics
      if (chartData.isNotEmpty) {
        periodTotal.value = chartData.reduce((a, b) => a + b);
        periodAverage.value = periodTotal.value / chartData.length;
        periodHighest.value = chartData.reduce((a, b) => a > b ? a : b);
      } else {
        periodTotal.value = 0.0;
        periodAverage.value = 0.0;
        periodHighest.value = 0.0;
      }
    } catch (e) {
      print('Error loading chart data: $e');
      // Set default data if error occurs
      chartData.value = [0, 0, 0, 0, 0, 0, 0];
      chartLabels.value = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      periodTotal.value = 0.0;
      periodAverage.value = 0.0;
      periodHighest.value = 0.0;
    }
  }

  Future<void> loadRecentActivities() async {
    try {
      final activities = <Map<String, dynamic>>[];
      
      // Add recent sales to activities
      for (final sale in recentSales) {
        activities.add({
          'type': 'sale',
          'title': 'New Sale: ${sale.invoiceNumber}',
          'description': 'Sale of \$${sale.total.toStringAsFixed(2)} by ${sale.employeeName}',
          'time': _getRelativeTime(sale.saleDate),
          'id': sale.id,
        });
      }
      
      // Add low stock alerts to activities
      for (final medicine in lowStockMedicines.take(3)) {
        activities.add({
          'type': 'inventory',
          'title': 'Low Stock Alert',
          'description': '${medicine.name} (${medicine.quantity} left)',
          'time': 'Now',
          'id': medicine.id,
        });
      }
      
      // Add expiring medicine alerts to activities
      for (final medicine in expiringMedicines.take(3)) {
        final daysRemaining = medicine.expiryDate.difference(DateTime.now()).inDays;
        activities.add({
          'type': 'inventory',
          'title': 'Expiring Soon',
          'description': '${medicine.name} (${daysRemaining} days left)',
          'time': 'Warning',
          'id': medicine.id,
        });
      }
      
      // Sort activities by most recent first (simplistic approach)
      activities.sort((a, b) {
        if (a['time'] == 'Now' || a['time'] == 'Warning') return -1;
        if (b['time'] == 'Now' || b['time'] == 'Warning') return 1;
        return 0;
      });
      
      recentActivities.value = activities.take(5).toList();
    } catch (e) {
      print('Error loading recent activities: $e');
      // Provide demo data if error occurs
      recentActivities.value = [
        {
          'type': 'sale',
          'title': 'New Sale',
          'description': 'Sale of \$250.00',
          'time': '5 min ago',
          'id': '',
        },
        {
          'type': 'inventory',
          'title': 'Low Stock Alert',
          'description': 'Paracetamol is running low',
          'time': '30 min ago',
          'id': '',
        },
      ];
    }
  }

  String _getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  void updateChartPeriod(String period) {
    selectedChartPeriod.value = period;
    loadChartData();
  }

  void refreshDashboard() {
    loadShopInfo();
    loadDashboardData();
  }
  
  // Navigate to specific modules
  void goToInventory() {
    Get.toNamed('/inventory');
  }
  
  void goToSales() {
    Get.toNamed('/sales');
  }
  
  void goToEmployees() {
    Get.toNamed('/employees');
  }
  
  void goToReports() {
    Get.toNamed('/sales-report');
  }
  
  void goToSettings() {
    Get.toNamed('/settings');
  }
  
  void goToSuppliers() {
    Get.toNamed('/suppliers');
  }
  
  // Get data for specific medicine details
  Future<MedicineModel?> getMedicineById(String id) async {
    try {
      return await _medicineRepository.getMedicineById(id);
    } catch (e) {
      print('Error getting medicine details: $e');
      return null;
    }
  }
  
  // Get detailed employee information
  Future<EmployeeModel?> getEmployeeById(String id) async {
    try {
      return await _employeeRepository.getEmployeeById(id);
    } catch (e) {
      print('Error getting employee details: $e');
      return null;
    }
  }
  
  // Get sales details
  Future<SaleModel?> getSaleById(String id) async {
    try {
      return await _saleRepository.getSaleById(id);
    } catch (e) {
      print('Error getting sale details: $e');
      return null;
    }
  }
  
  // Calculate revenue metrics
  double getTotalRevenue() {
    return totalSales.value;
  }
  
  double getAverageDailySales() {
    if (recentSales.isEmpty) return 0;
    
    final totalAmount = recentSales.fold(0.0, (sum, sale) => sum + sale.total);
    return totalAmount / recentSales.length;
  }
  
  int getTotalItems() {
    if (recentSales.isEmpty) return 0;
    
    return recentSales.fold(0, (sum, sale) => sum + sale.items.length);
  }
  
  // Top-selling medicine calculation
  Future<List<Map<String, dynamic>>> getTopSellingMedicines({int limit = 5}) async {
    try {
      final allSales = await _saleRepository.getAllSales();
      final Map<String, Map<String, dynamic>> medicineStats = {};
      
      // Process all sales to gather medicine stats
      for (final sale in allSales) {
        for (final item in sale.items) {
          if (medicineStats.containsKey(item.medicineId)) {
            medicineStats[item.medicineId]!['quantity'] += item.quantity;
            medicineStats[item.medicineId]!['total'] += item.finalPrice;
          } else {
            medicineStats[item.medicineId] = {
              'id': item.medicineId,
              'name': item.medicineName,
              'quantity': item.quantity,
              'total': item.finalPrice,
            };
          }
        }
      }
      
      // Convert to list and sort by quantity sold
      final sortedMedicines = medicineStats.values.toList()
        ..sort((a, b) => (b['quantity'] as int).compareTo(a['quantity'] as int));
      
      return sortedMedicines.take(limit).toList();
    } catch (e) {
      print('Error calculating top selling medicines: $e');
      return [];
    }
  }
  
  // Calculate profit for current month
  Future<double> getCurrentMonthProfit() async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
      
      final monthlySales = await _saleRepository.getSalesByDateRange(
        startDate: startOfMonth,
        endDate: endOfMonth,
      );
      
      double totalRevenue = 0.0;
      double totalCost = 0.0;
      
      for (final sale in monthlySales) {
        totalRevenue += sale.total;
        
        // Calculate cost (based on purchase price)
        for (final item in sale.items) {
          final medicine = await _medicineRepository.getMedicineById(item.medicineId);
          if (medicine != null) {
            totalCost += medicine.purchasePrice * item.quantity;
          }
        }
      }
      
      return totalRevenue - totalCost;
    } catch (e) {
      print('Error calculating monthly profit: $e');
      return 0.0;
    }
  }
}