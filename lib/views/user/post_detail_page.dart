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
        backgroundColor: Color(0xFFFAFDF9),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF0D631B)),
        ),
      );
    }
    // Post tidak ditemukan
    if (_post == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFFAFDF9),
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0D631B), Color(0xFF2E7D32)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          elevation: 0,
          leading: const BackButton(color: Colors.white),
        ),
        body: const Center(
          child: Text(
            'Post tidak ditemukan',
            style: TextStyle(
              color: Color(0xFF6B8B72),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    final post = _post!;
    final user = post.user;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFDF9),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0D631B), Color(0xFF2E7D32)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'Postingan',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
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
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFE2EFE0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header penulis
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: const Color(0xFFE8F5E9),
                              backgroundImage:
                                  (user?.avatarUrl.isNotEmpty == true)
                                  ? NetworkImage(user!.avatarUrl)
                                        as ImageProvider
                                  : null,
                              child: (user == null || user.avatarUrl.isEmpty)
                                  ? Text(
                                      user?.initials ?? '?',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0D631B),
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.username ?? 'Unknown',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1B3C21),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  post.createdAt != null
                                      ? _formatDate(post.createdAt!)
                                      : '',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF6B8B72),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Konten teks
                        if (post.content != null && post.content!.isNotEmpty)
                          Text(
                            post.content!,
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.5,
                              color: Color(0xFF1B3C21),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        // Gambar post
                        if (post.image != null && post.image!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              post.imageUrl,
                              width: double.infinity,
                              height: 240,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                height: 240,
                                color: const Color(0xFFE2EFE0),
                                child: const Icon(
                                  Icons.image_not_supported,
                                  size: 40,
                                  color: Color(0xFF6B8B72),
                                ),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        const Divider(color: Color(0xFFE2EFE0)),
                        const SizedBox(height: 8),
                        // Aksi like & komentar
                        Row(
                          children: [
                            GestureDetector(
                              onTap: _onLike,
                              child: Row(
                                children: [
                                  Icon(
                                    post.isLiked
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                    size: 22,
                                    color: post.isLiked
                                        ? const Color(0xFFBA1A1A)
                                        : const Color(0xFF6B8B72),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${post.likeCount}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF6B8B72),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 24),
                            const Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 22,
                              color: Color(0xFF6B8B72),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${_comments.length}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6B8B72),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // ── Section Komentar ────────────────────────────────────
                  const Text(
                    'Komentar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1B3C21),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._comments.map(_buildCommentCard),
                  if (_comments.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'Belum ada komentar',
                          style: TextStyle(
                            color: Color(0xFF6B8B72),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // ── Input komentar ──────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: const Border(top: BorderSide(color: Color(0xFFE2EFE0))),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1B3C21),
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Tulis komentar...',
                      hintStyle: const TextStyle(
                        color: Color(0xFF8FA89A),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF4F8F4),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: Color(0xFFE2EFE0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: Color(0xFFE2EFE0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: Color(0xFF0D631B)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _submitComment,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D631B),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0D631B).withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2EFE0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFE8F5E9),
            backgroundImage: (c.user?.avatarUrl.isNotEmpty == true)
                ? NetworkImage(c.user!.avatarUrl) as ImageProvider
                : null,
            child: (c.user == null || c.user!.avatarUrl.isEmpty)
                ? Text(
                    c.user?.initials ?? '?',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D631B),
                    ),
                  )
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
                    Text(
                      c.user?.username ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1B3C21),
                      ),
                    ),
                    Text(
                      c.createdAt != null ? _formatDate(c.createdAt!) : '',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6B8B72),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  c.content,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B8B72),
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
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
