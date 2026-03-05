import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  // Change per environment
  static const String baseUrl = "https://asset-management-system-bk61.onrender.com/api";

  // Secure token storage
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _tokenKey = "ams_jwt_token";

  // =========================
  // Auth token helpers
  // =========================
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return _storage.read(key: _tokenKey);
  }

  static Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }

  static Future<String> _requireToken() async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      throw Exception("User not authenticated");
    }
    return token;
  }

  // =========================
  // Core HTTP methods
  // =========================
  static Future<dynamic> getPublic(String path) async {
    final response = await http.get(
      Uri.parse("$baseUrl$path"),
      headers: {"Content-Type": "application/json"},
    );

    _handleError(response);
    return _decodeBody(response);
  }

  static Future<dynamic> postPublic(
      String path,
      Map<String, dynamic> body,
      ) async {
    final response = await http.post(
      Uri.parse("$baseUrl$path"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    _handleError(response);
    return _decodeBody(response);
  }

  static Future<dynamic> get(String path) async {
    final token = await _requireToken();

    final response = await http.get(
      Uri.parse("$baseUrl$path"),
      headers: {"Authorization": "Bearer $token"},
    );

    _handleError(response);
    return _decodeBody(response);
  }

  static Future<dynamic> post(
      String path,
      Map<String, dynamic> body,
      ) async {
    final token = await _requireToken();

    final response = await http.post(
      Uri.parse("$baseUrl$path"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );

    _handleError(response);
    return _decodeBody(response);
  }

  static Future<dynamic> put(
      String path,
      Map<String, dynamic> body,
      ) async {
    final token = await _requireToken();

    final response = await http.put(
      Uri.parse("$baseUrl$path"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );

    _handleError(response);
    return _decodeBody(response);
  }

  static Future<dynamic> patch(
      String path,
      Map<String, dynamic> body,
      ) async {
    final token = await _requireToken();

    final response = await http.patch(
      Uri.parse("$baseUrl$path"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );

    _handleError(response);
    return _decodeBody(response);
  }

  static Future<dynamic> delete(String path) async {
    final token = await _requireToken();

    final response = await http.delete(
      Uri.parse("$baseUrl$path"),
      headers: {"Authorization": "Bearer $token"},
    );

    _handleError(response);
    return _decodeBody(response);
  }

  // =========================
  // Project-specific helpers
  // =========================
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required String role, // asset_incharge | lab_technician | lab_admin | asset_user
  }) async {
    final data = await postPublic("/auth/login", {
      "email": email,
      "password": password,
      "role": role,
    });

    if (data is Map<String, dynamic> && data["token"] != null) {
      await saveToken(data["token"]);
    }

    return Map<String, dynamic>.from(data);
  }

  static Future<Map<String, dynamic>> signup(Map<String, dynamic> body) async {
    final data = await postPublic("/auth/signup", body);

    // Some signups return token immediately (except pending approval cases)
    if (data is Map<String, dynamic> && data["token"] != null) {
      await saveToken(data["token"]);
    }

    return Map<String, dynamic>.from(data);
  }

  static Future<Map<String, dynamic>> me() async {
    final data = await get("/auth/me");
    return Map<String, dynamic>.from(data);
  }

  // =========================
  // Internal helpers
  // =========================
  static dynamic _decodeBody(http.Response response) {
    if (response.body.isEmpty) return {};
    try {
      return jsonDecode(response.body);
    } catch (_) {
      return {"raw": response.body};
    }
  }

  static void _handleError(http.Response response) {
    if (response.statusCode >= 400) {
      try {
        final body = jsonDecode(response.body);
        throw Exception(
          body["error"] ??
              body["message"] ??
              body["details"] ??
              "Request failed (${response.statusCode})",
        );
      } catch (_) {
        throw Exception("Request failed (${response.statusCode}): ${response.body}");
      }
    }
  }
}