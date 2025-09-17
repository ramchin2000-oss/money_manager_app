// import 'package:flutter/material.dart';
// import 'IncomeReportCircle.dart';
// import 'IncomeReportPage.dart' hide IncomeReportCircle;
//
// class IncomeStatsPage extends StatelessWidget {
//   final List<dynamic> transactions;
//   const IncomeStatsPage({super.key, required this.transactions});
//
//   @override
//   Widget build(BuildContext context) {
//     final categoryMap = filterAndGroupByCategory(transactions, "Income");
//
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           // This widget already has its own internal layout (tabs + pages)
//           IncomeReportPage(transactions: transactions),
//
//           const SizedBox(height: 16),
//
//           // Chart section
//           IncomeReportCircle(categoryData: categoryMap),
//         ],
//       ),
//     );
//   }
// }
