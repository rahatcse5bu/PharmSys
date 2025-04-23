// app/modules/home/views/home_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pharma_sys/app/modules/home/controllers/home_controller.dart';
import 'package:pharma_sys/app/utils/theme.dart';
import 'package:pharma_sys/app/routes/app_routes.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:io';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pharmacy Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Get.toNamed(Routes.LOW_STOCK_ALERT);
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Get.toNamed(Routes.SETTINGS);
            },
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome message
              Obx(() => Text(
                    'Welcome, ${controller.shopOwnerName.value}',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryColor,
                    ),
                  )),
              SizedBox(height: 4.h),
              Text(
                DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()),
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              SizedBox(height: 24.h),

              // Dashboard summary cards
              _buildSummaryCards(),
              SizedBox(height: 24.h),

              // Today's Sales and Stock Alert
              Row(
                children: [
                  Expanded(
                    child: _buildTodaySalesWidget(),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: _buildAlertWidget(),
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              // Sales Chart
              _buildSalesChart(),
              SizedBox(height: 24.h),

              // Recent Activities
              _buildRecentActivities(),
              SizedBox(height: 24.h),

              // Quick Access
              _buildQuickAccess(),
              SizedBox(height:16.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppTheme.primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => controller.shopLogo.value.isNotEmpty
                    ? CircleAvatar(
                        backgroundImage: FileImage(File(controller.shopLogo.value)),
                        radius: 40.r,
                      )
                    : CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 40.r,
                        child: Icon(
                          Icons.business,
                          size: 40.r,
                          color: AppTheme.primaryColor,
                        ),
                      )),
                SizedBox(height: 8.h),
                Obx(() => Text(
                      controller.shopName.value,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
                SizedBox(height: 4.h),
                Obx(() => Text(
                      controller.shopOwnerName.value,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14.sp,
                      ),
                    )),
              ],
            ),
          ),
          _buildDrawerItem(
            icon: Icons.dashboard_outlined,
            title: 'Dashboard',
            onTap: () {
              Get.back();
            },
            selected: true,
          ),
          _buildDrawerItem(
            icon: Icons.inventory_2_outlined,
            title: 'Inventory',
            onTap: () {
              Get.back();
              Get.toNamed(Routes.INVENTORY);
            },
          ),
          _buildDrawerItem(
            icon: Icons.shopping_cart_outlined,
            title: 'Sales',
            onTap: () {
              Get.back();
              Get.toNamed(Routes.SALES);
            },
          ),
          _buildDrawerItem(
            icon: Icons.people_outline,
            title: 'Employees',
            onTap: () {
              Get.back();
              Get.toNamed(Routes.EMPLOYEES);
            },
          ),
          _buildDrawerItem(
            icon: Icons.business_center_outlined,
            title: 'Suppliers',
            onTap: () {
              Get.back();
              Get.toNamed(Routes.SUPPLIERS);
            },
          ),
          const Divider(),
          _buildDrawerItem(
            icon: Icons.settings_outlined,
            title: 'Settings',
            onTap: () {
              Get.back();
              Get.toNamed(Routes.SETTINGS);
            },
          ),
          _buildDrawerItem(
            icon: Icons.logout,
            title: 'Logout',
            onTap: () {
              controller.logout();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool selected = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: selected ? AppTheme.primaryColor : AppTheme.textSecondaryColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: selected ? AppTheme.primaryColor : AppTheme.textPrimaryColor,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: selected,
      onTap: onTap,
    );
  }

  Widget _buildSummaryCards() {
    return SizedBox(
      height: 140.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildSummaryCard(
            title: 'Total Sales',
            value: '\$${controller.totalSales.value.toStringAsFixed(2)}',
            icon: Icons.monetization_on,
            color: AppTheme.cardBlue,
            onTap: () => Get.toNamed(Routes.SALES_REPORT),
          ),
          _buildSummaryCard(
            title: 'Total Products',
            value: '${controller.totalProducts.value}',
            icon: Icons.medication,
            color: AppTheme.cardGreen,
            onTap: () => Get.toNamed(Routes.INVENTORY),
          ),
          _buildSummaryCard(
            title: 'Low Stock',
            value: '${controller.lowStockCount.value}',
            icon: Icons.warning_amber_outlined,
            color: AppTheme.cardOrange,
            onTap: () => Get.toNamed(Routes.LOW_STOCK_ALERT),
          ),
          _buildSummaryCard(
            title: 'Employees',
            value: '${controller.employeeCount.value}',
            icon: Icons.people,
            color: AppTheme.cardPurple,
            onTap: () => Get.toNamed(Routes.EMPLOYEES),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: EdgeInsets.only(right: 16.w),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          width: 160.w,
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 24.r,
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodaySalesWidget() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  color: AppTheme.primaryColor,
                  size: 20.r,
                ),
                SizedBox(width: 8.w),
                Text(
                  "Today's Sales",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Obx(() => Text(
                  '\$${controller.todaySales.value.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                )),
            SizedBox(height: 8.h),
            Obx(() => Text(
                  '${controller.todayTransactions.value} Transactions',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppTheme.textSecondaryColor,
                  ),
                )),
            SizedBox(height: 16.h),
            OutlinedButton(
              onPressed: () {
                Get.toNamed(Routes.NEW_SALE);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, size: 16.r),
                  SizedBox(width: 4.w),
                  const Text('New Sale'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertWidget() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_amber_outlined,
                  color: AppTheme.warningColor,
                  size: 20.r,
                ),
                SizedBox(width: 8.w),
                Text(
                  "Inventory Alerts",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Obx(() => Row(
                  children: [
                    _buildAlertItem(
                      count: controller.lowStockCount.value,
                      label: 'Low Stock',
                      color: AppTheme.warningColor,
                      icon: Icons.inventory_2_outlined,
                    ),
                    SizedBox(width: 16.w),
                    _buildAlertItem(
                      count: controller.expiringCount.value,
                      label: 'Expiring',
                      color: AppTheme.errorColor,
                      icon: Icons.event_busy_outlined,
                    ),
                  ],
                )),
            SizedBox(height: 16.h),
            OutlinedButton(
              onPressed: () {
                Get.toNamed(Routes.LOW_STOCK_ALERT);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.visibility, size: 16.r),
                  SizedBox(width: 4.w),
                  const Text('View Alerts'),
                ],
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.warningColor,
                side: BorderSide(color: AppTheme.warningColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertItem({
    required int count,
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20.r,
              color: color,
            ),
            SizedBox(height: 4.h),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesChart() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sales Overview',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                DropdownButton<String>(
                  value: controller.selectedChartPeriod.value,
                  underline: const SizedBox(),
                  isDense: true,
                  items: const [
                    DropdownMenuItem(value: 'Weekly', child: Text('Weekly')),
                    DropdownMenuItem(value: 'Monthly', child: Text('Monthly')),
                    DropdownMenuItem(value: 'Yearly', child: Text('Yearly')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      controller.selectedChartPeriod.value = value;
                      controller.updateChartData();
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 16.h),
            SizedBox(
              height: 200.h,
              child: Obx(() => controller.chartData.isEmpty
                  ? Center(
                      child: Text(
                        'No sales data available',
                        style: TextStyle(
                          color: AppTheme.textSecondaryColor,
                          fontSize: 14.sp,
                        ),
                      ),
                    )
                  : LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: true,
                          horizontalInterval: 1,
                          verticalInterval: 1,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: const Color(0xffe7e8ec),
                              strokeWidth: 1,
                            );
                          },
                          getDrawingVerticalLine: (value) {
                            return FlLine(
                              color: const Color(0xffe7e8ec),
                              strokeWidth: 1,
                            );
                          },
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  space: 8.0,
                                  child: Text(
                                    controller.chartLabels[value.toInt() % controller.chartLabels.length],
                                    style: TextStyle(
                                      color: AppTheme.textSecondaryColor,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  space: 8.0,
                                  child: Text(
                                    '\${value.toInt()}',
                                    style: TextStyle(
                                      color: AppTheme.textSecondaryColor,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                );
                              },
                              reservedSize: 40,
                            ),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(color: const Color(0xffe7e8ec)),
                        ),
                        minX: 0,
                        maxX: controller.chartData.length.toDouble() - 1,
                        minY: 0,
                        maxY: controller.chartData.reduce((a, b) => a > b ? a : b) * 1.2,
                        lineBarsData: [
                          LineChartBarData(
                            spots: List.generate(
                              controller.chartData.length,
                              (index) => FlSpot(index.toDouble(), controller.chartData[index]),
                            ),
                            isCurved: true,
                            color: AppTheme.primaryColor,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppTheme.primaryColor.withOpacity(0.2),
                            ),
                          ),
                        ],
                      ),
                    )),
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSalesSummaryItem(
                  label: 'Total',
                  value: '\${controller.periodTotal.value.toStringAsFixed(2)}',
                  color: AppTheme.primaryColor,
                ),
                _buildSalesSummaryItem(
                  label: 'Average',
                  value: '\${controller.periodAverage.value.toStringAsFixed(2)}',
                  color: AppTheme.infoColor,
                ),
                _buildSalesSummaryItem(
                  label: 'Highest',
                  value: '\${controller.periodHighest.value.toStringAsFixed(2)}',
                  color: AppTheme.successColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesSummaryItem({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: AppTheme.textSecondaryColor,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivities() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Activities',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Get.toNamed(Routes.SALES);
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Obx(() => controller.recentActivities.isEmpty
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      child: Text(
                        'No recent activities',
                        style: TextStyle(
                          color: AppTheme.textSecondaryColor,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  )
                : Column(
                    children: controller.recentActivities
                        .map((activity) => _buildActivityItem(activity))
                        .toList(),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    IconData getIcon() {
      switch (activity['type']) {
        case 'sale':
          return Icons.shopping_cart_outlined;
        case 'inventory':
          return Icons.inventory_2_outlined;
        case 'employee':
          return Icons.person_outline;
        default:
          return Icons.event_note_outlined;
      }
    }

    Color getColor() {
      switch (activity['type']) {
        case 'sale':
          return AppTheme.successColor;
        case 'inventory':
          return AppTheme.infoColor;
        case 'employee':
          return AppTheme.primaryColor;
        default:
          return AppTheme.textSecondaryColor;
      }
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: getColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              getIcon(),
              color: getColor(),
              size: 20.r,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['title'],
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  activity['description'],
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            activity['time'],
            style: TextStyle(
              fontSize: 12.sp,
              color: AppTheme.textTertiaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccess() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Access',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildQuickAccessItem(
              icon: Icons.add_shopping_cart,
              title: 'New Sale',
              onTap: () => Get.toNamed(Routes.NEW_SALE),
              color: AppTheme.successColor,
            ),
            _buildQuickAccessItem(
              icon: Icons.medication_liquid,
              title: 'Add Medicine',
              onTap: () => Get.toNamed(Routes.ADD_MEDICINE),
              color: AppTheme.infoColor,
            ),
            _buildQuickAccessItem(
              icon: Icons.person_add,
              title: 'Add Employee',
              onTap: () => Get.toNamed(Routes.ADD_EMPLOYEE),
              color: AppTheme.primaryColor,
            ),
            _buildQuickAccessItem(
              icon: Icons.pie_chart,
              title: 'Reports',
              onTap: () => Get.toNamed(Routes.SALES_REPORT),
              color: AppTheme.warningColor,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAccessItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: 80.w,
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 28.r,
            ),
            SizedBox(height: 8.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}