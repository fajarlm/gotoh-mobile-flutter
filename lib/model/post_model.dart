import 'package:fe_mobile/config/api_config.dart';
import 'user_model.dart';

/// Model Post sesuai response BE (tabel posts)
class PostModel {
  final int id;
  final int userId;
  final String type; // 'public' | 'private'
  final String? content;
  final String? image;
  final int likeCount;
  final int commentCount;
  final bool isLiked;
  final UserModel? user;
  final DateTime? createdAt;

  const PostModel({
    required this.id,
    required this.userId,
    required this.type,
    this.content,
    this.image,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
    this.user,
    this.createdAt,
  });

  String get imageUrl => ApiConfig.imageUrl(image);

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      userId: json['user_id'] is int
          ? json['user_id']
          : int.tryParse(json['user_id'].toString()) ?? 0,
      type: json['type'] ?? 'public',
      content: json['content'],
      image: json['image'],
      likeCount: json['like_count'] is int
          ? json['like_count']
          : int.tryParse(json['like_count']?.toString() ?? '0') ?? 0,
      commentCount: json['comment_count'] is int
          ? json['comment_count']
          : int.tryParse(json['comment_count']?.toString() ?? '0') ?? 0,
      isLiked: json['is_liked'] == true,
      user: json['User'] != null ? UserModel.fromJson(json['User']) : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }

  PostModel copyWith({
    int? likeCount,
    int? commentCount,
    bool? isLiked,
  }) {
    return PostModel(
      id: id,
      userId: userId,
      type: type,
      content: content,
      image: image,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isLiked: isLiked ?? this.isLiked,
      user: user,
      createdAt: createdAt,
    );
  }
}

/// Model Comment sesuai BE (tabel comments)
class CommentModel {
  final int id;
  final int postId;
  final int userId;
  final String content;
  final UserModel? user;
  final DateTime? createdAt;

  const CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    this.user,
    this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      postId: json['post_id'] is int
          ? json['post_id']
          : int.tryParse(json['post_id'].toString()) ?? 0,
      userId: json['user_id'] is int
          ? json['user_id']
          : int.tryParse(json['user_id'].toString()) ?? 0,
      content: json['content'] ?? '',
      user: json['User'] != null ? UserModel.fromJson(json['User']) : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }
}
