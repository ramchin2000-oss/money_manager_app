// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
//
// class DailyTransactions extends StatelessWidget {
//   final List<dynamic> transactions;
//   final String monthYear;
//   const DailyTransactions({
//     super.key,
//     required this.transactions,
//     required this.monthYear,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Expanded(
//           child: transactions.isEmpty
//               ? const Center(child: Text("No transactions yet"))
//               : ListView.builder(
//                   padding: const EdgeInsets.only(bottom: 70), // bottom space
//                   itemCount: transactions.length,
//                   itemBuilder: (context, index) {
//                     final txn = transactions[index];
//                     Color bgColor;
//                     switch (txn['type'] ?? '') {
//                       case "Income":
//                         bgColor = Colors.green.shade50;
//                         break;
//                       case "Expense":
//                         bgColor = Colors.red.shade50;
//                         break;
//                       case "Transfer":
//                         bgColor = Colors.blue.shade50;
//                         break;
//                       default:
//                         bgColor = Colors.grey.shade50;
//                     }
//                     bool showDateHeader = true;
//                     if (index > 0) {
//                       final prevTxn = transactions[index - 1];
//                       if ((prevTxn['date'] != null && txn['date'] != null) &&
//                           DateFormat.yMMMd().format(
//                                 DateTime.parse(prevTxn['date']),
//                               ) ==
//                               DateFormat.yMMMd().format(
//                                 DateTime.parse(txn['date']),
//                               )) {
//                         showDateHeader = false;
//                       }
//                     }
//                     return Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         if (showDateHeader)
//                           Padding(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 12,
//                               vertical: 6,
//                             ),
//                             child: Text(
//                               txn['date'] != null
//                                   ? DateFormat.yMMMd().format(
//                                       DateTime.parse(txn['date']),
//                                     )
//                                   : '',
//                               style: const TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         Card(
//                           color: bgColor,
//                           margin: const EdgeInsets.symmetric(
//                             vertical: 4,
//                             horizontal: 10,
//                           ),
//                           elevation: 2,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(
//                               vertical: 4,
//                               horizontal: 6,
//                             ),
//                             child: txn['type'] == "Transfer"
//                                 ? _buildTransferLayout(context, txn)
//                                 : _buildIncomeExpenseLayout(context, txn),
//                           ),
//                         ),
//                       ],
//                     );
//                   },
//                 ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildIncomeExpenseLayout(BuildContext context, dynamic txn) {
//     final date = txn['date'] != null
//         ? DateTime.parse(txn['date'])
//         : DateTime.now();
//     final isIncome = txn['type'] == "Income";
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             // Category
//             Expanded(
//               flex: 2,
//               child: Text(
//                 txn['category'] ?? '',
//                 style: const TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16,
//                 ),
//               ),
//             ),
//             // Account
//             Expanded(
//               flex: 2,
//               child: Text(
//                 txn['account'] ?? '',
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(fontSize: 18),
//               ),
//             ),
//             // Amount, arrow icon, time + note icon
//             Expanded(
//               flex: 3,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       Text(
//                         "₹ ${double.parse(txn['amount'].toString()).toStringAsFixed(0)}",
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 18,
//                           color: isIncome ? Colors.green : Colors.red,
//                         ),
//                       ),
//                       const SizedBox(width: 5),
//                       Icon(
//                         isIncome ? Icons.arrow_upward : Icons.arrow_downward,
//                         color: isIncome ? Colors.green : Colors.red,
//                         size: 22,
//                       ),
//                     ],
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       Text(
//                         DateFormat.jm().format(date),
//                         style: const TextStyle(fontSize: 12),
//                       ),
//                       const SizedBox(width: 6),
//                       ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           padding: const EdgeInsets.all(4),
//                           minimumSize: const Size(32, 32),
//                           shadowColor: Colors.teal,
//                           elevation: 2,
//                           backgroundColor: Colors.white,
//                         ),
//                         onPressed: () {
//                           final note = txn['note'] ?? '';
//                           showDialog(
//                             context: context,
//                             builder: (ctx) => AlertDialog(
//                               title: const Text("Note"),
//                               content: Text(
//                                 note.isNotEmpty
//                                     ? note
//                                     : "No note for this transaction",
//                               ),
//                               actions: [
//                                 TextButton(
//                                   onPressed: () => Navigator.pop(ctx),
//                                   child: const Text("Close"),
//                                 ),
//                               ],
//                             ),
//                           );
//                         },
//                         child: const Icon(
//                           Icons.note_alt_outlined,
//                           size: 20,
//                           color: Colors.teal,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
//
//   Widget _buildTransferLayout(BuildContext context, dynamic txn) {
//     final date = txn['date'] != null
//         ? DateTime.parse(txn['date'])
//         : DateTime.now();
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             // From -> To
//             Expanded(
//               flex: 4,
//               child: Row(
//                 children: [
//                   Text(
//                     txn['account'] ?? '',
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                       color: Colors.blue,
//                     ),
//                   ),
//                   const Icon(Icons.arrow_forward, size: 20, color: Colors.blue),
//                   Text(
//                     txn['toAccount'] ?? '',
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                       color: Colors.blue,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             // Amount, arrow icon, time + note icon
//             Expanded(
//               flex: 3,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       Text(
//                         "₹${double.parse(txn['amount'].toString()).toStringAsFixed(0)}",
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 20,
//                           color: Colors.blue,
//                         ),
//                       ),
//                       const SizedBox(width: 5),
//                       const Icon(
//                         Icons.compare_arrows,
//                         color: Colors.blue,
//                         size: 22,
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 4),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       Text(
//                         DateFormat.jm().format(date),
//                         style: const TextStyle(fontSize: 11),
//                       ),
//                       const SizedBox(width: 3),
//                       ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           padding: const EdgeInsets.all(4),
//                           minimumSize: const Size(32, 32),
//                           shadowColor: Colors.teal,
//                           elevation: 2,
//                           backgroundColor: Colors.white,
//                         ),
//                         onPressed: () {
//                           final note = txn['note'] ?? '';
//                           showDialog(
//                             context: context,
//                             builder: (ctx) => AlertDialog(
//                               title: const Text("Note"),
//                               content: Text(
//                                 note.isNotEmpty
//                                     ? note
//                                     : "No note for this transaction",
//                                 // Row(
//                                 //     children: [
//                                 //       Text(
//                                 //         'No note for this transaction',
//                                 //         style: TextStyle(
//                                 //           color: Colors.orange,
//                                 //         ),
//                                 //       ),
//                                 //       Icon(
//                                 //         Icons.info_outline,
//                                 //         color: Colors.orange,
//                                 //         size: 16,
//                                 //       ),
//                                 //     ],
//                                 //   ),
//                               ),
//                               actions: [
//                                 TextButton(
//                                   onPressed: () => Navigator.pop(ctx),
//                                   child: const Text("Close"),
//                                 ),
//                               ],
//                             ),
//                           );
//                         },
//                         child: const Icon(
//                           Icons.note_alt_outlined,
//                           size: 22,
//                           color: Colors.teal,
//                         ),
//                       ),
//                     ],
//                   ),
//                   // Info below note icon if no note
//                   if ((txn['note'] ?? '').isEmpty)
//                     Padding(
//                       padding: const EdgeInsets.only(top: 4),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         children: [
//                           const Icon(
//                             Icons.info_outline,
//                             color: Colors.orange,
//                             size: 16,
//                           ),
//                         ],
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
//
// class DailyTransactions extends StatelessWidget {
//   final List<dynamic> transactions;
//   final String monthYear; // Example: "Sep 2025"
//
//   const DailyTransactions({
//     super.key,
//     required this.transactions,
//     required this.monthYear,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     // Filter transactions by selected monthYear
//     final filteredTxns = transactions.where((txn) {
//       if (txn['date'] == null) return false;
//       final date = DateTime.tryParse(txn['date']);
//       if (date == null) return false;
//       return DateFormat.yMMM().format(date) == monthYear;
//     }).toList();
//
//     return Column(
//       children: [
//         Expanded(
//           child: filteredTxns.isEmpty
//               ? Center(child: Text("No transactions yet for $monthYear "))
//               : ListView.builder(
//                   padding: const EdgeInsets.only(bottom: 70), // bottom space
//                   itemCount: filteredTxns.length,
//                   itemBuilder: (context, index) {
//                     final txn = filteredTxns[index];
//                     Color bgColor;
//                     switch (txn['type'] ?? '') {
//                       case "Income":
//                         bgColor = Colors.green.shade50;
//                         break;
//                       case "Expense":
//                         bgColor = Colors.red.shade50;
//                         break;
//                       case "Transfer":
//                         bgColor = Colors.blue.shade50;
//                         break;
//                       default:
//                         bgColor = Colors.grey.shade50;
//                     }
//
//                     bool showDateHeader = true;
//                     if (index > 0) {
//                       final prevTxn = filteredTxns[index - 1];
//                       if ((prevTxn['date'] != null && txn['date'] != null) &&
//                           DateFormat.yMMMd().format(
//                                 DateTime.parse(prevTxn['date']),
//                               ) ==
//                               DateFormat.yMMMd().format(
//                                 DateTime.parse(txn['date']),
//                               )) {
//                         showDateHeader = false;
//                       }
//                     }
//
//                     return Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         if (showDateHeader)
//                           Padding(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 12,
//                               vertical: 6,
//                             ),
//                             child: Text(
//                               txn['date'] != null
//                                   ? DateFormat.yMMMd().format(
//                                       DateTime.parse(txn['date']),
//                                     )
//                                   : '',
//                               style: const TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         Card(
//                           color: bgColor,
//                           margin: const EdgeInsets.symmetric(
//                             vertical: 4,
//                             horizontal: 10,
//                           ),
//                           elevation: 2,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(
//                               vertical: 4,
//                               horizontal: 6,
//                             ),
//                             child: _buildIncomeExpenseLayout(context, txn),
//                           ),
//                         ),
//                       ],
//                     );
//                   },
//                 ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildIncomeExpenseLayout(BuildContext context, dynamic txn) {
//     final date = txn['date'] != null
//         ? DateTime.parse(txn['date'])
//         : DateTime.now();
//     final isIncome = txn['type'] == "Income";
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             // Category
//             Expanded(
//               flex: 2,
//               child: Text(
//                 txn['category'] ?? '',
//                 style: const TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16,
//                 ),
//               ),
//             ),
//             // Account
//             Expanded(
//               flex: 2,
//               child: Text(
//                 txn['account'] ?? '',
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(fontSize: 18),
//               ),
//             ),
//             // Amount, arrow icon, time + note icon
//             Expanded(
//               flex: 3,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       Text(
//                         "₹ ${double.parse(txn['amount'].toString()).toStringAsFixed(0)}",
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 18,
//                           color: isIncome ? Colors.green : Colors.red,
//                         ),
//                       ),
//                       const SizedBox(width: 5),
//                       Icon(
//                         isIncome ? Icons.arrow_upward : Icons.arrow_downward,
//                         color: isIncome ? Colors.green : Colors.red,
//                         size: 22,
//                       ),
//                     ],
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       Text(
//                         DateFormat.jm().format(date),
//                         style: const TextStyle(fontSize: 12),
//                       ),
//                       const SizedBox(width: 6),
//                       ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           padding: const EdgeInsets.all(4),
//                           minimumSize: const Size(32, 32),
//                           shadowColor: Colors.teal,
//                           elevation: 2,
//                           backgroundColor: Colors.white,
//                         ),
//                         onPressed: () {
//                           final note = txn['note'] ?? '';
//                           showDialog(
//                             context: context,
//                             builder: (ctx) => AlertDialog(
//                               title: const Text("Note"),
//                               content: Text(
//                                 note.isNotEmpty
//                                     ? note
//                                     : "No note for this transaction",
//                               ),
//                               actions: [
//                                 TextButton(
//                                   onPressed: () => Navigator.pop(ctx),
//                                   child: const Text("Close"),
//                                 ),
//                               ],
//                             ),
//                           );
//                         },
//                         child: const Icon(
//                           Icons.note_alt_outlined,
//                           size: 20,
//                           color: Colors.teal,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../pages/AddTransactionPage.dart';
import '../services/transaction_service.dart';

class DailyTransactions extends StatelessWidget {
  final List<dynamic> transactions;
  final String monthYear; // Example: "Sep 2025"
  final bool isLoggedIn;

  const DailyTransactions({
    super.key,
    required this.transactions,
    required this.monthYear,
    required this.isLoggedIn,
  });
  // Future<void> _refreshTransactions() async {
  //   final data = await TransactionService.fetchTransactions(); // backend call
  //   transactions = data;
  // }

  @override
  Widget build(BuildContext context) {
    // Filter transactions by selected monthYear
    final filteredTxns = transactions.where((txn) {
      if (txn['date'] == null) return false;
      final date = DateTime.tryParse(txn['date']);
      if (date == null) return false;
      return DateFormat.yMMM().format(date) == monthYear;
    }).toList();

    return Column(
      children: [
        Expanded(
          child: filteredTxns.isEmpty
              ? Center(child: Text("No transactions yet for $monthYear"))
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 70),
                  itemCount: filteredTxns.length,
                  itemBuilder: (context, index) {
                    final txn = filteredTxns[index];

                    Color bgColor;
                    switch (txn['type'] ?? '') {
                      case "Income":
                        bgColor = Colors.green.shade50;
                        break;
                      case "Expense":
                        bgColor = Colors.red.shade50;
                        break;
                      case "Transfer":
                        bgColor = Colors.blue.shade50;
                        break;
                      default:
                        bgColor = Colors.grey.shade50;
                    }

                    bool showDateHeader = true;
                    if (index > 0) {
                      final prevTxn = filteredTxns[index - 1];
                      if ((prevTxn['date'] != null && txn['date'] != null) &&
                          DateFormat.yMMMd().format(
                                DateTime.parse(prevTxn['date']),
                              ) ==
                              DateFormat.yMMMd().format(
                                DateTime.parse(txn['date']),
                              )) {
                        showDateHeader = false;
                      }
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showDateHeader)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            child: Text(
                              txn['date'] != null
                                  ? DateFormat.yMMMd().format(
                                      DateTime.parse(txn['date']),
                                    )
                                  : '',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        Card(
                          color: bgColor,
                          margin: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 10,
                          ),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () {
                              // Navigate to TransferPage with txn data
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddTransactionPage(
                                    editTransaction: txn,
                                    isLoggedIn: isLoggedIn,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 6,
                              ),
                              child: _buildIncomeExpenseLayout(context, txn),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildIncomeExpenseLayout(BuildContext context, dynamic txn) {
    final date = txn['date'] != null
        ? DateTime.parse(txn['date'])
        : DateTime.now();
    final isIncome = txn['type'] == "Income";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Category
            Expanded(
              flex: 2,
              child: Text(
                txn['category'] ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            // Account
            Expanded(
              flex: 2,
              child: Text(
                txn['account'] ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
            ),
            // Amount, arrow icon, time + note icon
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "₹ ${double.parse(txn['amount'].toString()).toStringAsFixed(0)}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: isIncome ? Colors.green : Colors.red,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Icon(
                        isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                        color: isIncome ? Colors.green : Colors.red,
                        size: 22,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        DateFormat.jm().format(date),
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 6),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(4),
                          minimumSize: const Size(32, 32),
                          shadowColor: Colors.teal,
                          elevation: 2,
                          backgroundColor: Colors.white,
                        ),
                        onPressed: () {
                          final note = txn['note'] ?? '';
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text("Note"),
                              content: Text(
                                note.isNotEmpty
                                    ? note
                                    : "No note for this transaction",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text("Close"),
                                ),
                              ],
                            ),
                          );
                        },
                        child: const Icon(
                          Icons.note_alt_outlined,
                          size: 20,
                          color: Colors.teal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
