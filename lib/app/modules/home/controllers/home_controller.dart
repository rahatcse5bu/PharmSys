// app/modules/home/controllers/home_controller.dart

import 'package:get/get.dart';
import 'package:pharma_sys/app/data/repositories/medicine_repository.dart';
import 'package:pharma_sys/app/data/repositories/sale_repository.dart';
import 'package:pharma_sys/app/data/repositories/employee_repository.dart';
import 'package:pharma_sys/app/data/repositories/shop_repository.dart';
import 'package:pharma_sys/app/routes/app_routes.dart';
import 'package:intl/intl.dart';

class HomeController extends GetxController {
  final MedicineRepository medicineRepository;
  final SaleRepository saleRepository;
  final EmployeeRepository employeeRepository;
  final ShopRepository shopRepository;

  // Shop information
  final RxString shopName = ''.obs;
  final RxString shopOwnerName = ''.obs;
  final RxString shopLogo = ''.obs;

  // Dashboard statistics
  final RxDouble totalSales = 0.0.obs;
  final RxInt totalProducts = 0.obs;
  final RxInt lowStockCount = 0.obs;
  final RxInt expiringCount = 0.obs;
  final RxInt employeeCount = 0.obs;
  final RxDouble todaySales = 0.0.obs;
  final RxInt todayTransactions = 0.obs;

  // Sales chart data
  final RxString selectedChartPeriod = 'Weekly'.obs;
  final RxList<double> chartData = <double>[].obs;
  final RxList<String> chartLabels = <String>[].obs;
  final RxDouble periodTotal = 0.0.obs;
  final RxDouble periodAverage = 0.0.obs;
  final RxDouble periodHighest = 0.0.obs;

  // Recent activities
  final RxList<Map<String, dynamic>> recentActivities = <Map<String, dynamic>>[].obs;

  // Loading status
  final RxBool isLoading = false.obs;

  HomeController({
    required this.medicineRepository,
    required this.saleRepository,
    required this.employeeRepository,
    required this.shopRepository,
  });

  @override
  void onInit() {
    super.onInit();
    loadShopInfo();
    loadDashboardData();
    loadChartData();
    loadRecentActivities();
  }

  Future<void> loadShopInfo() async {
    try {
      final shop = await shopRepository.getShopInfo();
      if (shop != null) {
        shopName.value = shop.name;
        shopOwnerName.value = shop.ownerName ?? 'Shop Owner';
        shopLogo.value = shop.logo ?? '';
      }
    } catch (e) {
      print('Error loading shop info: $e');
    }
  }

