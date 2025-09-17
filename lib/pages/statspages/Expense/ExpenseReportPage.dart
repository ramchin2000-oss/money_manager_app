import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'ExpenseReportCircle.dart';

class ExpenseReportPage extends StatefulWidget {
  final List<dynamic> transactions;

  const ExpenseReportPage({super.key, required this.transactions});

  @override
  State<ExpenseReportPage> createState() => _ExpenseReportPageState();
}

class _ChartData {
  final String period;
  final double amount;
  _ChartData(this.period, this.amount);
}

class _ExpenseReportPageState extends State<ExpenseReportPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, double> groupedExpense = {};
  double totalExpense = 0;
  String currentView = "Year";

  int? filterYear;
  int? filterMonth;
  int? filterWeek;

  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        currentView = ["Year", "Month", "Week"][_tabController.index];
        _calculateExpense();
        setState(() {});
      }
    });

    _calculateExpense();

    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _calculateExpense();
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  int weekNumber(DateTime date) {
    // used only for current week display
    return ((date.day - 1) ~/ 7) + 1;
  }

  List<Map<String, dynamic>> getFourWeeksInMonth(int year, int month) {
    final List<Map<String, dynamic>> weeks = [];
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);
    for (int i = 0; i < 4; i++) {
      final startDay = (i * 7) + 1;
      final endDay = i == 3 ? lastDay.day : ((i + 1) * 7);
      final start = DateTime(year, month, startDay);
      final end = DateTime(year, month, endDay);
      if (start.isAfter(lastDay)) break;
      weeks.add({
        'index': i + 1,
        'start': start,
        'end': end,
        'label': "Week ${i + 1} (${start.day}-${end.day})",
      });
    }
    return weeks;
  }

  void _calculateExpense() {
    groupedExpense.clear();
    totalExpense = 0;
    final now = DateTime.now();

    if (currentView == "Year") {
      final int yearToShow = filterYear ?? now.year;
      for (var txn in widget.transactions) {
        if (txn['type'] != 'Expense') continue;
        double amt = txn['amount'] is num
            ? (txn['amount'] as num).toDouble()
            : double.tryParse(txn['amount'].toString()) ?? 0;
        DateTime date = DateTime.parse(txn['date']).toLocal();
        if (date.year != yearToShow) continue;
        String key = DateFormat(
          'MMM yyyy',
        ).format(DateTime(date.year, date.month));
        groupedExpense[key] = (groupedExpense[key] ?? 0) + amt;
      }
      totalExpense = groupedExpense.values.fold(0.0, (a, b) => a + b);
      groupedExpense = Map.fromEntries(
        groupedExpense.entries.toList()..sort((a, b) {
          final da = DateFormat('MMM yyyy').parse(a.key);
          final db = DateFormat('MMM yyyy').parse(b.key);
          return db.compareTo(da);
        }),
      );
    } else if (currentView == "Month") {
      final int yearToShow = filterYear ?? now.year;
      final int monthToShow = filterMonth ?? now.month;
      final weeks = getFourWeeksInMonth(yearToShow, monthToShow);

      Map<int, double> weekTotals = {};
      for (var txn in widget.transactions) {
        if (txn['type'] != 'Expense') continue;
        double amt = txn['amount'] is num
            ? (txn['amount'] as num).toDouble()
            : double.tryParse(txn['amount'].toString()) ?? 0;
        DateTime date = DateTime.parse(txn['date']).toLocal();
        if (date.year != yearToShow || date.month != monthToShow) continue;
        int weekIdx = weekNumber(date);
        if (weekIdx >= 1 && weekIdx <= 4) {
          weekTotals[weekIdx] = (weekTotals[weekIdx] ?? 0) + amt;
        }
      }
      // Only weekly breakdown
      for (var w in weeks) {
        final label = w['label'];
        final weekAmt = weekTotals[w['index']] ?? 0;
        groupedExpense[label] = weekAmt;
      }
      totalExpense = weekTotals.values.fold(0.0, (a, b) => a + b);
    } else if (currentView == "Week") {
      final DateTime nowDt = now;
      final int yearToShow = filterYear ?? nowDt.year;
      final int monthToShow = filterMonth ?? nowDt.month;
      final weeks = getFourWeeksInMonth(yearToShow, monthToShow);

      int selWeekIdx = filterWeek ?? weekNumber(nowDt);
      if (selWeekIdx < 1 || selWeekIdx > weeks.length) selWeekIdx = 1;
      final selectedWeek = weeks[selWeekIdx - 1];

      Map<String, double> tempMap = {};
      Map<String, DateTime> keyToDate = {};

      for (var txn in widget.transactions) {
        if (txn['type'] != 'Expense') continue;
        double amt = txn['amount'] is num
            ? (txn['amount'] as num).toDouble()
            : double.tryParse(txn['amount'].toString()) ?? 0;
        DateTime date = DateTime.parse(txn['date']).toLocal();
        if (date.isBefore(selectedWeek['start']) ||
            date.isAfter(selectedWeek['end']))
          continue;
        String key = DateFormat('EEE, d MMM').format(date);
        tempMap[key] = (tempMap[key] ?? 0) + amt;
        keyToDate[key] = date;
      }

      // Show current day first, then others chronologically
      String todayKey = DateFormat('EEE, d MMM').format(nowDt);
      var entries = tempMap.entries.toList()
        ..sort((a, b) {
          if (a.key == todayKey) return -1;
          if (b.key == todayKey) return 1;
          // otherwise sort by date
          return keyToDate[a.key]!.compareTo(keyToDate[b.key]!);
        });

      groupedExpense = Map.fromEntries(entries);
      totalExpense = tempMap.values.fold(0.0, (a, b) => a + b);
    }
  }

  void _showFilterDialog() async {
    int? selectedYear = filterYear;
    int? selectedMonth = filterMonth;
    int? selectedWeek = filterWeek;

    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
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
                                onSelectedItemChanged: (index) =>
                                    tempValue = min + index,
                                childDelegate: ListWheelChildBuilderDelegate(
                                  builder: (context, index) {
                                    if (index < 0 || index > (max - min))
                                      return null;
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
                }) {
                  return ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey.shade50,
                      foregroundColor: Colors.black,
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
                            Icon(icon, color: Colors.blueGrey.shade700),
                            const SizedBox(width: 10),
                            Text(
                              title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          valueText ?? "Select",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                String weekDisplayLabel(int weekNumber) {
                  if (selectedYear != null && selectedMonth != null) {
                    final weeks = getFourWeeksInMonth(
                      selectedYear!,
                      selectedMonth!,
                    );
                    if (weekNumber >= 1 && weekNumber <= weeks.length) {
                      final w = weeks[weekNumber - 1];
                      return "Week $weekNumber (${w['start'].day}-${w['end'].day})";
                    }
                  }
                  return "Week $weekNumber";
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Filter Expense",
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
                          onSelected: (v) => setState(() {
                            selectedYear = v;
                            if (filterYear != v) {
                              selectedMonth = null;
                              selectedWeek = null;
                            }
                          }),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    pickerButton(
                      title: "Month",
                      icon: Icons.date_range,
                      valueText: selectedMonth != null
                          ? DateFormat(
                              'MMM',
                            ).format(DateTime(0, selectedMonth!))
                          : null,
                      onTap: () async {
                        await _showPickerBottomSheet(
                          title: "Select Month",
                          min: 1,
                          max: 12,
                          currentValue: selectedMonth,
                          display: (v) =>
                              DateFormat('MMM').format(DateTime(0, v)),
                          onSelected: (v) => setState(() {
                            selectedMonth = v;
                            if (filterMonth != v) selectedWeek = null;
                          }),
                        );
                      },
                    ),
                    if (currentView == "Week") ...[
                      const SizedBox(height: 12),
                      pickerButton(
                        title: "Week",
                        icon: Icons.calendar_view_week,
                        valueText: selectedWeek != null
                            ? weekDisplayLabel(selectedWeek!)
                            : null,
                        onTap: () async {
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
                            display: (v) => weekDisplayLabel(v),
                            onSelected: (v) => setState(() => selectedWeek = v),
                          );
                        },
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
                              _calculateExpense();
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
                            setState(() {
                              filterYear = selectedYear;
                              filterMonth = selectedMonth;
                              filterWeek = selectedWeek;
                            });
                            _calculateExpense();
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

  String _chartTitleForCurrentView() {
    if (currentView == "Year") {
      final y = filterYear ?? DateTime.now().year;
      return 'Monthly expense for $y';
    } else if (currentView == "Month") {
      final y = filterYear ?? DateTime.now().year;
      final m = filterMonth ?? DateTime.now().month;
      return 'Weekly expense for ${DateFormat('MMM yyyy').format(DateTime(y, m))}';
    } else {
      final y = filterYear ?? DateTime.now().year;
      final m = filterMonth ?? DateTime.now().month;
      final w = filterWeek ?? weekNumber(DateTime.now());
      return 'Daily expense for Week $w (${DateFormat('MMM yyyy').format(DateTime(y, m))})';
    }
  }

  String _breakdownTitleForCurrentView() {
    if (currentView == "Year") return "Monthly";
    if (currentView == "Month") return "Weekly";
    return "Daily";
  }

  @override
  Widget build(BuildContext context) {
    final List<_ChartData> chartData = groupedExpense.entries
        .map((e) => _ChartData(e.key, e.value))
        .toList();
    final double maxY = chartData.isEmpty
        ? 100
        : chartData.map((d) => d.amount).reduce((a, b) => a > b ? a : b) * 1.3;
    String subtitleLabel;
    if (currentView == "Year") {
      subtitleLabel = "Year: ${filterYear ?? DateTime.now().year}";
    } else if (currentView == "Month") {
      final y = filterYear ?? DateTime.now().year;
      final m = filterMonth ?? DateTime.now().month;
      subtitleLabel = DateFormat('MMM yyyy').format(DateTime(y, m));
    } else {
      final y = filterYear ?? DateTime.now().year;
      final m = filterMonth ?? DateTime.now().month;
      final w = filterWeek ?? weekNumber(DateTime.now());
      subtitleLabel =
          "Week $w, ${DateFormat('MMM yyyy').format(DateTime(y, m))}";
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Expense Report"),
        backgroundColor: Colors.grey.shade200,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_outlined, color: Colors.black87),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: () {
              _calculateExpense();
              setState(() {});
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.teal,
          tabs: const [
            Tab(text: "Year"),
            Tab(text: "Month"),
            Tab(text: "Week"),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _calculateExpense();
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
                          // colors: [Color(0xFFe44d26), Color(0xFFba3e1d)],
                          colors: [Colors.red, Colors.redAccent],
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 30,
                        horizontal: 18,
                      ),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: totalExpense),
                        duration: const Duration(milliseconds: 800),
                        builder: (context, value, _) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                "Total Expense",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                subtitleLabel,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "₹${value.toStringAsFixed(0)}",
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: SizedBox(
                        height: 260,
                        child: SfCartesianChart(
                          title: ChartTitle(text: _chartTitleForCurrentView()),
                          tooltipBehavior: TooltipBehavior(enable: true),
                          primaryXAxis: CategoryAxis(),
                          primaryYAxis: NumericAxis(
                            minimum: 0,
                            maximum: maxY,
                            edgeLabelPlacement: EdgeLabelPlacement.shift,
                            labelFormat: '₹{value}',
                          ),
                          series: <ColumnSeries<_ChartData, String>>[
                            ColumnSeries<_ChartData, String>(
                              dataSource: chartData,
                              xValueMapper: (d, _) => d.period,
                              yValueMapper: (d, _) => d.amount,
                              name: currentView == "Month"
                                  ? "Weekly Expense"
                                  : "Expense",
                              color: Colors.red.shade500,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(12),
                              ),
                              dataLabelSettings: const DataLabelSettings(
                                isVisible: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    "${_breakdownTitleForCurrentView()} Breakdown",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  groupedExpense.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              "No expense records found",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        )
                      : Column(
                          children: groupedExpense.entries.map((e) {
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.red.shade100,
                                  child: const Icon(
                                    Icons.currency_rupee_sharp,
                                    color: Colors.red,
                                  ),
                                ),
                                title: Text(
                                  e.key,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                trailing: Text(
                                  "₹${e.value.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                  ExpenseReportCircle(
                    categoryData: widget.transactions,
                    tapController: _tabController,
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
