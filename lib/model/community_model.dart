import 'package:fe_mobile/config/api_config.dart';
import 'user_model.dart';

/// Model Community sesuai BE (tabel communities)
class CommunityModel {
  final int id;
  final String name;
  final String description;
  final String? coverImage;
  final String? location;
  final int createdBy;
  final int memberCount;
  final bool isMember;
  final DateTime? createdAt;

  const CommunityModel({
    required this.id,
    required this.name,
    required this.description,
    this.coverImage,
    this.location,
    required this.createdBy,
    this.memberCount = 0,
    this.isMember = false,
    this.createdAt,
  });

  String get coverImageUrl => ApiConfig.imageUrl(coverImage);

  factory CommunityModel.fromJson(Map<String, dynamic> json) {
    return CommunityModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      coverImage: json['cover_image'],
      location: json['location'],
      createdBy: json['created_by'] is int
          ? json['created_by']
          : int.tryParse(json['created_by'].toString()) ?? 0,
      memberCount: json['member_count'] is int
          ? json['member_count']
          : int.tryParse(json['member_count']?.toString() ?? '0') ?? 0,
      isMember: json['is_member'] == true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }

  CommunityModel copyWith({bool? isMember, int? memberCount}) {
    return CommunityModel(
      id: id,
      name: name,
      description: description,
      coverImage: coverImage,
      location: location,
      createdBy: createdBy,
      memberCount: memberCount ?? this.memberCount,
      isMember: isMember ?? this.isMember,
      createdAt: createdAt,
    );
  }
}

/// Model ChatMessage sesuai BE (tabel chat_messages)
class ChatMessageModel {
  final int id;
  final int communityId;
  final int userId;
  final String message;
  final UserModel? user;
  final DateTime? createdAt;

  const ChatMessageModel({
    required this.id,
    required this.communityId,
    required this.userId,
    required this.message,
    this.user,
    this.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      communityId: json['community_id'] is int
          ? json['community_id']
          : int.tryParse(json['community_id'].toString()) ?? 0,
      userId: json['user_id'] is int
          ? json['user_id']
          : int.tryParse(json['user_id'].toString()) ?? 0,
      message: json['message'] ?? '',
      user: json['User'] != null ? UserModel.fromJson(json['User']) : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }
}
