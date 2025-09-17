import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/// -------------------
///  UTILITY FUNCTION
/// -------------------
Map<String, double> filterAndGroupByCategory(
  List<dynamic> transactions,
  String typeFilter,
  String view,
) {
  final Map<String, double> groupedData = {};
  final now = DateTime.now();

  for (var txn in transactions) {
    if (txn['type'] != typeFilter) continue;

    double amount = 0;
    if (txn['amount'] is num) {
      amount = (txn['amount'] as num).toDouble();
    } else {
      amount = double.tryParse(txn['amount'].toString()) ?? 0;
    }

    DateTime date = DateTime.parse(txn['date']).toLocal();

    // ✅ Apply date filter
    bool include = false;
    if (view == "Year" && date.year == now.year) {
      include = true;
    } else if (view == "Month" &&
        date.year == now.year &&
        date.month == now.month) {
      include = true;
    } else if (view == "Week") {
      final currentWeek = ((now.day - 1) ~/ 7) + 1;
      final txnWeek = ((date.day - 1) ~/ 7) + 1;
      if (date.year == now.year &&
          date.month == now.month &&
          txnWeek == currentWeek) {
        include = true;
      }
    }

    if (!include) continue;

    // ✅ Group by category instead of date
    final key = txn['category'] ?? "Unknown";
    groupedData[key] = (groupedData[key] ?? 0) + amount;
  }

  return groupedData;
}

/// -------------------
///  INCOME REPORT WIDGET
/// -------------------
class IncomeReportCircle extends StatefulWidget {
  final List<dynamic> categoryData;
  final TabController tapController; // Passed from parent

  const IncomeReportCircle({
    super.key,
    required this.categoryData,
    required this.tapController,
  });

  @override
  State<IncomeReportCircle> createState() => _IncomeReportCircleState();
}

