// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../services/transaction_service.dart';
// import '../services/transfer_service.dart';
//
// class AddTransactionPage extends StatefulWidget {
//   const AddTransactionPage({super.key});
//
//   @override
//   State<AddTransactionPage> createState() => _AddTransactionPageState();
// }
//
// class _AddTransactionPageState extends State<AddTransactionPage> {
//   int selectedType = 0; // 0 = Expense, 1 = Income, 2 = Transfer
//   DateTime selectedDate = DateTime.now();
//   TimeOfDay selectedTime = TimeOfDay.now();
//
//   final TextEditingController amountCtrl = TextEditingController();
//   final TextEditingController noteCtrl = TextEditingController();
//   final TextEditingController descCtrl = TextEditingController();
//
//   final List<String> titles = ["Expense", "Income"];
//
//   bool _isLoading = false;
//
//   // Income categories
//   final List<Map<String, dynamic>> incomeCategories = [
//     {"icon": Icons.attach_money, "name": "Allowance"},
//     {"icon": Icons.work, "name": "Salary"},
//     {"icon": Icons.account_balance_wallet, "name": "Petty Cash"},
//     {"icon": Icons.card_giftcard, "name": "Bonus"},
//     {"icon": Icons.more_horiz, "name": "Other"},
//   ];
//
//   // Expense categories
//   final List<Map<String, dynamic>> expenseCategories = [
//     {"icon": Icons.fastfood, "name": "Food"},
//     {"icon": Icons.movie, "name": "Cinema"},
//     {"icon": Icons.spa, "name": "Beauty"},
//     {"icon": Icons.health_and_safety, "name": "Health"},
//     {"icon": Icons.shopping_cart, "name": "Shopping"},
//     {"icon": Icons.directions_car, "name": "Transport"},
//     {"icon": Icons.home, "name": "Home"},
//     {"icon": Icons.card_giftcard, "name": "Gift"},
//     {"icon": Icons.more_horiz, "name": "Other"},
//   ];
//
//   // Account categories
//   final List<Map<String, dynamic>> accountCategories = [
//     {"icon": Icons.account_balance_wallet, "name": "Cash"},
//     {"icon": Icons.account_balance, "name": "Bank"},
//     {"icon": Icons.credit_card, "name": "Card"},
//     {"icon": Icons.more_horiz, "name": "Other"},
//   ];
//
//   String? selectedCategory;
//   String? selectedAccount;
//   String? selectedTransferToAccount; // For Transfer destination account
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: PreferredSize(
//         preferredSize: Size(MediaQuery.sizeOf(context).width, 80),
//         child: Container(
//           padding: const EdgeInsets.only(
//             top: 35,
//             left: 5,
//             right: 5,
//             bottom: 15,
//           ),
//           decoration: BoxDecoration(
//             color: Colors.teal,
//             borderRadius: const BorderRadius.only(
//               bottomLeft: Radius.circular(12),
//               bottomRight: Radius.circular(12),
//             ),
//           ),
//           child: Row(
//             children: [
//               IconButton(
//                 icon: const Icon(Icons.arrow_back, color: Colors.white),
//                 onPressed: () => Navigator.pop(context),
//               ),
//               const Spacer(),
//               Text(
//                 titles[selectedType],
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 23,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const Spacer(),
//               IconButton(
//                 icon: const Icon(Icons.more_vert, color: Colors.white),
//                 onPressed: () {},
//               ),
//             ],
//           ),
//         ),
//       ),
//       body: Stack(
//         children: [
//           SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 /// Toggle cards
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     _buildTypeCard("Expense", 0, Colors.red, Colors.white),
//                     _buildTypeCard("Income", 1, Colors.green, Colors.white),
//                   ],
//                 ),
//                 const SizedBox(height: 20),
//
//                 /// Date & Time pickers
//                 Row(
//                   children: [
//                     Expanded(
//                       child: GestureDetector(
//                         onTap: _pickDate,
//                         child: _inputBox(
//                           DateFormat.yMMMd().format(selectedDate),
//                           Icons.calendar_today,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: GestureDetector(
//                         onTap: _pickTime,
//                         child: _inputBox(
//                           selectedTime.format(context),
//                           Icons.access_time,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 20),
//
//                 /// Amount input
//                 TextField(
//                   controller: amountCtrl,
//                   keyboardType: TextInputType.number,
//                   decoration: const InputDecoration(
//                     labelText: "Amount",
//                     prefixIcon: Icon(Icons.attach_money),
//                     border: UnderlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//
//                 /// Show Category only if NOT Transfer
//                 if (selectedType != 2) ...[
//                   GestureDetector(
//                     onTap: () => _showCategoryPicker(context),
//                     child: AbsorbPointer(
//                       child: TextField(
//                         decoration: const InputDecoration(
//                           labelText: "Category",
//                           prefixIcon: Icon(Icons.category),
//                           hintText: "Select category",
//                           border: UnderlineInputBorder(),
//                           suffixIcon: Icon(Icons.arrow_drop_down),
//                         ),
//                         controller: TextEditingController(
//                           text: selectedCategory ?? "",
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                 ],
//
//                 /// For Transfer, show From Account and To Account pickers,
//                 /// else show one Account picker
//                 if (selectedType == 2) ...[
//                   GestureDetector(
//                     onTap: () =>
//                         _showAccountPicker(context, isFromAccount: true),
//                     child: AbsorbPointer(
//                       child: TextField(
//                         decoration: const InputDecoration(
//                           labelText: "From Account",
//                           prefixIcon: Icon(Icons.account_balance_wallet),
//                           hintText: "Select account",
//                           border: UnderlineInputBorder(),
//                           suffixIcon: Icon(Icons.arrow_drop_down),
//                         ),
//                         controller: TextEditingController(
//                           text: selectedAccount ?? "",
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   GestureDetector(
//                     onTap: () =>
//                         _showAccountPicker(context, isFromAccount: false),
//                     child: AbsorbPointer(
//                       child: TextField(
//                         decoration: const InputDecoration(
//                           labelText: "To Account",
//                           prefixIcon: Icon(Icons.account_balance_wallet),
//                           hintText: "Select account",
//                           border: UnderlineInputBorder(),
//                           suffixIcon: Icon(Icons.arrow_drop_down),
//                         ),
//                         controller: TextEditingController(
//                           text: selectedTransferToAccount ?? "",
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                 ] else ...[
//                   GestureDetector(
//                     onTap: () =>
//                         _showAccountPicker(context, isFromAccount: true),
//                     child: AbsorbPointer(
//                       child: TextField(
//                         decoration: const InputDecoration(
//                           labelText: "Account",
//                           prefixIcon: Icon(Icons.account_balance_wallet),
//                           hintText: "Select account",
//                           border: UnderlineInputBorder(),
//                           suffixIcon: Icon(Icons.arrow_drop_down),
//                         ),
//                         controller: TextEditingController(
//                           text: selectedAccount ?? "",
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                 ],
//
//                 /// Note input
//                 TextField(
//                   controller: noteCtrl,
//                   decoration: InputDecoration(
//                     labelText: "Note",
//                     prefixIcon: const Icon(Icons.note_alt),
//                     // suffixIcon: IconButton(
//                     //   icon: const Icon(Icons.camera_alt_outlined),
//                     //   onPressed: () {},
//                     // ),
//                     border: const UnderlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 36),
//
//                 /// Save button
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Expanded(
//                       child: ElevatedButton.icon(
//                         onPressed: _saveTransaction,
//                         icon: const Icon(Icons.save, color: Colors.white),
//                         label: const Text(
//                           "SAVE",
//                           style: TextStyle(color: Colors.white),
//                         ),
//                         style: ElevatedButton.styleFrom(
//                           padding: const EdgeInsets.symmetric(vertical: 15),
//                           backgroundColor: Colors.teal,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//
//           /// Loading overlay
//           if (_isLoading)
//             Container(
//               color: Colors.black45,
//               child: const Center(
//                 child: CircularProgressIndicator(color: Colors.white),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   /// Save transaction with validation and async service call
//   Future<void> _saveTransaction() async {
//     final amount = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
//     if (amount <= 0) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Please enter valid amount"),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }
//
//     if (selectedType == 2) {
//       if (selectedAccount == null || selectedAccount!.isEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("Please select From account"),
//             backgroundColor: Colors.red,
//           ),
//         );
//         return;
//       }
//       if (selectedTransferToAccount == null ||
//           selectedTransferToAccount!.isEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("Please select To account"),
//             backgroundColor: Colors.red,
//           ),
//         );
//         return;
//       }
//       if (selectedAccount == selectedTransferToAccount) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("From and To account cannot be the same"),
//             backgroundColor: Colors.red,
//           ),
//         );
//         return;
//       }
//     } else {
//       if (selectedCategory == null || selectedCategory!.isEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("Please select a category"),
//             backgroundColor: Colors.red,
//           ),
//         );
//         return;
//       }
//       if (selectedAccount == null || selectedAccount!.isEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("Please select an account"),
//             backgroundColor: Colors.red,
//           ),
//         );
//         return;
//       }
//     }
//
//     setState(() => _isLoading = true);
//
//     try {
//       final combined = DateTime(
//         selectedDate.year,
//         selectedDate.month,
//         selectedDate.day,
//         selectedTime.hour,
//         selectedTime.minute,
//       );
//       final isoDate = combined.toIso8601String();
//
//       String typeStr = selectedType == 0 ? "Expense" : "Income";
//
//       if (selectedType == 2) {
//         await TransferService.createTransfer(
//           userId: 1,
//           from: selectedAccount!,
//           to: selectedTransferToAccount!,
//           date: isoDate,
//           amount: amount,
//           note: noteCtrl.text.trim(),
//         );
//       } else {
//         // Pass 'toAccount' only for Transfer type
//         await TransactionService.addTransaction(
//           category: selectedType == 2 ? "Transfer" : selectedCategory!,
//           amount: amount,
//           type: typeStr,
//           note: noteCtrl.text.trim(),
//           account: selectedAccount!,
//           toAccount: selectedType == 2 ? selectedTransferToAccount! : null,
//           userId: 1,
//           date: isoDate,
//         );
//       }
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Saved Successfully"),
//           backgroundColor: Colors.green,
//         ),
//       );
//
//       amountCtrl.clear();
//       noteCtrl.clear();
//       descCtrl.clear();
//
//       setState(() {
//         selectedCategory = null;
//         selectedAccount = null;
//         selectedTransferToAccount = null;
//         selectedType = 0;
//         selectedDate = DateTime.now();
//         selectedTime = TimeOfDay.now();
//       });
//
//       Navigator.pop(context, true);
//     } catch (e) {
//       debugPrint("Error saving: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Error saving: $e"),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   Future<void> _pickDate() async {
//     DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: selectedDate,
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2100),
//     );
//     if (picked != null) setState(() => selectedDate = picked);
//   }
//
//   Future<void> _pickTime() async {
//     TimeOfDay? picked = await showTimePicker(
//       context: context,
//       initialTime: selectedTime,
//     );
//     if (picked != null) setState(() => selectedTime = picked);
//   }
//
//   Widget _buildTypeCard(String text, int index, Color color, Color textColor) {
//     bool isSelected = selectedType == index;
//     return Expanded(
//       child: GestureDetector(
//         onTap: () {
//           setState(() {
//             selectedType = index;
//             selectedCategory = null;
//             selectedAccount = null;
//             selectedTransferToAccount = null;
//           });
//         },
//         child: Card(
//           color: isSelected ? color.withValues(alpha: 0.8) : Colors.grey[200],
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//           margin: EdgeInsets.symmetric(horizontal: 10),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(vertical: 10),
//             child: Center(
//               child: Text(
//                 text,
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: isSelected ? textColor : Colors.black87,
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _inputBox(String value, IconData icon) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey.shade400),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Row(
//         children: [
//           Icon(icon, size: 20, color: Colors.grey[700]),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(fontWeight: FontWeight.bold),
//               textAlign: TextAlign.center,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showCategoryPicker(BuildContext context) {
//     final categories = selectedType == 0 ? expenseCategories : incomeCategories;
//     _showGridBottomSheet(
//       context,
//       categories,
//       (value) => setState(() => selectedCategory = value),
//     );
//   }
//
//   void _showAccountPicker(BuildContext context, {required bool isFromAccount}) {
//     _showGridBottomSheet(context, accountCategories, (value) {
//       setState(() {
//         if (isFromAccount) {
//           selectedAccount = value;
//         } else {
//           selectedTransferToAccount = value;
//         }
//       });
//     });
//   }
//
//   void _showGridBottomSheet(
//     BuildContext context,
//     List<Map<String, dynamic>> items,
//     Function(String) onSelected,
//   ) {
//     showModalBottomSheet(
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       context: context,
//       builder: (ctx) {
//         return Padding(
//           padding: const EdgeInsets.all(16),
//           child: GridView.count(
//             shrinkWrap: true,
//             crossAxisCount: 3,
//             crossAxisSpacing: 12,
//             mainAxisSpacing: 12,
//             children: items.map((item) {
//               return GestureDetector(
//                 onTap: () {
//                   onSelected(item["name"]);
//                   Navigator.pop(context);
//                 },
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     CircleAvatar(
//                       radius: 26,
//                       backgroundColor: Colors.blue.shade50,
//                       child: Icon(item["icon"], color: Colors.blue),
//                     ),
//                     const SizedBox(height: 6),
//                     Text(
//                       item["name"],
//                       style: const TextStyle(fontSize: 13),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ],
//                 ),
//               );
//             }).toList(),
//           ),
//         );
//       },
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../services/transaction_service.dart';
// import 'login_page.dart';
//
// class AddTransactionPage extends StatefulWidget {
//   final bool isLoggedIn;
//   final Map<String, dynamic> editTransaction;
//   const AddTransactionPage({
//     super.key,
//     required this.isLoggedIn,
//     required this.editTransaction,
//   });
//
//   @override
//   State<AddTransactionPage> createState() => _AddTransactionPageState();
// }
//
// class _AddTransactionPageState extends State<AddTransactionPage> {
//   int selectedType = 0; // 0 = Expense, 1 = Income
//   DateTime selectedDate = DateTime.now();
//   TimeOfDay selectedTime = TimeOfDay.now();
//
//   final TextEditingController amountCtrl = TextEditingController();
//   final TextEditingController noteCtrl = TextEditingController();
//
//   final List<String> titles = ["Expense", "Income"];
//
//   bool _isLoading = false;
//
//   // Income categories
//   final List<Map<String, dynamic>> incomeCategories = [
//     {"icon": Icons.attach_money, "name": "Allowance"},
//     {"icon": Icons.work, "name": "Salary"},
//     {"icon": Icons.account_balance_wallet, "name": "Petty Cash"},
//     {"icon": Icons.card_giftcard, "name": "Bonus"},
//     {"icon": Icons.more_horiz, "name": "Other"},
//   ];
//
//   // Expense categories
//   final List<Map<String, dynamic>> expenseCategories = [
//     {"icon": Icons.fastfood, "name": "Food"},
//     {"icon": Icons.movie, "name": "Cinema"},
//     {"icon": Icons.spa, "name": "Beauty"},
//     {"icon": Icons.health_and_safety, "name": "Health"},
//     {"icon": Icons.shopping_cart, "name": "Shopping"},
//     {"icon": Icons.directions_car, "name": "Transport"},
//     {"icon": Icons.home, "name": "Home"},
//     {"icon": Icons.card_giftcard, "name": "Gift"},
//     {"icon": Icons.more_horiz, "name": "Other"},
//   ];
//
//   // Account categories
//   final List<Map<String, dynamic>> accountCategories = [
//     {"icon": Icons.account_balance_wallet, "name": "Cash"},
//     {"icon": Icons.account_balance, "name": "Bank"},
//     {"icon": Icons.credit_card, "name": "Card"},
//     {"icon": Icons.more_horiz, "name": "Other"},
//   ];
//
//   String? selectedCategory;
//   String? selectedAccount;
//
//   /// Show login prompt dialog
//   void _showLoginPrompt() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Login Required"),
//         content: const Text("Please login to continue."),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("Cancel"),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context); // Close dialog
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => const LoginPage()),
//               );
//             },
//             child: const Text("Login"),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     print(widget.editTransaction);
//     return Scaffold(
//       appBar: PreferredSize(
//         preferredSize: Size(MediaQuery.sizeOf(context).width, 80),
//         child: Container(
//           padding: const EdgeInsets.only(
//             top: 35,
//             left: 5,
//             right: 5,
//             bottom: 15,
//           ),
//           decoration: BoxDecoration(
//             color: Colors.teal,
//             borderRadius: const BorderRadius.only(
//               bottomLeft: Radius.circular(12),
//               bottomRight: Radius.circular(12),
//             ),
//           ),
//           child: Row(
//             children: [
//               IconButton(
//                 icon: const Icon(Icons.arrow_back, color: Colors.white),
//                 onPressed: () => Navigator.pop(context),
//               ),
//               const Spacer(),
//               Text(
//                 titles[selectedType],
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 23,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const Spacer(),
//               IconButton(
//                 icon: const Icon(Icons.more_vert, color: Colors.white),
//                 onPressed: () {},
//               ),
//             ],
//           ),
//         ),
//       ),
//       body: Stack(
//         children: [
//           SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 /// Toggle cards
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     _buildTypeCard("Expense", 0, Colors.red, Colors.white),
//                     _buildTypeCard("Income", 1, Colors.green, Colors.white),
//                   ],
//                 ),
//                 const SizedBox(height: 20),
//
//                 /// Date & Time pickers
//                 Row(
//                   children: [
//                     Expanded(
//                       child: GestureDetector(
//                         onTap: _pickDate,
//                         child: _inputBox(
//                           DateFormat.yMMMd().format(selectedDate),
//                           Icons.calendar_today,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: GestureDetector(
//                         onTap: _pickTime,
//                         child: _inputBox(
//                           selectedTime.format(context),
//                           Icons.access_time,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 20),
//
//                 /// Amount input
//                 TextField(
//                   controller: amountCtrl,
//                   keyboardType: TextInputType.number,
//                   decoration: const InputDecoration(
//                     labelText: "Amount",
//                     prefixIcon: Icon(Icons.attach_money),
//                     border: UnderlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//
//                 /// Category picker
//                 GestureDetector(
//                   onTap: () => _showCategoryPicker(context),
//                   child: AbsorbPointer(
//                     child: TextField(
//                       decoration: const InputDecoration(
//                         labelText: "Category",
//                         prefixIcon: Icon(Icons.category),
//                         hintText: "Select category",
//                         border: UnderlineInputBorder(),
//                         suffixIcon: Icon(Icons.arrow_drop_down),
//                       ),
//                       controller: TextEditingController(
//                         text: selectedCategory ?? "",
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//
//                 /// Account picker
//                 GestureDetector(
//                   onTap: () => _showAccountPicker(context),
//                   child: AbsorbPointer(
//                     child: TextField(
//                       decoration: const InputDecoration(
//                         labelText: "Account",
//                         prefixIcon: Icon(Icons.account_balance_wallet),
//                         hintText: "Select account",
//                         border: UnderlineInputBorder(),
//                         suffixIcon: Icon(Icons.arrow_drop_down),
//                       ),
//                       controller: TextEditingController(
//                         text: selectedAccount ?? "",
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//
//                 /// Note input
//                 TextField(
//                   controller: noteCtrl,
//                   decoration: const InputDecoration(
//                     labelText: "Note",
//                     prefixIcon: Icon(Icons.note_alt),
//                     border: UnderlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 36),
//
//                 /// Save button
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Expanded(
//                       child: ElevatedButton.icon(
//                         onPressed: () {
//                           if (widget.isLoggedIn) {
//                             _saveTransaction(); // ✅ Save normally
//                           } else {
//                             _showLoginPrompt(); // ⚠️ Show login dialog
//                           }
//                         },
//                         icon: const Icon(Icons.save, color: Colors.white),
//                         label: const Text(
//                           "SAVE",
//                           style: TextStyle(color: Colors.white),
//                         ),
//                         style: ElevatedButton.styleFrom(
//                           padding: const EdgeInsets.symmetric(vertical: 15),
//                           backgroundColor: Colors.teal,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//
//           /// Loading overlay
//           if (_isLoading)
//             Container(
//               color: Colors.black45,
//               child: const Center(
//                 child: CircularProgressIndicator(color: Colors.white),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   /// Save transaction with validation and async service call
//   Future<void> _saveTransaction() async {
//     final amount = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
//     if (amount <= 0) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Please enter valid amount"),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }
//
//     if (selectedCategory == null || selectedCategory!.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Please select a category"),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }
//     if (selectedAccount == null || selectedAccount!.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Please select an account"),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }
//
//     setState(() => _isLoading = true);
//
//     try {
//       final combined = DateTime(
//         selectedDate.year,
//         selectedDate.month,
//         selectedDate.day,
//         selectedTime.hour,
//         selectedTime.minute,
//       );
//       final isoDate = combined.toIso8601String();
//
//       String typeStr = selectedType == 0 ? "Expense" : "Income";
//
//       await TransactionService.addTransaction(
//         category: selectedCategory!,
//         amount: amount,
//         type: typeStr,
//         note: noteCtrl.text.trim(),
//         account: selectedAccount!,
//         date: isoDate,
//       );
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Saved Successfully"),
//           backgroundColor: Colors.green,
//         ),
//       );
//
//       amountCtrl.clear();
//       noteCtrl.clear();
//
//       setState(() {
//         selectedCategory = null;
//         selectedAccount = null;
//         selectedType = 0;
//         selectedDate = DateTime.now();
//         selectedTime = TimeOfDay.now();
//       });
//
//       Navigator.pop(context, true);
//     } catch (e) {
//       debugPrint("Error saving: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Error saving: $e"),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   Future<void> _pickDate() async {
//     DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: selectedDate,
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2100),
//     );
//     if (picked != null) setState(() => selectedDate = picked);
//   }
//
//   Future<void> _pickTime() async {
//     TimeOfDay? picked = await showTimePicker(
//       context: context,
//       initialTime: selectedTime,
//     );
//     if (picked != null) setState(() => selectedTime = picked);
//   }
//
//   Widget _buildTypeCard(String text, int index, Color color, Color textColor) {
//     bool isSelected = selectedType == index;
//     return Expanded(
//       child: GestureDetector(
//         onTap: () {
//           setState(() {
//             selectedType = index;
//             selectedCategory = null;
//             selectedAccount = null;
//           });
//         },
//         child: Card(
//           color: isSelected ? color.withValues(alpha: 0.8) : Colors.grey[200],
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//           margin: const EdgeInsets.symmetric(horizontal: 10),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(vertical: 10),
//             child: Center(
//               child: Text(
//                 text,
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: isSelected ? textColor : Colors.black87,
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _inputBox(String value, IconData icon) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey.shade400),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Row(
//         children: [
//           Icon(icon, size: 20, color: Colors.grey[700]),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(fontWeight: FontWeight.bold),
//               textAlign: TextAlign.center,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showCategoryPicker(BuildContext context) {
//     final categories = selectedType == 0 ? expenseCategories : incomeCategories;
//     _showGridBottomSheet(
//       context,
//       categories,
//       (value) => setState(() => selectedCategory = value),
//     );
//   }
//
//   void _showAccountPicker(BuildContext context) {
//     _showGridBottomSheet(
//       context,
//       accountCategories,
//       (value) => setState(() => selectedAccount = value),
//     );
//   }
//
//   void _showGridBottomSheet(
//     BuildContext context,
//     List<Map<String, dynamic>> items,
//     Function(String) onSelected,
//   ) {
//     showModalBottomSheet(
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       context: context,
//       builder: (ctx) {
//         return Padding(
//           padding: const EdgeInsets.all(16),
//           child: GridView.count(
//             shrinkWrap: true,
//             crossAxisCount: 3,
//             crossAxisSpacing: 12,
//             mainAxisSpacing: 12,
//             children: items.map((item) {
//               return GestureDetector(
//                 onTap: () {
//                   onSelected(item["name"]);
//                   Navigator.pop(context);
//                 },
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     CircleAvatar(
//                       radius: 26,
//                       backgroundColor: Colors.blue.shade50,
//                       child: Icon(item["icon"], color: Colors.blue),
//                     ),
//                     const SizedBox(height: 6),
//                     Text(
//                       item["name"],
//                       style: const TextStyle(fontSize: 13),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ],
//                 ),
//               );
//             }).toList(),
//           ),
//         );
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/transaction_service.dart';
import 'login_page.dart';

class AddTransactionPage extends StatefulWidget {
  final bool isLoggedIn;
  final Map<String, dynamic>? editTransaction; // Nullable

  const AddTransactionPage({
    super.key,
    required this.isLoggedIn,
    this.editTransaction,
  });

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  int selectedType = 0; // 0 = Expense, 1 = Income
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  // @override
  // void initState1() {
  //   super.initState();
  //   init();
  // }
  //
  // Future<void> init() async {
  //   try {
  //     final tr = await TransactionService.fetchTransactions();
  //     setState(() {
  //       widget.transactions = tr;
  //     });
  //   } catch (e) {
  //     print("Error loading transactions: $e");
  //   }
  // }

  final TextEditingController amountCtrl = TextEditingController();
  final TextEditingController noteCtrl = TextEditingController();

  final List<String> titles = ["Expense", "Income"];

  bool _isLoading = false;

  // Income categories
  final List<Map<String, dynamic>> incomeCategories = [
    {"icon": Icons.attach_money, "name": "Allowance"},
    {"icon": Icons.work, "name": "Salary"},
    {"icon": Icons.account_balance_wallet, "name": "Petty Cash"},
    {"icon": Icons.card_giftcard, "name": "Bonus"},
    {"icon": Icons.more_horiz, "name": "Other"},
  ];

  // Expense categories
  final List<Map<String, dynamic>> expenseCategories = [
    {"icon": Icons.fastfood, "name": "Food"},
    {"icon": Icons.movie, "name": "Cinema"},
    {"icon": Icons.spa, "name": "Beauty"},
    {"icon": Icons.health_and_safety, "name": "Health"},
    {"icon": Icons.shopping_cart, "name": "Shopping"},
    {"icon": Icons.directions_car, "name": "Transport"},
    {"icon": Icons.home, "name": "Home"},
    {"icon": Icons.card_giftcard, "name": "Gift"},
    {"icon": Icons.more_horiz, "name": "Other"},
  ];

  // Account categories
  final List<Map<String, dynamic>> accountCategories = [
    {"icon": Icons.account_balance_wallet, "name": "Cash"},
    {"icon": Icons.account_balance, "name": "Bank"},
    {"icon": Icons.credit_card, "name": "Card"},
    {"icon": Icons.more_horiz, "name": "Other"},
  ];

  String? selectedCategory;
  String? selectedAccount;

  @override
  void initState() {
    super.initState();
    if (widget.editTransaction != null && widget.editTransaction!.isNotEmpty) {
      final t = widget.editTransaction!;
      selectedType = t['type'] == "Income" ? 1 : 0;
      amountCtrl.text = t['amount']?.toString() ?? '';
      noteCtrl.text = t['note'] ?? '';
      selectedCategory = t['category'];
      selectedAccount = t['account'];
      DateTime d = DateTime.parse(t['date']);
      selectedDate = d;
      selectedTime = TimeOfDay(hour: d.hour, minute: d.minute);
    }
  }

  void _showLoginPrompt() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Login Required"),
        content: const Text("Please login to continue."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
            child: const Text("Login"),
          ),
        ],
      ),
    );
  }

  Future<void> _saveOrUpdateTransaction() async {
    final amount = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter valid amount"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedCategory == null || selectedCategory!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a category"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (selectedAccount == null || selectedAccount!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select an account"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final combined = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );
      final isoDate = combined.toIso8601String();
      String typeStr = selectedType == 0 ? "Expense" : "Income";

      if (widget.editTransaction == null || widget.editTransaction!.isEmpty) {
        // Add
        await TransactionService.addTransaction(
          category: selectedCategory!,
          amount: amount,
          type: typeStr,
          note: noteCtrl.text.trim(),
          account: selectedAccount!,
          date: isoDate,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Saved Successfully"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final Map<String, dynamic> txnData = {
          "category": selectedCategory!,
          "amount": amount,
          "type": typeStr,
          "note": noteCtrl.text.trim(),
          "account": selectedAccount!,
          "date": isoDate,
        };

        // Update
        await TransactionService.updateTransaction(
          widget.editTransaction!['id'],
          txnData,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Updated Successfully"),
            backgroundColor: Colors.green,
          ),
        );
      }

      amountCtrl.clear();
      noteCtrl.clear();

      setState(() {
        selectedCategory = null;
        selectedAccount = null;
        selectedType = 0;
        selectedDate = DateTime.now();
        selectedTime = TimeOfDay.now();
      });

      Navigator.pop(context, true);
    } catch (e) {
      debugPrint("Error saving: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error saving: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteTransaction() async {
    if (widget.editTransaction == null || widget.editTransaction!.isEmpty)
      return;
    setState(() => _isLoading = true);
    try {
      await TransactionService.deleteTransaction(widget.editTransaction!['id']);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Deleted Successfully"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      debugPrint("Error deleting: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error deleting: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> _pickTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null) setState(() => selectedTime = picked);
  }

  Widget _buildTypeCard(String text, int index, Color color, Color textColor) {
    bool isSelected = selectedType == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedType = index;
            selectedCategory = null;
            selectedAccount = null;
          });
        },
        child: Card(
          color: isSelected ? color.withValues(alpha: 0.8) : Colors.grey[200],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? textColor : Colors.black87,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputBox(String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  void _showCategoryPicker(BuildContext context) {
    final categories = selectedType == 0 ? expenseCategories : incomeCategories;
    _showGridBottomSheet(
      context,
      categories,
      (value) => setState(() => selectedCategory = value),
    );
  }

  void _showAccountPicker(BuildContext context) {
    _showGridBottomSheet(
      context,
      accountCategories,
      (value) => setState(() => selectedAccount = value),
    );
  }

  void _showGridBottomSheet(
    BuildContext context,
    List<Map<String, dynamic>> items,
    Function(String) onSelected,
  ) {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      context: context,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.count(
            shrinkWrap: true,
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: items.map((item) {
              return GestureDetector(
                onTap: () {
                  onSelected(item["name"]);
                  Navigator.pop(context);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.blue.shade50,
                      child: Icon(item["icon"], color: Colors.blue),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item["name"],
                      style: const TextStyle(fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(MediaQuery.sizeOf(context).width, 80),
        child: Container(
          padding: const EdgeInsets.only(
            top: 35,
            left: 5,
            right: 5,
            bottom: 15,
          ),
          decoration: BoxDecoration(
            color: Colors.teal,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Spacer(),
              Text(
                titles[selectedType],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Toggle cards
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTypeCard("Expense", 0, Colors.red, Colors.white),
                    _buildTypeCard("Income", 1, Colors.green, Colors.white),
                  ],
                ),
                const SizedBox(height: 20),

                /// Date & Time pickers
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _pickDate,
                        child: _inputBox(
                          DateFormat.yMMMd().format(selectedDate),
                          Icons.calendar_today,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: _pickTime,
                        child: _inputBox(
                          selectedTime.format(context),
                          Icons.access_time,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                /// Amount input
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Amount",
                    prefixIcon: Icon(Icons.attach_money),
                    border: UnderlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                /// Category picker
                GestureDetector(
                  onTap: () => _showCategoryPicker(context),
                  child: AbsorbPointer(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: "Category",
                        prefixIcon: Icon(Icons.category),
                        hintText: "Select category",
                        border: UnderlineInputBorder(),
                        suffixIcon: Icon(Icons.arrow_drop_down),
                      ),
                      controller: TextEditingController(
                        text: selectedCategory ?? "",
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                /// Account picker
                GestureDetector(
                  onTap: () => _showAccountPicker(context),
                  child: AbsorbPointer(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: "Account",
                        prefixIcon: Icon(Icons.account_balance_wallet),
                        hintText: "Select account",
                        border: UnderlineInputBorder(),
                        suffixIcon: Icon(Icons.arrow_drop_down),
                      ),
                      controller: TextEditingController(
                        text: selectedAccount ?? "",
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                /// Note input
                TextField(
                  controller: noteCtrl,
                  decoration: const InputDecoration(
                    labelText: "Note",
                    prefixIcon: Icon(Icons.note_alt),
                    border: UnderlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 36),

                /// Save/Update and Delete buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (widget.isLoggedIn) {
                            _saveOrUpdateTransaction();
                          } else {
                            _showLoginPrompt();
                          }
                        },
                        icon: const Icon(Icons.save, color: Colors.white),
                        label: Text(
                          widget.editTransaction == null ||
                                  widget.editTransaction!.isEmpty
                              ? "SAVE"
                              : "UPDATE",
                          style: const TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          backgroundColor: Colors.teal,
                        ),
                      ),
                    ),
                    if (widget.editTransaction != null &&
                        widget.editTransaction!.isNotEmpty)
                      const SizedBox(width: 12),
                    if (widget.editTransaction != null &&
                        widget.editTransaction!.isNotEmpty)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (widget.isLoggedIn) {
                              _deleteTransaction();
                            } else {
                              _showLoginPrompt();
                            }
                          },
                          icon: const Icon(Icons.delete, color: Colors.white),
                          label: const Text(
                            "DELETE",
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            backgroundColor: Colors.red,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black45,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
