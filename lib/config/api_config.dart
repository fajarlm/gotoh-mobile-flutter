import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3001';
    } else {
      return 'http://15.15.5.11:3001';
    }
  }

  // Endpoint uploads untuk gambar
  static String get uploadsUrl => '$baseUrl/uploads';

  // Helper: buat URL gambar lengkap dari filename
  static String imageUrl(String? filename) {
    if (filename == null || filename.isEmpty) return '';
    if (filename.startsWith('http')) return filename;
    return '$uploadsUrl/$filename';
  }
}