  Future<void> loadDashboardData() async {
    try {
      isLoading.value = true;

      // Get total products, low stock and expiring counts
      final medicines = await medicineRepository.getAllMedicines();
      totalProducts.value = medicines.length;
      
      final lowStockMeds = await medicineRepository.getLowStockMedicines();
      lowStockCount.value = lowStockMeds.length;
      
      final expiringMeds = await medicineRepository.getExpiringMedicines();
      expiringCount.value = expiringMeds.length;

      // Get employee count
      final employees = await employeeRepository.getAllEmployees();
      employeeCount.value = employees.length;

      // Get total sales
      final sales = await saleRepository.getAllSales();
      totalSales.value = sales.fold(0, (prev, sale) => prev + sale.total);

      // Get today's sales
      final todayStart = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      );
      final todaySalesList = await saleRepository.getSalesByDateRange(
        startDate: todayStart,
        endDate: DateTime.now(),
      );
      
      todaySales.value = todaySalesList.fold(0, (prev, sale) => prev + sale.total);
      todayTransactions.value = todaySalesList.length;

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      print('Error loading dashboard data: $e');
    }
  }

  Future<void> loadChartData() async {
    try {
      // Generate sample data for now - in real app, this would come from the database
      chartData.clear();
      chartLabels.clear();

      DateTime now = DateTime.now();
      List<double> data = [];
      List<String> labels = [];

      switch (selectedChartPeriod.value) {
        case 'Weekly':
          // Get sales for each day of the current week
          for (int i = 6; i >= 0; i--) {
            final date = now.subtract(Duration(days: i));
            final startOfDay = DateTime(date.year, date.month, date.day);
            final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
            
            final daySales = await saleRepository.getSalesByDateRange(
              startDate: startOfDay,
              endDate: endOfDay,
            );
            
            double dailyTotal = daySales.fold(0, (prev, sale) => prev + sale.total);
            data.add(dailyTotal);
            labels.add(DateFormat('EEE').format(date));
          }
          break;
        
        case 'Monthly':
          // Get sales for each week of the current month
          final startOfMonth = DateTime(now.year, now.month, 1);
          final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
          
          for (int week = 0; week < 4; week++) {
            final weekStartDay = week * 7 + 1;
            final weekEndDay = (week + 1) * 7;
            
            final startDate = DateTime(now.year, now.month, weekStartDay > daysInMonth ? daysInMonth : weekStartDay);
            final endDate = DateTime(now.year, now.month, weekEndDay > daysInMonth ? daysInMonth : weekEndDay, 23, 59, 59);
            
            final weekSales = await saleRepository.getSalesByDateRange(
              startDate: startDate,
              endDate: endDate,
            );
            
            double weeklyTotal = weekSales.fold(0, (prev, sale) => prev + sale.total);
            data.add(weeklyTotal);
            labels.add('Week ${week + 1}');
          }
          break;
        
        case 'Yearly':
          // Get sales for each month of the current year
          for (int month = 1; month <= 12; month++) {
            final startDate = DateTime(now.year, month, 1);
            final endDate = DateTime(now.year, month + 1, 0, 23, 59, 59);
            
            final monthSales = await saleRepository.getSalesByDateRange(
              startDate: startDate,
              endDate: endDate,
            );
            
            double monthlyTotal = monthSales.fold(0, (prev, sale) => prev + sale.total);
            data.add(monthlyTotal);
            labels.add(DateFormat('MMM').format(DateTime(now.year, month)));
          }
          break;
      }

      chartData.value = data;
      chartLabels.value = labels;

      // Calculate summary stats
      if (data.isNotEmpty) {
        periodTotal.value = data.reduce((a, b) => a + b);
        periodAverage.value = periodTotal.value / data.length;
        periodHighest.value = data.reduce((a, b) => a > b ? a : b);
      } else {
        periodTotal.value = 0;
        periodAverage.value = 0;
        periodHighest.value = 0;
      }
    } catch (e) {
      print('Error loading chart data: $e');
      // Set default values
      chartData.value = [0, 0, 0, 0, 0, 0, 0];
      switch (selectedChartPeriod.value) {
        case 'Weekly':
          chartLabels.value = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
          break;
        case 'Monthly':
          chartLabels.value = ['Week 1', 'Week 2', 'Week 3', 'Week 4'];
          break;
        case 'Yearly':
          chartLabels.value = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
          break;
      }
      periodTotal.value = 0;
      periodAverage.value = 0;
      periodHighest.value = 0;
    }
  }

  void updateChartData() {
    loadChartData();
  }

  Future<void> loadRecentActivities() async {
    try {
      // This would typically be populated from the database
      // For now, we'll create sample data
      recentActivities.value = [
        {
          'type': 'sale',
          'title': 'New Sale',
          'description': 'Sale of \$250.00 by John Doe',
          'time': '5 min ago',
        },
        {
          'type': 'inventory',
          'title': 'Low Stock Alert',
          'description': 'Paracetamol 500mg is running low',
          'time': '1 hour ago',
        },
        {
          'type': 'employee',
          'title': 'Employee Login',
          'description': 'Jane Smith logged in for shift',
          'time': '2 hours ago',
        },
        {
          'type': 'inventory',
          'title': 'New Medicine Added',
          'description': 'Added Amoxicillin 250mg to inventory',
          'time': '3 hours ago',
        },
        {
          'type': 'sale',
          'title': 'New Sale',
          'description': "Sale of \$120.75 by Jane Smith'",
          'time': '5 hours ago',
        },
      ];
    } catch (e) {
      print('Error loading recent activities: $e');
    }
  }

  void logout() {
    // Handle logout logic - clear user session, etc.
    Get.offAllNamed(Routes.LOGIN);
  }
}