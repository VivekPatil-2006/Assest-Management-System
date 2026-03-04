import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = "http://YOUR_SERVER_URL/api/auth";

  /* ==============================
        LOGIN
  ============================== */

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {

    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data["success"] == true) {
      return data;
    } else {
      throw Exception(data["message"] ?? "Login failed");
    }
  }

  /* ==============================
        SIGNUP
  ============================== */

  static Future<Map<String, dynamic>> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
    required String role,
    String? department,
  }) async {

    final response = await http.post(
      Uri.parse("$baseUrl/signup"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        "password": password,
        "confirmPassword": confirmPassword,
        "role": role,
        "department": department
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201 && data["success"] == true) {
      return data;
    } else {
      throw Exception(data["message"] ?? "Signup failed");
    }
  }
}