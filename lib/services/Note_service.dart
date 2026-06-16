import 'dart:convert';
import 'package:http/http.dart' as http;

import '../utils/utils.dart';

class NoteService {
  // Base URL for your API
  final isoDate = DateTime.now().toIso8601String();

  NoteService();

  /// Create a new note
  Future<Map<String, dynamic>> create({
    required String title,
    required String content,
    required int userId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/notes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'content': content,
        'userId': userId,
        'date': isoDate,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create note: ${response.statusCode}');
    }
  }

  /// Fetch all notes
  Future<List<Map<String, dynamic>>> findAll() async {
    final response = await http.get(Uri.parse('$baseUrl/notes'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(jsonList);
    } else {
      throw Exception('Failed to fetch notes: ${response.statusCode}');
    }
  }

  /// Fetch a single note by ID
  Future<Map<String, dynamic>> findOne(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/notes/$id'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch note: ${response.statusCode}');
    }
  }

  /// Update a note
  Future<Map<String, dynamic>> update(
    int id, {
    String? title,
    String? content,
  }) async {
    print(' updete service :${title} ${content}');
    final body = <String, String>{};
    if (title != null) body['title'] = title;
    if (content != null) body['content'] = content;

    final response = await http.put(
      Uri.parse('$baseUrl/notes/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update note: ${response.statusCode}');
    }
  }

  /// Delete a note
  Future<void> remove(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/notes/$id'));

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete note: ${response.statusCode}');
    }
  }
}
