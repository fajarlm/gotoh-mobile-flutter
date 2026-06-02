import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:fe_mobile/config/api_config.dart';
import 'package:fe_mobile/model/community_model.dart';
import 'auth_services.dart';

/// Service untuk endpoint /communities & /community-members & /chat-messages
class CommunityService {
  static Future<Map<String, dynamic>> getCommunities({
    String? name,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final headers = await AuthService.authHeaders();
      final params = <String, String>{
        'page': '$page',
        'limit': '$limit',
        if (name != null && name.isNotEmpty) 'name': name,
      };
      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/communities',
      ).replace(queryParameters: params);
      final res = await http.get(uri, headers: headers);

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final data = body['data'];
        final rows = (data['data'] as List)
            .map((e) => CommunityModel.fromJson(e))
            .toList();
        return {'success': true, 'data': rows, 'total': data['total']};
      }
    } catch (e) {
      print("error $e");
    }
    return {'success': false, 'data': <CommunityModel>[], 'total': 0};
  }

  static Future<CommunityModel?> getCommunity(int id) async {
    try {
      final headers = await AuthService.authHeaders();
      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/communities/$id'),
        headers: headers,
      );
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        return CommunityModel.fromJson(body['data']);
      }
    } catch (e) {
      print("error $e");

    }
    return null;
  }

  static Future<Map<String, dynamic>> createCommunity({
    required String name,
    required String description,
    String? location,
    File? coverFile,
  }) async {
    try {
      final token = await AuthService.getToken();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/communities'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['name'] = name;
      request.fields['description'] = description;
      if (location != null) request.fields['location'] = location;
      if (coverFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('cover', coverFile.path),
        );
      }
      final streamed = await request.send();
      final res = await http.Response.fromStream(streamed);

      if (res.statusCode == 201) {
        final body = jsonDecode(res.body);
        return {'success': true, 'data': CommunityModel.fromJson(body['data'])};
      } else {
        final body = jsonDecode(res.body);
        return {'success': false, 'message': body['message'] ?? 'Gagal'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Gagal: $e'};
    }
  }

  static Future<bool> joinCommunity(int id) async {
    try {
      final headers = await AuthService.authHeaders();
      final res = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/communities/$id/join'),
        headers: headers,
      );
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> leaveCommunity(int id) async {
    try {
      final headers = await AuthService.authHeaders();
      final res = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/communities/$id/leave'),
        headers: headers,
      );
      return res.statusCode == 204 || res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<List<ChatMessageModel>> getChatMessages(int communityId) async {
    try {
      final headers = await AuthService.authHeaders();
      final uri = Uri.parse('${ApiConfig.baseUrl}/chat-messages/$communityId');
      final res = await http.get(uri, headers: headers);
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final dataList = body['data'];
        if (dataList is List) {
          return dataList.map((e) => ChatMessageModel.fromJson(e)).toList();
        }
        if (dataList is Map && dataList['data'] is List) {
          return (dataList['data'] as List)
              .map((e) => ChatMessageModel.fromJson(e))
              .toList();
        }
      }
    } catch (e) {
      print("error $e");
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>> getCommunityMembers(int communityId) async {
    try {
      final headers = await AuthService.authHeaders();
      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/community-members/$communityId'),
        headers: headers,
      );
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final list = body['data']['data'] as List;
        return list.map((e) => e as Map<String, dynamic>).toList();
      }
    } catch (e) {
      print("error getCommunityMembers $e");
    }
    return [];
  }

  static Future<bool> deleteCommunity(int id) async {
    try {
      final headers = await AuthService.authHeaders();
      final res = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/communities/$id'),
        headers: headers,
      );
      return res.statusCode == 200 || res.statusCode == 204;
    } catch (e) {
      return false;
    }
  }
}
