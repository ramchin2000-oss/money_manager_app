// import 'package:flutter/material.dart';
//
// class TransactionListPage extends StatelessWidget {
//   final List<Map<String, dynamic>> transactions;
//
//   const TransactionListPage({super.key, required this.transactions});
//
//   @override
//   Widget build(BuildContext context) {
//     if (transactions.isEmpty) {
//       return const Center(
//         child: Text("No Transactions Added Yet"),
//       );
//     }
//
//     // Calculate summary
//     double income = 0;
//     double expenses = 0;
//     for (var tx in transactions) {
//       double amt = double.tryParse(tx["amount"].toString()) ?? 0;
//       if (tx["type"] == "Income") {
//         income += amt;
//       } else {
//         expenses += amt;
//       }
//     }
//     double total = income - expenses;
//
//     return Column(
//       children: [
//         // 🔹 Top summary bar
//         Container(
//           padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//           decoration: BoxDecoration(
//             border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               _buildSummary("Income", income, Colors.blue),
//               _buildSummary("Expenses", expenses, Colors.red),
//               _buildSummary("Total", total, Colors.black),
//             ],
//           ),
//         ),
//
//         // 🔹 Transaction list
//         Expanded(
//           child: ListView.builder(
//             itemCount: transactions.length,
//             itemBuilder: (context, index) {
//               final tx = transactions[index];
//               bool isIncome = tx["type"] == "Income";
//
//               return Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // 🔹 Date Row
//                   Container(
//                     width: double.infinity,
//                     color: Colors.grey.shade100,
//                     padding: const EdgeInsets.symmetric(
//                         vertical: 6, horizontal: 12),
//                     child: Row(
//                       children: [
//                         Text(
//                           tx["date"],
//                           style: const TextStyle(
//                               fontWeight: FontWeight.bold, fontSize: 16),
//                         ),
//                         const SizedBox(width: 6),
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 8, vertical: 2),
//                           decoration: BoxDecoration(
//                             color: Colors.grey.shade400,
//                             borderRadius: BorderRadius.circular(6),
//                           ),
//                           child: Text(
//                             tx["time"],
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 12,
//                             ),
//                           ),
//                         )
//                       ],
//                     ),
//                   ),
//
//                   // 🔹 Transaction card
//                   ListTile(
//                     leading: CircleAvatar(
//                       backgroundColor: isIncome
//                           ? Colors.green.shade100
//                           : Colors.red.shade100,
//                       child: Icon(
//                         isIncome ? Icons.arrow_downward : Icons.arrow_upward,
//                         color: isIncome ? Colors.green : Colors.red,
//                       ),
//                     ),
//                     title: Text(
//                       tx["note"].isEmpty ? tx["category"] : tx["note"],
//                       style: const TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                     subtitle: Text(tx["account"]),
//                     trailing: Text(
//                       "${isIncome ? "₹" : "-₹"} ${tx["amount"]}",
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: isIncome ? Colors.blue : Colors.red,
//                         fontSize: 16,
//                       ),
//                     ),
//                   ),
//                   const Divider(height: 0),
//                 ],
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
//
//   // 🔹 Helper widget for summary bar
//   Widget _buildSummary(String title, double value, Color color) {
//     return Column(
//       children: [
//         Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
//         const SizedBox(height: 4),
//         Text(
//           "₹ ${value.toStringAsFixed(2)}",
//           style: TextStyle(
//             color: color,
//             fontWeight: FontWeight.bold,
//             fontSize: 16,
//           ),
//         ),
//       ],
//     );
//   }
// }
