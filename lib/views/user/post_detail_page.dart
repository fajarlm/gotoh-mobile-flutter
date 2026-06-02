import 'package:flutter/material.dart';
import 'package:fe_mobile/model/post_model.dart';
import 'package:fe_mobile/services/post_service.dart';

// Halaman detail post — menerima postId dari navigasi
class PostDetailPage extends StatefulWidget {
  final int postId;
  const PostDetailPage({super.key, required this.postId});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  PostModel? _post;
  List<CommentModel> _comments = [];
  bool _isLoading = true;
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // Muat data post dan komentar dari API
  Future<void> _loadData() async {
    final post = await PostService.getPost(widget.postId);
    final comments = await PostService.getComments(widget.postId);
    if (mounted) {
      setState(() {
        _post = post;
        _comments = comments;
        _isLoading = false;
      });
    }
  }

  // Kirim komentar baru ke BE
  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    final ok = await PostService.createComment(widget.postId, text);
    if (ok && mounted) {
      _commentController.clear();
      _loadData(); // reload komentar setelah kirim
    }
  }

  // Toggle like dengan optimistic update
  Future<void> _onLike() async {
    if (_post == null) return;
    setState(() {
      _post = _post!.copyWith(
        isLiked: !_post!.isLiked,
        likeCount: _post!.isLiked ? _post!.likeCount - 1 : _post!.likeCount + 1,
      );
    });
    await PostService.toggleLike(widget.postId);
  }

  @override
  Widget build(BuildContext context) {
    // Tampilkan loading spinner saat data belum siap
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF7FBF0),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF0D631B))),
      );
    }
    // Post tidak ditemukan
    if (_post == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF7FBF0),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF7FBF0),
          elevation: 0,
          leading: const BackButton(color: Color(0xFF0D631B)),
        ),
        body: const Center(child: Text('Post tidak ditemukan')),
      );
    }

    final post = _post!;
    final user = post.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FBF0),
      appBar: AppBar(
        backgroundColor: const Color(0xCCECFDF5),
        elevation: 1,
        leading: const BackButton(color: Color(0xFF0D631B)),
        title: const Text(
          'Postingan',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF064E3B)),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Card Post ───────────────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: const Color(0x0A000000), blurRadius: 12, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header penulis
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: const Color(0xFFEBEFE5),
                              backgroundImage: (user?.avatarUrl.isNotEmpty == true)
                                  ? NetworkImage(user!.avatarUrl) as ImageProvider
                                  : null,
                              child: (user == null || user.avatarUrl.isEmpty)
                                  ? Text(user?.initials ?? '?',
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4E6952)))
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.username ?? 'Unknown',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF181D17)),
                                ),
                                Text(
                                  post.createdAt != null ? _formatDate(post.createdAt!) : '',
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF40493D)),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Konten teks
                        if (post.content != null && post.content!.isNotEmpty)
                          Text(post.content!,
                              style: const TextStyle(fontSize: 16, height: 1.6, color: Color(0xFF181D17))),
                        // Gambar post
                        if (post.image != null && post.image!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              post.imageUrl,
                              width: double.infinity,
                              height: 240,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                height: 240,
                                color: const Color(0xFFE0E4DA),
                                child: const Icon(Icons.image_not_supported, size: 40, color: Color(0xFF9E9E9E)),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        const Divider(color: Color(0xFFE0E4DA)),
                        const SizedBox(height: 8),
                        // Aksi like & komentar
                        Row(
                          children: [
                            GestureDetector(
                              onTap: _onLike,
                              child: Row(
                                children: [
                                  Icon(
                                    post.isLiked ? Icons.favorite : Icons.favorite_border,
                                    size: 22,
                                    color: post.isLiked ? const Color(0xFFBA1A1A) : const Color(0xFF707A6C),
                                  ),
                                  const SizedBox(width: 4),
                                  Text('${post.likeCount}',
                                      style: const TextStyle(fontSize: 14, color: Color(0xFF707A6C))),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                            const Icon(Icons.chat_bubble_outline, size: 22, color: Color(0xFF707A6C)),
                            const SizedBox(width: 4),
                            Text('${_comments.length}',
                                style: const TextStyle(fontSize: 14, color: Color(0xFF707A6C))),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // ── Section Komentar ────────────────────────────────────
                  const Text('Komentar',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF181D17))),
                  const SizedBox(height: 12),
                  ..._comments.map(_buildCommentCard),
                  if (_comments.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('Belum ada komentar', style: TextStyle(color: Color(0xFF707A6C))),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // ── Input komentar ──────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Tulis komentar...',
                      filled: true,
                      fillColor: const Color(0xFFF7FBF0),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _submitComment,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(color: Color(0xFF0D631B), shape: BoxShape.circle),
                    child: const Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Card untuk setiap item komentar
  Widget _buildCommentCard(CommentModel c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: const Color(0x05000000), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFEBEFE5),
            backgroundImage: (c.user?.avatarUrl.isNotEmpty == true)
                ? NetworkImage(c.user!.avatarUrl) as ImageProvider
                : null,
            child: (c.user == null || c.user!.avatarUrl.isEmpty)
                ? Text(c.user?.initials ?? '?',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF4E6952)))
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(c.user?.username ?? 'Unknown',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF181D17))),
                    Text(
                      c.createdAt != null ? _formatDate(c.createdAt!) : '',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF40493D)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(c.content,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF40493D), height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Format tanggal menjadi waktu relatif
  String _formatDate(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m lalu';
    if (diff.inHours < 24) return '${diff.inHours}j lalu';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}