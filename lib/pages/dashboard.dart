import 'package:fintrack/pages/statspages/Expense/ExpenseReportPage.dart';
import 'package:fintrack/pages/statspages/Income/IncomeReportPage.dart';
import 'package:fintrack/pages/statspages/OverAllCharts.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../appbar/money_appbar.dart';
import '../services/transaction_service.dart';
import '../services/transfer_service.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/daily_transactions.dart';
import '../widgets/popup_navi.dart';
import 'AddTransactionPage.dart';
import 'Note_page.dart';
import 'ProfilePage.dart';
import 'calendar_view_page.dart';
import 'monthly_view_page.dart';

class Dashboard extends StatefulWidget {
  final String name;
  final String email;
  final bool isLoggedIn;
  const Dashboard({
    super.key,
    required this.name,
    required this.email,
    required this.isLoggedIn,
  });

  @override
  State<Dashboard> createState() => DashboardState();
}

class DashboardState extends State<Dashboard> {
  int bottomIndex = 0; // bottom nav index
  int transIndex = 0; // transactions popup index
  int statsIndex = 0; // stats popup index
  int accountsIndex = 0; // accounts popup index

  List<dynamic> transactions = [];

  DateTime selectedDate = DateTime.now();

  void _prevMonth() {
    setState(() {
      selectedDate = DateTime(selectedDate.year, selectedDate.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      selectedDate = DateTime(selectedDate.year, selectedDate.month + 1);
    });
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    try {
      final tr = await TransactionService.fetchTransactions();

      tr.sort((a, b) {
        final dateA = DateTime.parse(a['date']).toLocal();
        final dateB = DateTime.parse(b['date']).toLocal();
        return dateB.compareTo(dateA); // ✅ latest first (time included)
      });

      setState(() {
        transactions = tr;
      });
    } catch (e) {
      print("Error loading transactions: $e");
    }
  }

  // ✅ Filter transactions for current month
  List<dynamic> _getTransactionsForMonth(DateTime date) {
    return transactions.where((t) {
      final txnDate = DateTime.parse(t['date']).toLocal();
      return txnDate.year == date.year && txnDate.month == date.month;
    }).toList();
  }

  // ✅ Calculate total by type
  double _calculateMonthlyTotal(String type, List<dynamic> txns) {
    return txns
        .where((t) => t['type'] == type)
        .fold(0.0, (sum, t) => sum + double.tryParse(t['amount'].toString())!);
  }

  @override
  Widget build(BuildContext context) {
    String monthYear = DateFormat("MMM yyyy").format(selectedDate);
    final now = DateTime.now();
    final monthlyTxns = _getTransactionsForMonth(now);

    double income = _calculateMonthlyTotal("Income", monthlyTxns);
    double expense = _calculateMonthlyTotal("Expense", monthlyTxns);
    double total = income - expense;

    /// Transactions tab
    Widget transactionsTab = Column(
      children: [
        // Summary only for current month
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummary("Income", income, Colors.green.shade600),
              _buildSummary("Expenses", expense, Colors.red),
              _buildSummary("Total", total, Colors.black),
            ],
          ),
        ),
        // Transaction tabs
        PopupNavi(
          tabs: const ["Daily", "Calender", "Monthly", "Note"],
          currentIndex: transIndex,
          onTabSelected: (index) {
            setState(() => transIndex = index);
          },
        ),

        Expanded(
          child: IndexedStack(
            index: transIndex,
            children: [
              // Show all transactions sorted ascending
              DailyTransactions(
                transactions: transactions,
                monthYear: monthYear,
                isLoggedIn: widget.isLoggedIn,
              ),
              CalendarTransactionsPage(
                transactions: transactions,
                monthYear: monthYear,
              ),
              MonthlyTransactionsPage(transactions: transactions),
              // const Center(
              //   child: Text("Total Summary", style: TextStyle(fontSize: 20)),
              // ),
              NotePage(),
            ],
          ),
        ),
      ],
    );

    /// Stats tab
    Widget statsTab = Column(
      children: [
        PopupNavi(
          tabs: const ["OverAll", "Income", "Expense"],
          currentIndex: statsIndex,
          onTabSelected: (index) {
            setState(() => statsIndex = index);
          },
        ),
        Expanded(
          child: IndexedStack(
            index: statsIndex,
            children: [
              OverallStatsPage(transactions: transactions),
              IncomeReportPage(transactions: transactions),
              ExpenseReportPage(transactions: transactions),
              // TransferReportPage(transfers: transfer),
            ],
          ),
        ),
      ],
    );

    /// Accounts tab
    Widget accountsTab = Column(
      children: [
        PopupNavi(
          tabs: const ["Year", "Month", "Week"],
          currentIndex: accountsIndex,
          onTabSelected: (index) {
            setState(() => accountsIndex = index);
          },
        ),
        Expanded(
          child: IndexedStack(
            index: accountsIndex,
            children: const [
              Center(
                child: Text("Assets Overview", style: TextStyle(fontSize: 20)),
              ),
              Center(
                child: Text(
                  "Liabilities Overview",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Center(
                child: Text("Total Balance", style: TextStyle(fontSize: 20)),
              ),
            ],
          ),
        ),
      ],
    );

    /// Profile tab
    Widget profileTab = Center(
      child: ProfilePage(
        isLoggedIn: widget.isLoggedIn,
        name: widget.name,
        email: widget.email,
      ),
    );

    /// Bottom page stack
    List<Widget> bottomPages = [
      transactionsTab,
      statsTab,
      accountsTab,
      profileTab,
    ];
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(MediaQuery.sizeOf(context).width, 80),
        child: MoneyAppbar(
          monthYear: monthYear,
          prevMonth: _prevMonth,
          nextMonth: _nextMonth,
        ),
      ),
      body: IndexedStack(index: bottomIndex, children: bottomPages),
      floatingActionButton: (transIndex == 3)
          ? null
          : FloatingActionButton(
              onPressed: () async {
                // Navigate to AddTransactionPage and wait until it pops
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddTransactionPage(
                      isLoggedIn: widget.isLoggedIn,
                      editTransaction: {},
                    ),
                  ),
                );
                // After returning, refresh transactions
                await init();
              },
              backgroundColor: Colors.teal,
              child: const Icon(Icons.add, color: Colors.white),
            ),

      bottomNavigationBar: CustomBottomNav(
        currentIndex: bottomIndex,
        onTap: (index) {
          setState(() {
            bottomIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildSummary(String label, double value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(
          "₹ ${value.toStringAsFixed(0)}",
          style: TextStyle(color: color, fontSize: 16),
        ),
      ],
    );
  }
}

// class AppbarFilter extends StatefulWidget {
//   const AppbarFilter({super.key});
//
//   @override
//   State<AppbarFilter> createState() => _AppbarFilterState();
// }
//
// class _AppbarFilterState extends State<AppbarFilter> {
//   String selectedFilter = "All";
//
//   void _openFilterModal() {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ListTile(
//               leading: const Icon(Icons.all_inbox),
//               title: const Text("All"),
//               onTap: () {
//                 setState(() => selectedFilter = "All");
//                 Navigator.pop(context);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.arrow_downward, color: Colors.green),
//               title: const Text("Income"),
//               onTap: () {
//                 setState(() => selectedFilter = "Income");
//                 Navigator.pop(context);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.arrow_upward, color: Colors.red),
//               title: const Text("Expense"),
//               onTap: () {
//                 setState(() => selectedFilter = "Expense");
//                 Navigator.pop(context);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.swap_horiz, color: Colors.blue),
//               title: const Text("Transfer"),
//               onTap: () {
//                 setState(() => selectedFilter = "Transfer");
//                 Navigator.pop(context);
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Filter: $selectedFilter"),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.filter_list),
//             onPressed: _openFilterModal,
//           ),
//         ],
//       ),
//       body: Center(child: Text("Currently showing: $selectedFilter")),
//     );
//   }
// }
