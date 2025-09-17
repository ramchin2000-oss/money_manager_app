import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class OverallStatsPage extends StatefulWidget {
  final List<dynamic> transactions;

  const OverallStatsPage({Key? key, required this.transactions})
    : super(key: key);

  @override
  State<OverallStatsPage> createState() => _OverallStatsPageState();
}

class _ChartData {
  final String category;
  final double amount;
  _ChartData(this.category, this.amount);
}

class _PieChartData {
  final String category;
  final double amount;
  final Color color;

  _PieChartData(this.category, this.amount, this.color);
}

class _OverallStatsPageState extends State<OverallStatsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showPieChart = true;

  String currentView = "Year";
  int? filterYear;
  int? filterMonth;
  int? filterWeek;

  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);

    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        currentView = ["Year", "Month", "Week"][_tabController.index];

        // On tab change, reset filters for unused scopes
        if (currentView == "Year") {
          filterMonth = null;
          filterWeek = null;
        } else if (currentView == "Month") {
          filterWeek = null;
        }
      });
    }
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  int weekNumber(DateTime date) => ((date.day - 1) ~/ 7) + 1;

  List<Map<String, dynamic>> getFourWeeksInMonth(int year, int month) {
    final List<Map<String, dynamic>> weeks = [];
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);
    for (var i = 0; i < 4; i++) {
      final startDay = i * 7 + 1;
      final endDay = i == 3 ? lastDay.day : (i + 1) * 7;
      final start = DateTime(year, month, startDay);
      final end = DateTime(year, month, endDay);
      if (start.isAfter(lastDay)) break;
      weeks.add({
        'index': i + 1,
        'start': start,
        'end': end,
        'label': 'Week ${i + 1} (${start.day}-${end.day})',
      });
    }
    return weeks;
  }

  /// Correctly group transactions (for Income/Expense) and transfers by filtered period
  Map<String, double> filterAndGroupByPeriod(String type) {
    final Map<String, double> groupedData = {};
    final now = DateTime.now();

    int yearToShow = filterYear ?? now.year;
    int monthToShow = filterMonth ?? now.month;
    int weekToShow = filterWeek ?? weekNumber(now);

    for (var txn in widget.transactions) {
      if ((txn['type'] ?? type) != type) continue;

      double amount;
      if (txn['amount'] is num) {
        amount = (txn['amount'] as num).toDouble();
      } else {
        amount = double.tryParse(txn['amount'].toString()) ?? 0;
      }

      // All records are required to have a "date" field
      DateTime date = DateTime.parse(txn['date']).toLocal();

      bool include = false;
      String key = '';
      if (currentView == "Year") {
        if (date.year == yearToShow) {
          include = true;
          key = DateFormat('MMM yyyy').format(DateTime(date.year, date.month));
        }
      } else if (currentView == "Month") {
        if (date.year == yearToShow && date.month == monthToShow) {
          include = true;
          int wk = weekNumber(date);
          final weeks = getFourWeeksInMonth(yearToShow, monthToShow);
          key = (wk >= 1 && wk <= weeks.length)
              ? weeks[wk - 1]['label']
              : 'Week $wk';
        }
      } else if (currentView == "Week") {
        final weeks = getFourWeeksInMonth(yearToShow, monthToShow);
        final selectedWeek = (weekToShow >= 1 && weekToShow <= weeks.length)
            ? weeks[weekToShow - 1]
            : weeks[0];
        final start = selectedWeek['start'];
        final end = selectedWeek['end'];
        if (!date.isBefore(start) && !date.isAfter(end)) {
          include = true;
          key = DateFormat('EEE, d MMM').format(date);
        }
      }

      if (!include) continue;
      groupedData[key] = (groupedData[key] ?? 0) + amount;
    }

    return groupedData;
  }

  double getTotalForType(String type) {
    final map = filterAndGroupByPeriod(type);
    return map.values.fold(0.0, (sum, v) => sum + v);
  }

  Future<void> _showFilterDialog() async {
    int? selectedYear = filterYear;
    int? selectedMonth = filterMonth;
    int? selectedWeek = filterWeek;

    bool hasChanged() =>
        filterYear != selectedYear ||
        filterMonth != selectedMonth ||
        filterWeek != selectedWeek;

    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: StatefulBuilder(
              builder: (context, setState) {
                Future<void> _showPickerBottomSheet({
                  required String title,
                  required int min,
                  required int max,
                  required int? currentValue,
                  required Function(int) onSelected,
                  required String Function(int) display,
                }) async {
                  int tempValue = currentValue ?? min;
                  await showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (ctx) {
                      return Container(
                        height: 250,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Column(
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: ListWheelScrollView.useDelegate(
                                itemExtent: 45,
                                diameterRatio: 1.2,
                                physics: const FixedExtentScrollPhysics(),
                                onSelectedItemChanged: (index) {
                                  tempValue = min + index;
                                },
                                childDelegate: ListWheelChildBuilderDelegate(
                                  builder: (context, index) {
                                    if (index < 0 || index > (max - min)) {
                                      return null;
                                    }
                                    return Center(
                                      child: Text(
                                        display(min + index),
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                    );
                                  },
                                  childCount: max - min + 1,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                onSelected(tempValue);
                                Navigator.pop(ctx);
                              },
                              child: const Text("Select"),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      );
                    },
                  );
                }

                Widget pickerButton({
                  required String title,
                  required IconData icon,
                  String? valueText,
                  required VoidCallback onTap,
                  bool enabled = true,
                }) {
                  return ElevatedButton(
                    onPressed: enabled ? onTap : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: enabled
                          ? Colors.blueGrey.shade50
                          : Colors.grey.shade300,
                      foregroundColor: enabled
                          ? Colors.black
                          : Colors.grey.shade700,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              icon,
                              color: enabled
                                  ? Colors.blueGrey.shade700
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              title,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: enabled ? Colors.black : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          valueText ?? "Select",
                          style: TextStyle(
                            color: enabled ? Colors.grey : Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                String weekLabel(int weekNumber) {
                  if (selectedYear != null && selectedMonth != null) {
                    final weeks = getFourWeeksInMonth(
                      selectedYear!,
                      selectedMonth!,
                    );
                    if (weekNumber >= 1 && weekNumber <= weeks.length) {
                      final w = weeks[weekNumber - 1];
                      return 'Week $weekNumber (${w['start'].day}-${w['end'].day})';
                    }
                  }
                  return "Week $weekNumber";
                }

                final yearEnabled = true;
                final monthEnabled = currentView != "Year";
                final weekEnabled = currentView == "Week";

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Filter Report",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    pickerButton(
                      title: "Year",
                      icon: Icons.calendar_today,
                      valueText: selectedYear?.toString(),
                      onTap: () async {
                        await _showPickerBottomSheet(
                          title: "Select Year",
                          min: DateTime.now().year - 20,
                          max: DateTime.now().year,
                          currentValue: selectedYear,
                          display: (v) => "$v",
                          onSelected: (v) {
                            setState(() {
                              selectedYear = v;
                              if (filterYear != v) {
                                selectedMonth = null;
                                selectedWeek = null;
                              }
                            });
                          },
                        );
                      },
                      enabled: yearEnabled,
                    ),
                    const SizedBox(height: 20),
                    pickerButton(
                      title: "Month",
                      icon: Icons.date_range,
                      valueText: selectedMonth != null
                          ? DateFormat(
                              'MMM',
                            ).format(DateTime(0, selectedMonth!))
                          : null,
                      onTap: () async {
                        if (!monthEnabled) return;
                        await _showPickerBottomSheet(
                          title: "Select Month",
                          min: 1,
                          max: 12,
                          currentValue: selectedMonth,
                          display: (v) =>
                              DateFormat('MMM').format(DateTime(0, v)),
                          onSelected: (v) {
                            setState(() {
                              selectedMonth = v;
                              selectedWeek = null;
                            });
                          },
                        );
                      },
                      enabled: monthEnabled,
                    ),
                    if (weekEnabled) ...[
                      const SizedBox(height: 20),
                      pickerButton(
                        title: "Week",
                        icon: Icons.calendar_view_week,
                        valueText: selectedWeek != null
                            ? weekLabel(selectedWeek!)
                            : null,
                        onTap: () async {
                          if (!weekEnabled) return;
                          int maxWeek = 4;
                          if (selectedYear != null && selectedMonth != null) {
                            final weeks = getFourWeeksInMonth(
                              selectedYear!,
                              selectedMonth!,
                            );
                            maxWeek = weeks.length;
                          }
                          await _showPickerBottomSheet(
                            title: "Select Week",
                            min: 1,
                            max: maxWeek,
                            currentValue: selectedWeek,
                            display: (v) => weekLabel(v),
                            onSelected: (v) => setState(() => selectedWeek = v),
                          );
                        },
                        enabled: weekEnabled,
                      ),
                    ],
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              filterYear = null;
                              filterMonth = null;
                              filterWeek = null;
                            });
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade300,
                            foregroundColor: Colors.black,
                            minimumSize: const Size(120, 40),
                          ),
                          child: const Text("Clear"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (!hasChanged()) {
                              Navigator.pop(context);
                              return;
                            }
                            setState(() {
                              filterYear = selectedYear;
                              filterMonth = selectedMonth;
                              filterWeek = selectedWeek;
                            });
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            minimumSize: const Size(120, 40),
                          ),
                          child: const Text("Apply"),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  String _subtitleLabel() {
    final now = DateTime.now();
    if (currentView == "Year") {
      return "Year: ${filterYear ?? now.year}";
    } else if (currentView == "Month") {
      final y = filterYear ?? now.year;
      final m = filterMonth ?? now.month;
      return DateFormat('MMM yyyy').format(DateTime(y, m));
    } else {
      final y = filterYear ?? now.year;
      final m = filterMonth ?? now.month;
      final w = filterWeek ?? weekNumber(DateTime.now());
      return "Week $w, ${DateFormat('MMM yyyy').format(DateTime(y, m))}";
    }
  }

  @override
  Widget build(BuildContext context) {
    final incomeData = filterAndGroupByPeriod("Income");
    final expenseData = filterAndGroupByPeriod("Expense");

    final totalIncome = incomeData.values.fold(0.0, (a, b) => a + b);
    final totalExpense = expenseData.values.fold(0.0, (a, b) => a + b);

    final double grandTotal = totalIncome + totalExpense;

    final List<_PieChartData> pieChartData = [
      _PieChartData('Income', totalIncome, Colors.green.shade400),
      _PieChartData('Expense', totalExpense, Colors.red.shade400),
    ];

    final List<_ChartData> barChartData = [
      _ChartData('Income', totalIncome),
      _ChartData('Expense', totalExpense),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Overall Stats'),
        backgroundColor: Colors.grey.shade200,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_outlined, color: Colors.black87),
            onPressed: _showFilterDialog,
            tooltip: 'Filters',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: () {
              setState(() {});
            },
            tooltip: 'Refresh',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.teal,
          tabs: const [
            Tab(text: 'Year'),
            Tab(text: 'Month'),
            Tab(text: 'Week'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: TabBarView(
          controller: _tabController,
          children: List.generate(3, (_) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 5,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xff4caf50),
                            // Color(0xff2196f3),
                            Color(0xfff44336),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 30,
                        horizontal: 18,
                      ),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: grandTotal),
                        duration: const Duration(milliseconds: 800),
                        builder: (context, value, _) => Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Total Amount',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _subtitleLabel(),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '₹${value.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 350,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "OverAll Breakdown",
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              icon: Icon(
                                _showPieChart
                                    ? Icons.bar_chart
                                    : Icons.pie_chart,
                                color: Colors.red.shade400,
                              ),
                              onPressed: () => setState(
                                () => _showPieChart = !_showPieChart,
                              ),
                              tooltip: _showPieChart
                                  ? "Show Bar Chart"
                                  : "Show Pie Chart",
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: _showPieChart
                              ? SfCircularChart(
                                  legend: Legend(
                                    isVisible: true,
                                    overflowMode: LegendItemOverflowMode.wrap,
                                    position: LegendPosition.bottom,
                                    textStyle: const TextStyle(fontSize: 14),
                                  ),
                                  tooltipBehavior: TooltipBehavior(
                                    enable: true,
                                  ),
                                  series: <PieSeries<_PieChartData, String>>[
                                    PieSeries<_PieChartData, String>(
                                      dataSource: pieChartData,
                                      xValueMapper: (data, _) => data.category,
                                      yValueMapper: (data, _) => data.amount,
                                      pointColorMapper: (data, _) => data.color,
                                      dataLabelMapper: (data, _) =>
                                          '${data.category}\n${(grandTotal == 0 ? 0 : data.amount / grandTotal * 100).toStringAsFixed(1)}%',
                                      dataLabelSettings:
                                          const DataLabelSettings(
                                            isVisible: true,
                                            labelPosition:
                                                ChartDataLabelPosition.outside,
                                          ),
                                      explode: true,
                                      explodeIndex: 0,
                                    ),
                                  ],
                                )
                              : SfCartesianChart(
                                  primaryXAxis: CategoryAxis(),
                                  primaryYAxis: NumericAxis(
                                    minimum: 0,
                                    edgeLabelPlacement:
                                        EdgeLabelPlacement.shift,
                                    labelFormat: '₹{value}',
                                  ),
                                  tooltipBehavior: TooltipBehavior(
                                    enable: true,
                                  ),
                                  series: <ColumnSeries<_ChartData, String>>[
                                    ColumnSeries<_ChartData, String>(
                                      dataSource: barChartData,
                                      xValueMapper: (data, _) => data.category,
                                      yValueMapper: (data, _) => data.amount,
                                      dataLabelSettings:
                                          const DataLabelSettings(
                                            isVisible: true,
                                          ),
                                      pointColorMapper: (data, _) {
                                        switch (data.category) {
                                          case 'Income':
                                            return Colors.green.shade600;
                                          case 'Expense':
                                            return Colors.red.shade600;
                                          default:
                                            return Colors.blue.shade600;
                                        }
                                      },
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(12),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),
                  Text(
                    'Breakdown by Type',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...pieChartData.map((e) {
                    final percent = grandTotal == 0
                        ? 0
                        : e.amount / grandTotal * 100;
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: e.color.withOpacity(0.3),
                          child: Icon(
                            e.category == 'Income'
                                ? Icons.currency_rupee
                                : e.category == 'Expense'
                                ? Icons.currency_rupee
                                : Icons.sync_alt,
                            color: e.color,
                          ),
                        ),
                        title: Text(
                          e.category,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        trailing: Text(
                          '₹${e.amount.toStringAsFixed(2)}\n${percent.toStringAsFixed(1)}%',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: e.color,
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 40),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
