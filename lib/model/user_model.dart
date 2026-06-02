import 'package:fe_mobile/config/api_config.dart';

class UserModel {
  final int id;
  final String username;
  final String email;
  final String? avatar;
  final String role;
  final String? healthTarget;
  final DateTime? createdAt;

  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.avatar,
    this.role = 'user',
    this.healthTarget,
    this.createdAt,
  });

  String get avatarUrl => ApiConfig.imageUrl(avatar);

  String get initials =>
      username.isNotEmpty ? username[0].toUpperCase() : '?';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      avatar: json['avatar'],
      role: json['role'] ?? 'user',
      healthTarget: json['health_target'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'email': email,
        'avatar': avatar,
      'role': role,
        'health_target': healthTarget,
      };

  UserModel copyWith({
    int? id,
    String? username,
    String? email,
    String? avatar,
    String? role,
    String? healthTarget,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
      healthTarget: healthTarget ?? this.healthTarget,
      createdAt: createdAt,
    );
  }
}
