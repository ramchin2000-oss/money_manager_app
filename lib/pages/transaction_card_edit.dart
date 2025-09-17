import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/transaction_service.dart';

class TransactionEditPage extends StatefulWidget {
  final Map<String, dynamic> txn;

  const TransactionEditPage({super.key, required this.txn});

  @override
  State<TransactionEditPage> createState() => _TransactionEditPageState();
}

class _TransactionEditPageState extends State<TransactionEditPage> {
  late TextEditingController categoryController;
  late TextEditingController accountController;
  late TextEditingController amountController;
  late TextEditingController noteController;
  late String type;

  @override
  void initState() {
    super.initState();
    final txn = widget.txn;
    categoryController = TextEditingController(text: txn['category'] ?? "");
    accountController = TextEditingController(text: txn['account'] ?? "");
    amountController = TextEditingController(text: txn['amount'].toString());
    noteController = TextEditingController(text: txn['note'] ?? "");
    type = txn['type'];
  }

  @override
  void dispose() {
    categoryController.dispose();
    accountController.dispose();
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  /// ✅ Save (Update) Transaction
  Future<void> _saveTransaction() async {
    final updated = {
      "id": widget.txn['id'],
      "amount":
          double.tryParse(amountController.text.trim()) ?? widget.txn['amount'],
      "type": type,
      "category": categoryController.text.trim(),
      "account": accountController.text.trim().isEmpty
          ? null
          : accountController.text.trim(),
      "note": noteController.text.trim().isEmpty
          ? null
          : noteController.text.trim(),
      "date": widget.txn['date'],
      "createdAt": widget.txn['createdAt'],
      "userId": widget.txn['userId'],
    };

    await TransactionService.updateTransaction(widget.txn['id'], updated);
    Navigator.pop(context, true); // return success
  }

  /// ✅ Delete Transaction
  Future<void> _deleteTransaction() async {
    await TransactionService.deleteTransaction(widget.txn['id']);
    Navigator.pop(context, true); // return success
  }

  @override
  Widget build(BuildContext context) {
    final txn = widget.txn;

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Transaction")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ✅ Date & Time
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat.yMMMd().format(DateTime.parse(txn['date'])),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    DateFormat.jm().format(DateTime.parse(txn['date'])),
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ✅ Type selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: ["Income", "Expense"].map((t) {
                  final isSelected = type == t;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => type = t),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected ? Colors.orange : Colors.grey,
                          ),
                          borderRadius: BorderRadius.circular(6),
                          color: isSelected
                              ? Colors.orange.shade50
                              : Colors.transparent,
                        ),
                        child: Center(
                          child: Text(
                            t,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.orange
                                  : Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // ✅ Input fields
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount'),
              ),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              TextField(
                controller: accountController,
                decoration: const InputDecoration(labelText: 'Account'),
              ),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(labelText: 'Note'),
              ),
              const SizedBox(height: 20),

              // ✅ Buttons Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton.icon(
                    onPressed: _deleteTransaction,
                    icon: const Icon(Icons.delete),
                    label: const Text("Delete"),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ✅ Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveTransaction,
                  child: const Text("Save"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
