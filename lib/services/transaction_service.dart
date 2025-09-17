// import 'dart:convert';
// import 'package:http/http.dart' as http;
//
// class TransactionService {
//   static String baseUrl = "http://194.238.23.250:3002";
//
//   /// Fetch all transactions
//   static Future<List<dynamic>> fetchTransactions() async {
//     try {
//       final response = await http.get(Uri.parse("$baseUrl/transactions"));
//       if (response.statusCode == 200) {
//         return jsonDecode(response.body);
//       } else {
//         throw Exception("Failed to fetch transactions: ${response.statusCode}");
//       }
//     } catch (e) {
//       throw Exception("Error fetching transactions: $e");
//     }
//   }
//
//   /// Get single transaction by ID
//   static Future<Map<String, dynamic>> fetchTransactionById(int id) async {
//     try {
//       final response = await http.get(Uri.parse("$baseUrl/transactions/$id"));
//
//       if (response.statusCode == 200) {
//         return jsonDecode(response.body) as Map<String, dynamic>;
//       } else {
//         throw Exception("Failed to fetch transaction: ${response.statusCode}");
//       }
//     } catch (e) {
//       throw Exception("Error fetching transaction: $e");
//     }
//   }
//
//   /// Add a transaction
//   static Future<void> addTransaction({
//     required String category,
//     required double amount,
//     required String type, // "Income" | "Expense"
//     int userId = 1, // temporary hardcoded userId (or pass from auth)
//     String? note,
//     String? account,
//     String? date,
//     String? toAccount,
//   }) async {
//     try {
//       final txn = {
//         "category": category,
//         "amount": double.parse(amount.toStringAsFixed(1)),
//         "type": type,
//         "note": note,
//         "account": account,
//         "userId": userId,
//         "date": date,
//       };
//
//       final response = await http.post(
//         Uri.parse("$baseUrl/transactions"),
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode(txn),
//       );
//       print('Response body: ${response.body}');
//
//       if (response.statusCode != 200 && response.statusCode != 201) {
//         throw Exception("Failed to save transaction: ${response.statusCode}");
//       }
//     } catch (e) {
//       throw Exception("Error saving transaction: $e");
//     }
//   }
//
//   // ✅ Update transaction
//   static Future<void> updateTransaction(
//     int id,
//     Map<String, dynamic> txn,
//   ) async {
//     final response = await http.put(
//       Uri.parse("$baseUrl/transactions/$id"),
//       headers: {"Content-Type": "application/json"},
//       body: jsonEncode(txn),
//     );
//
//     if (response.statusCode != 200) {
//       throw Exception("Failed to update transaction");
//     }
//   }
//
//   // ✅ Delete transaction
//   static Future<void> deleteTransaction(int id) async {
//     final response = await http.delete(Uri.parse("$baseUrl/transactions/$id"));
//
//     if (response.statusCode != 200) {
//       throw Exception("Failed to delete transaction");
//     }
//   }
// }

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TransactionService {
  // static String baseUrl = "https://rdt3tvjb-3002.inc1.devtunnels.ms";
  static String baseUrl = "http://194.238.23.250:3002";

  /// 🔑 Get headers with JWT
  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");
    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  /// ✅ Fetch all transactions
  static Future<List<dynamic>> fetchTransactions() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse("$baseUrl/transactions"),
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to fetch transactions: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching transactions: $e");
    }
  }

  /// ✅ Get single transaction by ID
  static Future<Map<String, dynamic>> fetchTransactionById(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse("$baseUrl/transactions/$id"),
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception("Failed to fetch transaction: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching transaction: $e");
    }
  }

  /// ✅ Add a transaction (JWT required)
  static Future<void> addTransaction({
    required String category,
    required double amount,
    required String type, // "Income" | "Expense"
    String? note,
    String? account,
    String? date,
  }) async {
    try {
      // Prepare transaction payload (without userId)
      final txn = {
        "category": category,
        "amount": double.parse(amount.toStringAsFixed(1)),
        "type": type,
        "note": note,
        "account": account,
        "date": date,
      };
      print('datas.....: $txn');

      // Get headers with JWT
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse("$baseUrl/transactions"),
        headers: headers,
        body: jsonEncode(txn),
      );

      print('a.....');
      print("Response body: ${response.body}");

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception("Failed to save transaction: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error saving transaction: $e");
    }
  }

  /// ✅ Update transaction
  static Future<void> updateTransaction(
    int id,
    Map<String, dynamic> txn,
  ) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse("$baseUrl/transactions/$id"),
      headers: headers,
      body: jsonEncode(txn),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to update transaction");
    }
  }

  /// ✅ Delete transaction
  static Future<void> deleteTransaction(int id) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse("$baseUrl/transactions/$id"),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to delete transaction");
    }
  }
}
