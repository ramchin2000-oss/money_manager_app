import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../Income/IncomeReportCircle.dart';

class ExpenseReportCircle extends StatefulWidget {
  final List<dynamic> categoryData;
  final TabController tapController; // Passed from parent

  const ExpenseReportCircle({
    super.key,
    required this.categoryData,
    required this.tapController,
  });

  @override
  State<ExpenseReportCircle> createState() => _ExpenseReportCircleState();
}

class _ExpenseReportCircleState extends State<ExpenseReportCircle> {
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
          // Uncomment below if TabBar is needed
          // child: TabBar(
          //   controller: widget.tapController,
          //   indicator: BoxDecoration(
          //     color: Colors.red.shade400,
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
              "Expense Breakdown",
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(width: 12),
            IconButton(
              icon: Icon(
                _showPieChart ? Icons.bar_chart : Icons.pie_chart,
                color: Colors.red.shade400,
              ),
              onPressed: () => setState(() => _showPieChart = !_showPieChart),
              tooltip: _showPieChart ? "Show Bar Chart" : "Show Pie Chart",
            ),
          ],
        ),

        const SizedBox(height: 10),

        SizedBox(
          height: MediaQuery.of(context).size.height * 0.8, // 50% of screen
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

  Widget _buildPieChart(String view) {
    final categoryMap = filterAndGroupByCategory(
      widget.categoryData,
      "Expense", // Changed here
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
      Colors.red.shade400,
      Colors.redAccent.shade400,
      Colors.deepOrange.shade400,
      Colors.orange.shade400,
      Colors.red.shade200,
      Colors.deepOrangeAccent.shade400,
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

  Widget _buildBarChart(String view) {
    final categoryMap = filterAndGroupByCategory(
      widget.categoryData,
      "Expense", // Changed here
      view,
    );

    final total = categoryMap.values.fold(0.0, (sum, v) => sum + v);

    if (categoryMap.isEmpty || total == 0) return _buildEmptyChart();

    return Column(
      children: [
        SizedBox(
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
                color: Colors.red.shade400,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildBreakdownCards(categoryMap, total, {}),
      ],
    );
  }

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

  Widget _buildBreakdownCards(
    Map<String, double> categoryMap,
    double total,
    Map<String, Color> colorMap,
  ) {
    return Column(
      children: categoryMap.entries.map((entry) {
        final percent = total == 0 ? 0 : (entry.value / total * 100);
        final color = colorMap[entry.key] ?? Colors.red.shade400;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          child: _CategoryPercentCard(
            category: entry.key,
            amount: entry.value,
            percentage: percent.toDouble(),
            color: color,
            fullWidth: true,
          ),
        );
      }).toList(),
    );
  }
}

// Reuse the same helper classes for data and cards:
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
        color: Colors.white,
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "${percentage.toStringAsFixed(1)}%",
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              ),
            ],
          ),
          Text(
            currencyFormat.format(amount),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
