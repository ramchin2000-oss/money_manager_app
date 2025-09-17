import 'dart:convert';
import 'package:http/http.dart' as http;

class TransferService {
  static const String baseUrl = "http://194.238.23.250:3002"; // change in prod
  static const Map<String, String> headers = {
    "Content-Type": "application/json",
  };

  /// Create a new transfer
  static Future<Map<String, dynamic>> createTransfer({
    required int userId,
    required String from,
    required String to,
    required String date,
    required double amount,
    String? note,
  }) async {
    final url = Uri.parse("$baseUrl/transfer");
    final body = {
      "userId": userId,
      "from": from,
      "to": to,
      "date": date,
      "amount": amount,
      if (note != null && note.isNotEmpty) "note": note,
    };

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  /// Get all transfers
  static Future<List<dynamic>> getTransfers() async {
    final url = Uri.parse("$baseUrl/transfer");
    final response = await http.get(url);
    return _handleResponse(response) as List<dynamic>;
  }

  /// Get transfer by ID
  static Future<Map<String, dynamic>> getTransfer(int id) async {
    final url = Uri.parse("$baseUrl/transfer/$id");
    final response = await http.get(url);
    return _handleResponse(response);
  }

  /// Update transfer
  static Future<Map<String, dynamic>> updateTransfer({
    required int id,
    required Map<String, dynamic> data,
  }) async {
    final url = Uri.parse("$baseUrl/transfer/$id");
    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  /// Delete transfer
  static Future<void> deleteTransfer(int id) async {
    final url = Uri.parse("$baseUrl/transfer/$id");
    final response = await http.delete(url);

    if (response.statusCode != 200) {
      throw Exception(
        "Failed to delete transfer (${response.statusCode}): ${response.body}",
      );
    }
  }

  /// Common response handler
  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        "Request failed (${response.statusCode}): ${response.body}",
      );
    }
  }
}
