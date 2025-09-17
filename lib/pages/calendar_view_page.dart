// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:table_calendar/table_calendar.dart';
// import 'dart:math';
//
// import 'AddTransactionPage.dart';
//
// class CalendarTransactionsPage extends StatefulWidget {
//   final List<dynamic> transactions;
//   final String monthYear;
//   const CalendarTransactionsPage({
//     super.key,
//     required this.transactions,
//     required this.monthYear,
//   });
//
//   @override
//   State<CalendarTransactionsPage> createState() =>
//       _CalendarTransactionsPageState();
// }
//
// class _CalendarTransactionsPageState extends State<CalendarTransactionsPage> {
//   DateTime _focusedDay = DateTime.now();
//   DateTime? _selectedDay;
//   Map<DateTime, List<Map<String, dynamic>>> _groupedTransactions = {};
//
//   @override
//   void initState() {
//     super.initState();
//     _groupTransactions(widget.transactions.cast<Map<String, dynamic>>());
//   }
//
//   @override
//   void didUpdateWidget(covariant CalendarTransactionsPage oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.transactions != widget.transactions) {
//       _groupTransactions(widget.transactions.cast<Map<String, dynamic>>());
//     }
//   }
//
//   void _groupTransactions(List<Map<String, dynamic>> transactions) {
//     final Map<DateTime, List<Map<String, dynamic>>> grouped = {};
//     for (var txn in transactions) {
//       final rawDate = txn["date"];
//       if (rawDate == null) continue;
//       final date = DateTime.tryParse(rawDate.toString());
//       if (date == null) continue;
//       final dayKey = DateTime(date.year, date.month, date.day);
//       grouped.putIfAbsent(dayKey, () => []);
//       grouped[dayKey]!.add(txn);
//     }
//     setState(() {
//       _groupedTransactions = grouped;
//     });
//   }
//
//   List<Map<String, dynamic>> _getTransactionsForDay(DateTime day) {
//     return _groupedTransactions[DateTime(day.year, day.month, day.day)] ?? [];
//   }
//
//   Color _getColorForType(String type) {
//     switch (type) {
//       case "Income":
//         return Colors.green.shade400;
//       case "Expense":
//         return Colors.red.shade400;
//       case "Transfer":
//         return Colors.blue.shade400;
//       default:
//         return Colors.grey;
//     }
//   }
//
//   void _showTransactionsForDay(DateTime day) {
//     final txns = _getTransactionsForDay(day)
//       ..sort((a, b) {
//         final timeA = DateTime.tryParse(a["date"].toString()) ?? DateTime.now();
//         final timeB = DateTime.tryParse(b["date"].toString()) ?? DateTime.now();
//         return timeB.compareTo(timeA);
//       });
//
//     // Calculate total income and expense
//     double totalIncome = 0.0;
//     double totalExpense = 0.0;
//     for (var txn in txns) {
//       final type = txn["type"]?.toString() ?? "Expense";
//       final amount = double.tryParse(txn["amount"].toString()) ?? 0.0;
//       if (type == "Income") {
//         totalIncome += amount;
//       } else if (type == "Expense") {
//         totalExpense += amount;
//       }
//     }
//
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return DraggableScrollableSheet(
//           expand: false,
//           initialChildSize: 0.3,
//           minChildSize: 0.2,
//           maxChildSize: 0.9,
//           builder: (context, scrollController) {
//             return Container(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 children: [
//                   Container(
//                     width: 60,
//                     height: 5,
//                     margin: const EdgeInsets.only(bottom: 10),
//                     decoration: BoxDecoration(
//                       color: Colors.grey[300],
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   Text(
//                     DateFormat.yMMMMd().format(day),
//                     style: const TextStyle(
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Row(
//                         children: [
//                           const Text(
//                             "INC :",
//                             style: TextStyle(
//                               fontWeight: FontWeight.w600,
//                               fontSize: 18,
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           Text(
//                             "₹ ${totalIncome.toStringAsFixed(1)}",
//                             style: const TextStyle(
//                               color: Colors.green,
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                             ),
//                           ),
//                         ],
//                       ),
//                       Row(
//                         children: [
//                           const Text(
//                             "EXP :",
//                             style: TextStyle(
//                               fontWeight: FontWeight.w600,
//                               fontSize: 18,
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           Text(
//                             "₹ ${totalExpense.toStringAsFixed(1)}",
//                             style: const TextStyle(
//                               color: Colors.red,
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                   const Divider(height: 20),
//                   Expanded(
//                     child: txns.isEmpty
//                         ? const Center(child: Text("No transactions"))
//                         : ListView.builder(
//                             controller: scrollController,
//                             itemCount: txns.length,
//                             itemBuilder: (context, index) {
//                               final txn = txns[index];
//                               final category =
//                                   txn["category"]?.toString() ?? "Unknown";
//                               final account = txn["account"]?.toString() ?? "-";
//                               final type = txn["type"]?.toString() ?? "Expense";
//                               final amount =
//                                   double.tryParse(txn["amount"].toString()) ??
//                                   0.0;
//
//                               // ✅ format stored ISO date into 12-hour AM/PM
//                               final time = DateFormat.jm().format(
//                                 DateTime.tryParse(
//                                       txn["date"].toString(),
//                                     )?.toLocal() ??
//                                     DateTime.now(),
//                               );
//
//                               return ListTile(
//                                 leading: CircleAvatar(
//                                   radius: 16,
//                                   backgroundColor: _getColorForType(type),
//                                   child: Icon(
//                                     type == "Income"
//                                         ? Icons.arrow_upward
//                                         : type == "Expense"
//                                         ? Icons.arrow_downward
//                                         : Icons.swap_horiz,
//                                     size: 16,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                                 title: Text(category),
//                                 subtitle: Text("$account • $time"), // ✅ 9:22 PM
//                                 trailing: Text(
//                                   "₹${amount.toStringAsFixed(2)}",
//                                   style: TextStyle(
//                                     color: _getColorForType(type),
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
//
//   Widget _buildDateCell(DateTime day, bool isSelected, bool isToday) {
//     final txns = _getTransactionsForDay(day);
//
//     final Map<String, double> typeAmount = {};
//     for (var txn in txns) {
//       final type = txn["type"]?.toString() ?? "Other";
//       final amount = double.tryParse(txn["amount"].toString()) ?? 0.0;
//       typeAmount[type] = (typeAmount[type] ?? 0.0) + amount;
//     }
//
//     final colors = typeAmount.keys.map(_getColorForType).toList();
//     final amounts = typeAmount.values.toList();
//
//     return GestureDetector(
//       onTap: () {
//         setState(() => _selectedDay = day);
//         _showTransactionsForDay(day);
//       },
//       child: Container(
//         margin: const EdgeInsets.all(4),
//         child: CustomPaint(
//           painter: _DateCirclePainter(colors, amounts),
//           child: Container(
//             width: 35,
//             height: 35,
//             alignment: Alignment.center,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: isToday ? Colors.orange.shade300 : Colors.white,
//               boxShadow: [
//                 if (isSelected || isToday)
//                   const BoxShadow(
//                     color: Colors.black12,
//                     blurRadius: 4,
//                     offset: Offset(0, 2),
//                   ),
//               ],
//             ),
//             child: Text(
//               '${day.day}',
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: isToday ? Colors.white : Colors.black87,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: TableCalendar(
//         focusedDay: _focusedDay,
//         firstDay: DateTime(2000),
//         lastDay: DateTime(2100),
//         calendarFormat: CalendarFormat.month,
//         rowHeight: 60,
//         headerStyle: const HeaderStyle(
//           formatButtonVisible: false,
//           titleCentered: true,
//           titleTextStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//         ),
//         selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
//         onPageChanged: (focusedDay) => _focusedDay = focusedDay,
//         calendarBuilders: CalendarBuilders(
//           defaultBuilder: (context, day, focusedDay) => _buildDateCell(
//             day,
//             isSameDay(day, _selectedDay),
//             isSameDay(day, DateTime.now()),
//           ),
//           todayBuilder: (context, day, focusedDay) =>
//               _buildDateCell(day, isSameDay(day, _selectedDay), true),
//           selectedBuilder: (context, day, focusedDay) =>
//               _buildDateCell(day, true, isSameDay(day, DateTime.now())),
//         ),
//       ),
//     );
//   }
// }
//
// class _DateCirclePainter extends CustomPainter {
//   final List<Color> colors;
//   final List<double> amounts;
//
//   _DateCirclePainter(this.colors, this.amounts);
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     if (colors.isEmpty || amounts.isEmpty) return;
//
//     final total = amounts.reduce((a, b) => a + b);
//     if (total == 0) return;
//
//     final rect = Rect.fromLTWH(0, 0, size.width, size.height);
//     final paint = Paint()
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 10;
//
//     double startAngle = -pi / 2;
//
//     for (int i = 0; i < colors.length; i++) {
//       final sweepAngle = 2 * pi * (amounts[i] / total);
//       paint.color = colors[i];
//       canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
//       startAngle += sweepAngle;
//     }
//   }
//
//   @override
//   bool shouldRepaint(covariant _DateCirclePainter oldDelegate) =>
//       oldDelegate.colors != colors || oldDelegate.amounts != amounts;
// }

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:math';

import 'AddTransactionPage.dart';

class CalendarTransactionsPage extends StatefulWidget {
  final List<dynamic> transactions;
  final String monthYear; // Example: "Sep 2025"
  const CalendarTransactionsPage({
    super.key,
    required this.transactions,
    required this.monthYear,
  });

  @override
  State<CalendarTransactionsPage> createState() =>
      _CalendarTransactionsPageState();
}

class _CalendarTransactionsPageState extends State<CalendarTransactionsPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Map<String, dynamic>>> _groupedTransactions = {};

  @override
  void initState() {
    super.initState();
    _groupTransactions(widget.transactions.cast<Map<String, dynamic>>());
  }

  @override
  void didUpdateWidget(covariant CalendarTransactionsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.transactions != widget.transactions ||
        oldWidget.monthYear != widget.monthYear) {
      _groupTransactions(widget.transactions.cast<Map<String, dynamic>>());
    }
  }

  void _groupTransactions(List<Map<String, dynamic>> transactions) {
    final Map<DateTime, List<Map<String, dynamic>>> grouped = {};
    for (var txn in transactions) {
      final rawDate = txn["date"];
      if (rawDate == null) continue;
      final date = DateTime.tryParse(rawDate.toString());
      if (date == null) continue;

      // ✅ Only include if matches monthYear (e.g. "Sep 2025")
      final txnMonthYear = DateFormat.yMMM().format(date);
      if (widget.monthYear.isEmpty || txnMonthYear != widget.monthYear)
        continue;

      final dayKey = DateTime(date.year, date.month, date.day);
      grouped.putIfAbsent(dayKey, () => []);
      grouped[dayKey]!.add(txn);
    }
    setState(() {
      _groupedTransactions = grouped;
    });
  }

  List<Map<String, dynamic>> _getTransactionsForDay(DateTime day) {
    return _groupedTransactions[DateTime(day.year, day.month, day.day)] ?? [];
  }

  Color _getColorForType(String type) {
    switch (type) {
      case "Income":
        return Colors.green.shade400;
      case "Expense":
        return Colors.red.shade400;
      case "Transfer":
        return Colors.blue.shade400;
      default:
        return Colors.grey;
    }
  }

  void _showTransactionsForDay(DateTime day) {
    final txns = _getTransactionsForDay(day)
      ..sort((a, b) {
        final timeA = DateTime.tryParse(a["date"].toString()) ?? DateTime.now();
        final timeB = DateTime.tryParse(b["date"].toString()) ?? DateTime.now();
        return timeB.compareTo(timeA);
      });

    double totalIncome = 0.0;
    double totalExpense = 0.0;
    for (var txn in txns) {
      final type = txn["type"]?.toString() ?? "Expense";
      final amount = double.tryParse(txn["amount"].toString()) ?? 0.0;
      if (type == "Income") {
        totalIncome += amount;
      } else if (type == "Expense") {
        totalExpense += amount;
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.3,
          minChildSize: 0.2,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Text(
                    DateFormat.yMMMMd().format(day),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text(
                            "INC :",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "₹ ${totalIncome.toStringAsFixed(1)}",
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text(
                            "EXP :",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "₹ ${totalExpense.toStringAsFixed(1)}",
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Expanded(
                    child: txns.isEmpty
                        ? const Center(child: Text("No transactions"))
                        : ListView.builder(
                            controller: scrollController,
                            itemCount: txns.length,
                            itemBuilder: (context, index) {
                              final txn = txns[index];
                              final category =
                                  txn["category"]?.toString() ?? "Unknown";
                              final account = txn["account"]?.toString() ?? "-";
                              final type = txn["type"]?.toString() ?? "Expense";
                              final amount =
                                  double.tryParse(txn["amount"].toString()) ??
                                  0.0;

                              final time = DateFormat.jm().format(
                                DateTime.tryParse(
                                      txn["date"].toString(),
                                    )?.toLocal() ??
                                    DateTime.now(),
                              );

                              return ListTile(
                                leading: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: _getColorForType(type),
                                  child: Icon(
                                    type == "Income"
                                        ? Icons.arrow_upward
                                        : type == "Expense"
                                        ? Icons.arrow_downward
                                        : Icons.swap_horiz,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                title: Text(category),
                                subtitle: Text("$account • $time"),
                                trailing: Text(
                                  "₹${amount.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    color: _getColorForType(type),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDateCell(DateTime day, bool isSelected, bool isToday) {
    final txns = _getTransactionsForDay(day);

    final Map<String, double> typeAmount = {};
    for (var txn in txns) {
      final type = txn["type"]?.toString() ?? "Other";
      final amount = double.tryParse(txn["amount"].toString()) ?? 0.0;
      typeAmount[type] = (typeAmount[type] ?? 0.0) + amount;
    }

    final colors = typeAmount.keys.map(_getColorForType).toList();
    final amounts = typeAmount.values.toList();

    return GestureDetector(
      onTap: () {
        setState(() => _selectedDay = day);
        _showTransactionsForDay(day);
      },
      child: Container(
        margin: const EdgeInsets.all(4),
        child: CustomPaint(
          painter: _DateCirclePainter(colors, amounts),
          child: Container(
            width: 35,
            height: 35,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isToday ? Colors.orange.shade300 : Colors.white,
              boxShadow: [
                if (isSelected || isToday)
                  const BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
              ],
            ),
            child: Text(
              '${day.day}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isToday ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ set focusedDay to parsed monthYear (default today if invalid)
    DateTime initialFocus;
    try {
      if (widget.monthYear.isNotEmpty) {
        initialFocus = DateFormat.yMMM().parse(widget.monthYear);
      } else {
        initialFocus = DateTime.now();
      }
    } catch (_) {
      initialFocus = DateTime.now();
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TableCalendar(
        focusedDay: initialFocus,
        firstDay: DateTime(2000),
        lastDay: DateTime(2100),
        calendarFormat: CalendarFormat.month,
        rowHeight: 60,
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onPageChanged: (focusedDay) => _focusedDay = focusedDay,
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) => _buildDateCell(
            day,
            isSameDay(day, _selectedDay),
            isSameDay(day, DateTime.now()),
          ),
          todayBuilder: (context, day, focusedDay) =>
              _buildDateCell(day, isSameDay(day, _selectedDay), true),
          selectedBuilder: (context, day, focusedDay) =>
              _buildDateCell(day, true, isSameDay(day, DateTime.now())),
        ),
      ),
    );
  }
}

class _DateCirclePainter extends CustomPainter {
  final List<Color> colors;
  final List<double> amounts;

  _DateCirclePainter(this.colors, this.amounts);

  @override
  void paint(Canvas canvas, Size size) {
    if (colors.isEmpty || amounts.isEmpty) return;

    final total = amounts.reduce((a, b) => a + b);
    if (total == 0) return;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;

    double startAngle = -pi / 2;

    for (int i = 0; i < colors.length; i++) {
      final sweepAngle = 2 * pi * (amounts[i] / total);
      paint.color = colors[i];
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DateCirclePainter oldDelegate) =>
      oldDelegate.colors != colors || oldDelegate.amounts != amounts;
}
