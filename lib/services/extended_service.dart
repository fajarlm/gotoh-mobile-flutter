import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fe_mobile/config/api_config.dart';
import 'auth_services.dart';

class WorkoutService {
  static Future<List<Map<String, dynamic>>> getWorkouts() async {
    try {
      final headers = await AuthService.authHeaders();
      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/workouts'),
        headers: headers,
      );
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        return List<Map<String, dynamic>>.from(body['data'] ?? []);
      }
    } catch (_) {}
    return [];
  }

  static Future<Map<String, dynamic>?> getSummary() async {
    try {
      final headers = await AuthService.authHeaders();
      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/workouts/summary'),
        headers: headers,
      );
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        return Map<String, dynamic>.from(body['data'] ?? {});
      }
    } catch (_) {}
    return null;
  }

  static Future<bool> createWorkout({
    required String title,
    String category = 'cardio',
    int durationMinutes = 30,
  }) async {
    try {
      final headers = await AuthService.authHeaders();
      final res = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/workouts'),
        headers: headers,
        body: jsonEncode({
          'title': title,
          'category': category,
          'duration_minutes': durationMinutes,
        }),
      );
      return res.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> deleteWorkout(int id) async {
    try {
      final headers = await AuthService.authHeaders();
      final res = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/workouts/$id'),
        headers: headers,
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}

class ChallengeService {
  static Future<List<Map<String, dynamic>>> getChallenges() async {
    try {
      final headers = await AuthService.authHeaders();
      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/challenges'),
        headers: headers,
      );
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        return List<Map<String, dynamic>>.from(body['data'] ?? []);
      }
    } catch (_) {}
    return [];
  }

  static Future<bool> createChallenge({
    required String title,
    String description = '',
    int targetDays = 7,
  }) async {
    try {
      final headers = await AuthService.authHeaders();
      final res = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/challenges'),
        headers: headers,
        body: jsonEncode({
          'title': title,
          'description': description,
          'target_days': targetDays,
        }),
      );
      return res.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> joinChallenge(int id) async {
    try {
      final headers = await AuthService.authHeaders();
      final res = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/challenges/$id/join'),
        headers: headers,
      );
      return res.statusCode == 200 || res.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  static Future<Map<String, dynamic>> checkinChallenge(int id) async {
    try {
      final headers = await AuthService.authHeaders();
      final res = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/challenges/$id/checkin'),
        headers: headers,
      );
      final body = jsonDecode(res.body);
      return {
        'success': res.statusCode == 200,
        'message': body['message'] ?? '',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}

class ArticleService {
  static Future<List<Map<String, dynamic>>> getArticles({String? category}) async {
    try {
      final headers = await AuthService.authHeaders();
      final uri = Uri.parse('${ApiConfig.baseUrl}/articles').replace(
        queryParameters: (category != null && category != 'all')
            ? {'category': category}
            : null,
      );
      final res = await http.get(uri, headers: headers);
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        return List<Map<String, dynamic>>.from(body['data'] ?? []);
      }
    } catch (_) {}
    return [];
  }
}

class ReportService {
  static Future<bool> createReport({
    required int postId,
    required String reason,
    String? details,
  }) async {
    try {
      final headers = await AuthService.authHeaders();
      final res = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/reports'),
        headers: headers,
        body: jsonEncode({
          'post_id': postId,
          'reason': reason,
          if (details != null && details.isNotEmpty) 'details': details,
        }),
      );
      return res.statusCode == 201;
    } catch (_) {
      return false;
    }
  }
}
