// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
// class AuthService {
//   final String baseUrl = 'http://194.238.23.250:3002/users';
//
//   // Login user
//   Future<Map<String, dynamic>> login({
//     required String email,
//     required String password,
//   }) async {
//     final response = await http.post(
//       Uri.parse('$baseUrl/login'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({'email': email, 'password': password}),
//     );
//
//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//
//       // Save access token locally
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString('access_token', data['access_token']);
//
//       // Return user data as Map
//       return data['user'];
//     } else {
//       final data = jsonDecode(response.body);
//       throw Exception(data['message'] ?? 'Login failed');
//     }
//   }
//
//   // Get saved access token
//   Future<String?> getAccessToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('access_token');
//   }
//
//   // Logout user
//   Future<void> logout() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('access_token');
//   }
//
//   Future<Map<String, dynamic>> register({
//     required String email,
//     required String password,
//     String? name,
//   }) async {
//     final response = await http.post(
//       Uri.parse('$baseUrl/register'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({
//         'email': email,
//         'password': password,
//         if (name != null) 'name': name,
//       }),
//     );
//
//     if (response.statusCode == 201 || response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       // Return user data as Map without password
//       return data;
//     } else {
//       final data = jsonDecode(response.body);
//       throw Exception(data['message'] ?? 'Registration failed');
//     }
//   }
// }

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/utils.dart';

class AuthService {

  // 🔑 Login user
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);

      // Save access token + userId locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', data['access_token']);
      await prefs.setInt('user_id', data['user']['id']); // 👈 save userId

      // Return user data as Map
      return data['user'];
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Login failed');
    }
  }

  // ✅ Get saved access token
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  // ✅ Get saved userId
  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }

  // ✅ Logout user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('user_id');
  }

  // ✅ Register user
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    String? name,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        if (name != null) 'name': name,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data; // password excluded by backend
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Registration failed');
    }
  }
}
