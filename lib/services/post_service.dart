import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:fe_mobile/config/api_config.dart';
import 'package:fe_mobile/model/post_model.dart';
import 'auth_services.dart';

/// Service untuk endpoint /posts & /comments & /likes
class PostService {
  // ─── GET /posts ───────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getPosts({
    String? type,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final headers = await AuthService.authHeaders();
      final params = <String, String>{
        'page': '$page',
        'limit': '$limit',
        if (type != null) 'type': type,
      };
      final uri = Uri.parse('${ApiConfig.baseUrl}/posts')
          .replace(queryParameters: params);
      final res = await http.get(uri, headers: headers);

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final data = body['data'];
        final rows = (data['data'] as List)
        .map((e) => PostModel.fromJson(e))
            .toList();
        return {
          'success': true,
          'data': rows,
          'total': data['total'],
          'page': data['page'],
        };
      }
    } catch (e) {
      print("error $e");
    }
    return {'success': false, 'data': <PostModel>[], 'total': 0};
  }

  static Future<Map<String, dynamic>> createPost({
    required String type,
    String? content,
    File? imageFile,
  }) async {
    try {
      final token = await AuthService.getToken();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/posts'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['type'] = type;
      if (content != null) request.fields['content'] = content;
      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', imageFile.path),
        );
      }
      final streamed = await request.send();
      final res = await http.Response.fromStream(streamed);

      if (res.statusCode == 201) {
        final body = jsonDecode(res.body);
        return {
          'success': true,
          'data': PostModel.fromJson(body['data']),
        };
      } else {
        final body = jsonDecode(res.body);
        return {'success': false, 'message': body['message'] ?? 'Gagal membuat post'};
      }
    } catch (e) {
      print("error $e");
      return {'success': false, 'message': 'Gagal: $e'};
    }
  }

  // ─── DELETE /posts/:id ────────────────────────────────────────────────────
  static Future<bool> deletePost(int id) async {
    try {
      final headers = await AuthService.authHeaders();
      final res = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/posts/$id'),
        headers: headers,
      );
      return res.statusCode == 200;
    } catch (e) {
      print("error $e");
      return false;
    }
  }

  // ─── GET /posts/:id ───────────────────────────────────────────────────────
  static Future<PostModel?> getPost(int id) async {
    try {
      final headers = await AuthService.authHeaders();
      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/posts/$id'),
        headers: headers,
      );
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        return PostModel.fromJson(body['data']);
      }
    } catch (e) {
      // ignore
    }
    return null;
  }

  // ─── GET /comments?post_id= ───────────────────────────────────────────────
  static Future<List<CommentModel>> getComments(int postId) async {
    try {
      final headers = await AuthService.authHeaders();
      final uri = Uri.parse('${ApiConfig.baseUrl}/comments')
          .replace(queryParameters: {'post_id': '$postId', 'limit': '50'});
      final res = await http.get(uri, headers: headers);

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        return (body['data']['data'] as List)
            .map((e) => CommentModel.fromJson(e))
            .toList();
      }
    } catch (e) {
      // ignore
    }
    return [];
  }

  static Future<bool> createComment(int postId, String content) async {
    try {
      final headers = await AuthService.authHeaders();
      final res = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/comments'),
        headers: headers,
        body: jsonEncode({'post_id': postId, 'content': content}),
      );
      return res.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> toggleLike(int postId) async {
    try {
      final headers = await AuthService.authHeaders();
      final res = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/likes'),
        headers: headers,
        body: jsonEncode({'post_id': postId}),
      );
      return res.statusCode == 200 || res.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}
