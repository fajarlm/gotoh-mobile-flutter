import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fe_mobile/config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final url = '${ApiConfig.baseUrl}/login';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final token = body['data']['token'] as String;
        final userData = body['data']['data'] as Map<String, dynamic>;

        // Decode JWT payload to extract user_role (set in BE as user_role)
        final jwtPayload = _decodeJwt(token);
        final role = (jwtPayload['user_role'] ?? 'user').toString();

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setInt('user_id', userData['id'] ?? 0);
        await prefs.setString('username', userData['username'] ?? '');
        await prefs.setString('email', userData['email'] ?? '');
        await prefs.setString('role', role);

        return {'success': true};
      } else {
        final msg = body['data'] is String
            ? body['data']
            : body['message'] ?? 'Login gagal';
        return {'success': false, 'message': msg};
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi ke server gagal: $e'};
    }
  }

  static Future<Map<String, dynamic>> register(
      String username, String email, String password) async {
    final url = '${ApiConfig.baseUrl}/register';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
            {'username': username, 'email': email, 'password': password}),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {'success': true};
      } else {
        final msg = body['data'] is String
            ? body['data']
            : body['message'] ?? 'Registrasi gagal';
        return {'success': false, 'message': msg};
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi ke server gagal: $e'};
    }
  }

  // ─── Logout ──────────────────────────────────────────────────────────────
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ─── Helper: ambil token ─────────────────────────────────────────────────
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // ─── Helper: cek apakah sudah login ──────────────────────────────────────
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ─── Helper: ambil role user ─────────────────────────────────────────────
  static Future<String> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role') ?? 'user';
  }

  // ─── Helper: header Authorization ────────────────────────────────────────
  static Future<Map<String, String>> authHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ─── Decode JWT payload (no signature verify – client-side only) ──────────
  static Map<String, dynamic> _decodeJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return {};
      // Base64Url padding
      String payload = parts[1];
      switch (payload.length % 4) {
        case 2:
          payload += '==';
          break;
        case 3:
          payload += '=';
          break;
      }
      final decoded = utf8.decode(base64Url.decode(payload));
      return jsonDecode(decoded) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }
}
