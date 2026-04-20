import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = String.fromEnvironment(
    "API_AUTH_BASE_URL",
    defaultValue: "https://asset-management-system-bk61.onrender.com/api/auth",
  );
  static const Duration _requestTimeout = Duration(seconds: 25);

  /* ==============================
        LOGIN
  ============================== */

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {

    final response = await _safeRequest(
      () => http
          .post(
            Uri.parse("$baseUrl/login"),
            headers: {
              "Content-Type": "application/json",
            },
            body: jsonEncode({
              "email": email,
              "password": password,
            }),
          )
          .timeout(_requestTimeout),
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

    final response = await _safeRequest(
      () => http
          .post(
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
          )
          .timeout(_requestTimeout),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201 && data["success"] == true) {
      return data;
    } else {
      throw Exception(data["message"] ?? "Signup failed");
    }
  }

  static Future<http.Response> _safeRequest(
    Future<http.Response> Function() request,
  ) async {
    try {
      return await request();
    } on SocketException {
      throw Exception(
        "Cannot reach server. Check internet connection or verify API host DNS.",
      );
    } on TimeoutException {
      throw Exception("Request timed out. Please try again.");
    } on HttpException catch (e) {
      throw Exception("Network error: ${e.message}");
    }
  }
}