class _IncomeReportCircleState extends State<IncomeReportCircle> {
  final List<String> _views = ["Year", "Month", "Week"];
  bool _showPieChart = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // --- TabBar for Year/Month/Week ---
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
          // child: TabBar(
          //   controller: widget.tapController,
          //   indicator: BoxDecoration(
          //     color: Colors.teal,
          //     borderRadius: BorderRadius.circular(16),
          //   ),
          //   labelColor: Colors.white,
          //   unselectedLabelColor: Colors.black87,
          //   tabs: _views.map((e) => Tab(text: e)).toList(),
          // ),
        ),

        const SizedBox(height: 8),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Income Breakdown",
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(width: 12),
            IconButton(
              icon: Icon(
                _showPieChart ? Icons.bar_chart : Icons.pie_chart,
                color: Colors.teal,
              ),
              onPressed: () => setState(() => _showPieChart = !_showPieChart),
              tooltip: _showPieChart ? "Show Bar Chart" : "Show Pie Chart",
            ),
          ],
        ),

        const SizedBox(height: 10),

        // --- TabBarView for charts ---
        SizedBox(
          height: 500,
          child: TabBarView(
            controller: widget.tapController,
            children: _views.map((view) {
              return _showPieChart
                  ? _buildPieChart(view)
                  : _buildBarChart(view);
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// -------------------
  /// PIE CHART
  /// -------------------
  Widget _buildPieChart(String view) {
    final categoryMap = filterAndGroupByCategory(
      widget.categoryData,
      "Income",
      view,
    );

    final total = categoryMap.values.fold(0.0, (sum, v) => sum + v);

    if (categoryMap.isEmpty || total == 0) return _buildEmptyChart();

    final List<_PieData> pieData = categoryMap.entries
        .map(
          (e) =>
              _PieData(e.key, e.value, total == 0 ? 0 : e.value / total * 100),
        )
        .toList();

    final List<Color> palette = [
      Colors.green.shade400,
      Colors.teal.shade400,
      Colors.lightGreen.shade400,
      Colors.lime.shade400,
      Colors.greenAccent.shade400,
      Colors.tealAccent.shade400,
      Colors.lightGreenAccent.shade400,
    ];

    final Map<String, Color> colorMap = {};
    int colorIndex = 0;
    for (var key in categoryMap.keys) {
      colorMap[key] = palette[colorIndex % palette.length];
      colorIndex++;
    }

    return Column(
      children: [
        SizedBox(
          height: 300,
          child: SfCircularChart(
            legend: Legend(
              isVisible: true,
              overflowMode: LegendItemOverflowMode.wrap,
              position: LegendPosition.bottom,
              textStyle: const TextStyle(fontSize: 12),
            ),
            tooltipBehavior: TooltipBehavior(
              enable: true,
              format: 'point.x : ₹point.y',
            ),
            series: <PieSeries<_PieData, String>>[
              PieSeries<_PieData, String>(
                dataSource: pieData,
                xValueMapper: (data, _) => data.category,
                yValueMapper: (data, _) => data.amount,
                dataLabelMapper: (data, _) =>
                    "${data.category}\n${data.percent.toStringAsFixed(1)}%",
                dataLabelSettings: const DataLabelSettings(
                  isVisible: true,
                  labelPosition: ChartDataLabelPosition.outside,
                  connectorLineSettings: ConnectorLineSettings(
                    type: ConnectorType.curve,
                  ),
                  textStyle: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                pointColorMapper: (data, _) => colorMap[data.category],
                radius: '90%',
                startAngle: 90,
                endAngle: 450,
                explode: true,
                explodeIndex: 0,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildBreakdownCards(categoryMap, total, colorMap),
      ],
    );
  }

  /// -------------------
  /// BAR CHART
  /// -------------------
  Widget _buildBarChart(String view) {
    final categoryMap = filterAndGroupByCategory(
      widget.categoryData,
      "Income",
      view,
    );

    final total = categoryMap.values.fold(0.0, (sum, v) => sum + v);

    if (categoryMap.isEmpty || total == 0) return _buildEmptyChart();

    return Column(
      children: [
        SizedBox(
          // height: 100,
          child: SfCartesianChart(
            primaryXAxis: CategoryAxis(),
            tooltipBehavior: TooltipBehavior(enable: true),
            series: <CartesianSeries<ChartData, String>>[
              ColumnSeries<ChartData, String>(
                dataSource: categoryMap.entries
                    .map((e) => ChartData(e.key, e.value))
                    .toList(),
                xValueMapper: (data, _) => data.category,
                yValueMapper: (data, _) => data.amount,
                dataLabelSettings: const DataLabelSettings(isVisible: true),
                color: Colors.teal,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildBreakdownCards(categoryMap, total, {}),
      ],
    );
  }

  /// -------------------
  /// EMPTY STATE
  /// -------------------
  Widget _buildEmptyChart() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.insert_chart_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            "No data available",
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  /// -------------------
  /// BREAKDOWN CARDS
  /// -------------------
  Widget _buildBreakdownCards(
    Map<String, double> categoryMap,
    double total,
    Map<String, Color> colorMap,
  ) {
    return Column(
      children: categoryMap.entries.map((entry) {
        final percent = total == 0 ? 0 : (entry.value / total * 100);
        final color = colorMap[entry.key] ?? Colors.teal;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          child: _CategoryPercentCard(
            category: entry.key,
            amount: entry.value,
            percentage: percent.toDouble(),
            color: color,
            fullWidth: true, // ✅ make card take full row
          ),
        );
      }).toList(),
    );
  }
}

/// -------------------
/// DATA CLASSES
/// -------------------
class _PieData {
  final String category;
  final double amount;
  final double percent;
  _PieData(this.category, this.amount, this.percent);
}

class ChartData {
  final String category;
  final num amount;
  ChartData(this.category, this.amount);
}

class _CategoryPercentCard extends StatelessWidget {
  final String category;
  final double amount;
  final double percentage;
  final Color color;
  final bool fullWidth;

  const _CategoryPercentCard({
    required this.category,
    required this.amount,
    required this.percentage,
    required this.color,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: "₹", decimalDigits: 2);

    return Container(
      width: fullWidth ? double.infinity : 160,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white, // ✅ white background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Category + Percentage
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: color, // ✅ category color
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "${percentage.toStringAsFixed(1)}%",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                ), // ✅ softer
              ),
            ],
          ),

          // Amount
          Text(
            currencyFormat.format(amount),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87, // ✅ darker text for amount
            ),
          ),
        ],
      ),
    );
  }
}
