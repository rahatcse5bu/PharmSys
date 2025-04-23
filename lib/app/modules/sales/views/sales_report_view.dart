// app/modules/sales/views/sales_report_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/widgets/custom_app_bar.dart';
import '../controllers/sales_controller.dart';
import '../../../core/widgets/custom_drawer.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/utils/date_formatter.dart';
import 'package:fl_chart/fl_chart.dart';

class SalesReportView extends GetView<SalesController> {
  const SalesReportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Sales Report',
      ),
      drawer: const CustomDrawer(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget();
        }
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateFilter(),
              const SizedBox(height: 16),
              _buildSummaryCards(),
              const SizedBox(height: 24),
              _buildSalesChart(context),
              const SizedBox(height: 24),
              _buildPaymentMethodDistribution(context),
              const SizedBox(height: 24),
              _buildRecentSales(),
            ],
          ),
        );
      }),
    );
  }
  
  Widget _buildDateFilter() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Date Range',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Obx(() => OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      DateFormatter.formatDateOnly(controller.startDate.value),
                    ),
                    onPressed: () => controller.showDateRangePicker(Get.context!),
                  )),
                ),
                const SizedBox(width: 8),
                const Text('to'),
                const SizedBox(width: 8),
                Expanded(
                  child: Obx(() => OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      DateFormatter.formatDateOnly(controller.endDate.value),
                    ),
                    onPressed: () => controller.showDateRangePicker(Get.context!),
                  )),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: controller.refreshSales,
                  tooltip: 'Refresh Data',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final now = DateTime.now();
                      controller.startDate.value = DateTime(now.year, now.month, now.day - 7);
                      controller.endDate.value = now;
                      controller.applyDateFilter();
                    },
                    child: const Text('Last 7 Days'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final now = DateTime.now();
                      controller.startDate.value = DateTime(now.year, now.month, 1);
                      controller.endDate.value = now;
                      controller.applyDateFilter();
                    },
                    child: const Text('This Month'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final now = DateTime.now();
                      controller.startDate.value = DateTime(now.year, 1, 1);
                      controller.endDate.value = now;
                      controller.applyDateFilter();
                    },
                    child: const Text('This Year'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSummaryCards() {
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Summary',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.5,
          children: [
            _buildSummaryCard(
              'Total Sales',
              '${controller.salesViewModel.totalSales.value}',
              Icons.point_of_sale,
              Colors.blue,
            ),
            _buildSummaryCard(
              'Total Revenue',
              '\$${controller.salesViewModel.totalRevenue.value.toStringAsFixed(2)}',
              Icons.attach_money,
              Colors.green,
            ),
            _buildSummaryCard(
              'Total Items',
              '${controller.salesViewModel.totalItems.value}',
              Icons.inventory,
              Colors.orange,
            ),
            _buildSummaryCard(
              'Average Sale',
              '\$${controller.salesViewModel.averageSaleValue.value.toStringAsFixed(2)}',
              Icons.trending_up,
              Colors.purple,
            ),
          ],
        ),
      ],
    ));
  }
  
  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: color,
              width: 4,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSalesChart(BuildContext context) {
    return Obx(() {
      // Group sales by date
      final salesByDate = <DateTime, double>{};
      
      // Get all days in the date range
      final start = controller.startDate.value;
      final end = controller.endDate.value;
      for (int i = 0; i <= end.difference(start).inDays; i++) {
        final date = start.add(Duration(days: i));
        salesByDate[DateTime(date.year, date.month, date.day)] = 0;
      }
      
      // Sum sales for each day
      for (final sale in controller.salesViewModel.filteredSales) {
        final date = DateTime(
          sale.saleDate.year,
          sale.saleDate.month,
          sale.saleDate.day,
        );
        salesByDate[date] = (salesByDate[date] ?? 0) + sale.total;
      }
      
      // Sort dates
      final sortedDates = salesByDate.keys.toList()..sort();
      
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sales Trend',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 300,
                child: salesByDate.isEmpty
                    ? const Center(child: Text('No data available'))
                    : _buildLineChart(sortedDates, salesByDate),
              ),
            ],
          ),
        ),
      );
    });
  }
  
  Widget _buildLineChart(List<DateTime> dates, Map<DateTime, double> salesByDate) {
    return LineChart(
      LineChartData(
        gridData:  FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles:  AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < dates.length) {
                  final date = dates[value.toInt()];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '${date.day}/${date.month}',
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const SizedBox();
              },
              reservedSize: 30,
            ),
          ),
          rightTitles:  AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles:  AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: true),
        minX: 0,
        maxX: dates.length - 1,
        minY: 0,
        lineBarsData: [
          LineChartBarData(
            spots: dates.asMap().entries.map((entry) {
              return FlSpot(
                entry.key.toDouble(),
                salesByDate[entry.value]!,
              );
            }).toList(),
            isCurved: true,
            color: Colors.blue,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData:  FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPaymentMethodDistribution(BuildContext context) {
    return Obx(() {
      final paymentMethods = controller.salesViewModel.paymentMethods;
      
      if (paymentMethods.isEmpty) {
        return const SizedBox();
      }
      
      final totalSales = paymentMethods.values.fold(0, (sum, count) => sum + count);
      
      // Calculate percentages
      final data = <String, double>{};
      paymentMethods.forEach((method, count) {
        data[method] = (count / totalSales) * 100;
      });
      
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Payment Methods',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: Row(
                  children: [
                    Expanded(
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                          sections: _getPieChartSections(data),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLegendItem('Cash', Colors.blue, data['cash'] ?? 0),
                        const SizedBox(height: 8),
                        _buildLegendItem('Card', Colors.green, data['card'] ?? 0),
                        const SizedBox(height: 8),
                        _buildLegendItem('Mobile', Colors.orange, data['mobile'] ?? 0),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
  
  List<PieChartSectionData> _getPieChartSections(Map<String, double> data) {
    final colors = {
      'cash': Colors.blue,
      'card': Colors.green,
      'mobile': Colors.orange,
    };
    
    return data.entries.map((entry) {
      return PieChartSectionData(
        color: colors[entry.key] ?? Colors.grey,
        value: entry.value,
        title: '${entry.value.toStringAsFixed(1)}%',
        radius: 80,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      );
    }).toList();
  }
  
  Widget _buildLegendItem(String title, Color color, double percentage) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
        ),
        const SizedBox(width: 8),
        Text('$title (${percentage.toStringAsFixed(1)}%)'),
      ],
    );
  }
  
  Widget _buildRecentSales() {
    return Obx(() {
      final sales = controller.salesViewModel.filteredSales.take(5).toList();
      
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Sales',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              sales.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No recent sales'),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: sales.length,
                      itemBuilder: (context, index) {
                        final sale = sales[index];
                        return ListTile(
                          title: Text(sale.invoiceNumber),
                          subtitle: Text(
                            '${DateFormatter.formatDate(sale.saleDate)} | ${sale.customerName ?? 'Walk-in Customer'}',
                          ),
                          trailing: Text(
                            '\$${sale.total.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: sale.paymentStatus == 'paid'
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ),
                          onTap: () async {
                            await controller.getSaleDetails(sale.id);
                            // Navigate to sale details or show dialog
                          },
                        );
                      },
                    ),
            ],
          ),
        ),
      );
    });
  }
}