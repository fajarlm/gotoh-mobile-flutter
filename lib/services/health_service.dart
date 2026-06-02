import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fe_mobile/config/api_config.dart';
import 'package:fe_mobile/model/health_model.dart';
import 'auth_services.dart';

/// Service untuk endpoint /medical-checkup & /exercise-recommendations
class HealthService {
  // ─── POST /medical-checkup ────────────────────────────────────────────────
  static Future<Map<String, dynamic>> createCheckup({
    String? date,
    String? bloodPressure,
    int? heartRate,
    double? bloodSugar,
    double? cholesterol,
    double? weight,
    double? height,
  }) async {
    try {
      final headers = await AuthService.authHeaders();
      final body = <String, dynamic>{
        if (date != null) 'date': date,
        if (bloodPressure != null) 'blood_pressure': bloodPressure,
        if (heartRate != null) 'heart_rate': heartRate,
        if (bloodSugar != null) 'blood_sugar': bloodSugar,
        if (cholesterol != null) 'cholesterol': cholesterol,
        if (weight != null) 'weight': weight,
        if (height != null) 'height': height,
      };
      final res = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/medical-checkup'),
        headers: headers,
        body: jsonEncode(body),
      );
      if (res.statusCode == 201) {
        final resBody = jsonDecode(res.body);
        return {
          'success': true,
          'data': MedicalCheckupModel.fromJson(resBody['data']),
        };
      } else {
        final resBody = jsonDecode(res.body);
        return {'success': false, 'message': resBody['message'] ?? 'Gagal'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Gagal: $e'};
    }
  }

  // ─── GET /medical-checkup ─────────────────────────────────────────────────
  static Future<List<MedicalCheckupModel>> getCheckups({int? userId}) async {
    try {
      final headers = await AuthService.authHeaders();
      final params = <String, String>{
        if (userId != null) 'user_id': '$userId',
      };
      final uri = Uri.parse('${ApiConfig.baseUrl}/medical-checkup')
          .replace(queryParameters: params.isEmpty ? null : params);
      final res = await http.get(uri, headers: headers);
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        return (body['data'] as List)
            .map((e) => MedicalCheckupModel.fromJson(e))
            .toList();
      }
    } catch (e) {
      // ignore
    }
    return [];
  }

  // ─── DELETE /medical-checkup/:id ─────────────────────────────────────────
  static Future<bool> deleteCheckup(int id) async {
    try {
      final headers = await AuthService.authHeaders();
      final res = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/medical-checkup/$id'),
        headers: headers,
      );
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ─── POST /exercise-recommendations ──────────────────────────────────────
  static Future<Map<String, dynamic>> createRecommendation({
    required String bmiCategory,
  }) async {
    try {
      final headers = await AuthService.authHeaders();
      final res = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/exercise-recommendations'),
        headers: headers,
        body: jsonEncode({'bmi_category': bmiCategory}),
      );
      if (res.statusCode == 201) {
        final body = jsonDecode(res.body);
        return {
          'success': true,
          'data': ExerciseRecommendationModel.fromJson(body['data']),
        };
      }
    } catch (e) {
      // ignore
    }
    return {'success': false};
  }

  // ─── GET /exercise-recommendations ───────────────────────────────────────
  static Future<List<ExerciseRecommendationModel>> getRecommendations({
    String? bmiCategory,
  }) async {
    try {
      final headers = await AuthService.authHeaders();
      final params = <String, String>{
        if (bmiCategory != null) 'bmi_category': bmiCategory,
      };
      final uri = Uri.parse('${ApiConfig.baseUrl}/exercise-recommendations')
          .replace(queryParameters: params.isEmpty ? null : params);
      final res = await http.get(uri, headers: headers);
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        return (body['data'] as List)
            .map((e) => ExerciseRecommendationModel.fromJson(e))
            .toList();
      }
    } catch (e) {
      // ignore
    }
    return [];
  }
}
