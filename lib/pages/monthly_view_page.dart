import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthlyTransactionsPage extends StatefulWidget {
  final List<dynamic> transactions;
  const MonthlyTransactionsPage({super.key, required this.transactions});

  @override
  State<MonthlyTransactionsPage> createState() =>
      _MonthlyTransactionsPageState();
}

class _MonthlyTransactionsPageState extends State<MonthlyTransactionsPage>
    with TickerProviderStateMixin {
  Map<String, List<Map<String, dynamic>>> _groupedByMonth = {};
  Map<String, List<Map<String, dynamic>>> _groupedByWeek = {};
  final int _currentYear = DateTime.now().year;
  final int _currentMonth = DateTime.now().month;

  final Set<String> _expandedMonths = {};
  List<Map<String, dynamic>> _transactions = [];
  bool _loading = true;

  final Map<String, GlobalKey> _monthKeys = {};
  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    _loadTransactions();

    // Auto-refresh every 30 seconds
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) _refreshTransactions();
    });
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  /// Loads transactions and preserves expanded states
  Future<void> _refreshTransactions() async {
    try {
      _transactions = widget.transactions.cast<Map<String, dynamic>>();
      _groupTransactions();
      setState(() {}); // rebuild UI with updated data
    } catch (e) {
      debugPrint("Error refreshing transactions: $e");
    }
  }

  Future<void> _loadTransactions() async {
    setState(() => _loading = true);
    try {
      _transactions = widget.transactions.cast<Map<String, dynamic>>();
      _groupTransactions();
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  void _groupTransactions() {
    _groupedByMonth.clear();
    _groupedByWeek.clear();
    final now = DateTime.now();

    for (var txn in _transactions) {
      DateTime date = DateTime.parse(txn["date"]).toLocal();
      if (date.year == _currentYear && date.month <= _currentMonth) {
        String monthKey = DateFormat("yyyy-MM").format(date);
        _groupedByMonth.putIfAbsent(monthKey, () => []);
        _groupedByMonth[monthKey]!.add(txn);
      }
    }

    for (int month = 1; month <= _currentMonth; month++) {
      DateTime startOfMonth = DateTime(_currentYear, month, 1);
      DateTime endOfMonth = DateTime(_currentYear, month + 1, 0);
      String monthKey = DateFormat("yyyy-MM").format(startOfMonth);

      List<Map<String, dynamic>> txns = _groupedByMonth[monthKey] ?? [];
      txns.sort((a, b) {
        final dateA = DateTime.parse(a["date"]).toLocal();
        final dateB = DateTime.parse(b["date"]).toLocal();
        return dateB.compareTo(dateA);
      });

      List<Map<String, dynamic>> weeks = [];
      int totalDays = endOfMonth.day;
      int weekStartDay = 1;

      for (int i = 1; i <= 4; i++) {
        int weekEndDay = i < 4 ? weekStartDay + 6 : totalDays;
        DateTime weekStart = DateTime(_currentYear, month, weekStartDay);
        DateTime weekEnd = DateTime(_currentYear, month, weekEndDay);
        if (weekEnd.isAfter(now)) weekEnd = now;
        if (weekStart.isAfter(now)) break;

        final weekTxns = txns.where((t) {
          final d = DateTime.parse(t["date"]).toLocal();
          return !d.isBefore(weekStart) && !d.isAfter(weekEnd);
        }).toList();

        double income = 0, expense = 0, transfer = 0;
        for (var t in weekTxns) {
          double amt = 0;
          if (t["amount"] is num) amt = (t["amount"] as num).toDouble();
          if (t["amount"] is String) amt = double.tryParse(t["amount"]) ?? 0;
          switch (t["type"]) {
            case "Income":
              income += amt;
              break;
            case "Expense":
              expense += amt;
              break;
            case "Transfer":
              transfer += amt;
              break;
          }
        }

        weeks.add({
          "weekNumber": i,
          "range": "$weekStartDay-$weekEndDay",
          "income": income,
          "expense": expense,
          "transfer": transfer,
          "total": income - expense - transfer,
          "isCurrentWeek":
              month == _currentMonth &&
              now.day >= weekStartDay &&
              now.day <= weekEndDay,
          "isExpanded": false,
        });

        weekStartDay = weekEndDay + 1;
      }

      _groupedByWeek[monthKey] = weeks;
    }
  }

  double _calculateMonthTotal(String type, List<Map<String, dynamic>> txns) {
    return txns.where((t) => t["type"] == type).fold(0.0, (sum, t) {
      final amount = t["amount"];
      if (amount is num) return sum + amount.toDouble();
      if (amount is String) return sum + (double.tryParse(amount) ?? 0.0);
      return sum;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    List<int> months = List.generate(_currentMonth, (i) => _currentMonth - i);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadTransactions,
        child: ListView.builder(
          padding: const EdgeInsets.only(bottom: 80),
          itemCount: months.length,
          itemBuilder: (context, index) {
            final month = months[index];
            final monthDate = DateTime(_currentYear, month, 1);
            final monthKey = DateFormat("yyyy-MM").format(monthDate);
            _monthKeys.putIfAbsent(monthKey, () => GlobalKey());
            final monthName = DateFormat("MMMM").format(monthDate);

            final txns = _groupedByMonth[monthKey] ?? [];
            final income = _calculateMonthTotal("Income", txns);
            final expense = _calculateMonthTotal("Expense", txns);
            final transfer = _calculateMonthTotal("Transfer", txns);
            final total = income - expense - transfer;
            final isExpanded = _expandedMonths.contains(monthKey);

            return Column(
              key: _monthKeys[monthKey],
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isExpanded) {
                        _expandedMonths.remove(monthKey);
                      } else {
                        _expandedMonths.add(monthKey);
                      }
                    });

                    if (_expandedMonths.contains(monthKey)) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Scrollable.ensureVisible(
                          _monthKeys[monthKey]!.currentContext!,
                          duration: const Duration(milliseconds: 300),
                          alignment: 0.0,
                          curve: Curves.easeInOut,
                        );
                      });
                    }
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                monthName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              // Text(
                              //   "Totals : ₹ ${total.toStringAsFixed(0)}",
                              //   style: const TextStyle(
                              //     fontWeight: FontWeight.w500,
                              //     fontSize: 14,
                              //   ),
                              // ),
                              Icon(
                                isExpanded
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _summaryBox("Income", income, Colors.green),
                              _summaryBox("Expense", expense, Colors.red),
                              _summaryBox("Total", total, Colors.black),
                            ],
                          ),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            child: isExpanded
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: (_groupedByWeek[monthKey] ?? []).map((
                                      week,
                                    ) {
                                      bool isCurrentWeek =
                                          week['isCurrentWeek'] ?? false;

                                      return Container(
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 4,
                                        ),
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: isCurrentWeek
                                              ? Colors.blue.shade50
                                              : Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  "Week ${week['weekNumber']}",
                                                ),
                                                Text("(${week['range']})"),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  "INC : ${week['income'].toStringAsFixed(0)}",
                                                  style: const TextStyle(
                                                    color: Colors.green,
                                                  ),
                                                ),
                                                Text(
                                                  "EXP : ${week['expense'].toStringAsFixed(0)}",
                                                  style: const TextStyle(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                                Text(
                                                  "Tot : ${week['total'].toStringAsFixed(0)}",
                                                  style: TextStyle(
                                                    color: week['total'] >= 0
                                                        ? Colors.black
                                                        : Colors.red,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshTransactions,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _summaryBox(String label, double value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 4),
        Text(
          "₹${value.toStringAsFixed(0)}",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
