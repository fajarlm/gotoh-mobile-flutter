import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fe_mobile/config/api_config.dart';
import 'package:fe_mobile/model/user_model.dart';
import 'auth_services.dart';

/// Service untuk endpoint /users
class UserService {
  static Future<UserModel?> getProfile() async {
    try {
      final headers = await AuthService.authHeaders();
      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/users/profile'),
        headers: headers,
      );
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        return UserModel.fromJson(body['data']);
      }
    } catch (e) {
      // ignore
      print("error $e");
    }
    return null;
  }

  // GET /users — daftar semua user (admin)
  static Future<Map<String, dynamic>> getUsers({
    String? username,
    String? email,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final headers = await AuthService.authHeaders();
      final params = <String, String>{
        'page': '$page',
        'limit': '$limit',
        if (username != null && username.isNotEmpty) 'username': username,
        if (email != null && email.isNotEmpty) 'email': email,
      };
      final uri = Uri.parse('${ApiConfig.baseUrl}/users')
          .replace(queryParameters: params);
      final res = await http.get(uri, headers: headers);

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final data = body['data'];
        final rows = (data['data'] as List)
            .map((e) => UserModel.fromJson(e))
            .toList();
        return {
          'success': true,
          'data': rows,
          'total': data['total'],
          'page': data['page'],
        };
      }
    } catch (e) {
      // ignore
    }
    return {'success': false, 'data': [], 'total': 0};
  }

  // PUT /users/profile — update profil
  static Future<Map<String, dynamic>> updateProfile({
    String? username,
    String? email,
    String? healthTarget,
    String? password,
  }) async {
    try {
      final headers = await AuthService.authHeaders();
      final body = <String, dynamic>{
        if (username != null) 'username': username,
        if (email != null) 'email': email,
        if (healthTarget != null) 'health_target': healthTarget,
        if (password != null && password.isNotEmpty) 'password': password,
      };
      final res = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/users/profile'),
        headers: headers,
        body: jsonEncode(body),
      );
      if (res.statusCode == 200) {
        final resBody = jsonDecode(res.body);
        return {
          'success': true,
          'data': UserModel.fromJson(resBody['data']),
        };
      } else {
        final resBody = jsonDecode(res.body);
        return {'success': false, 'message': resBody['message'] ?? 'Gagal update profil'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Gagal: $e'};
    }
  }

  // DELETE /users/:id — hapus user (admin)
  static Future<bool> deleteUser(int id) async {
    try {
      final headers = await AuthService.authHeaders();
      final res = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/users/profile/$id'),
        headers: headers,
      );
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
