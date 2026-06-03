import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fe_mobile/config/api_config.dart';
import 'package:fe_mobile/model/post_model.dart';
import 'package:fe_mobile/services/post_service.dart';
import 'package:fe_mobile/views/user/post_create_page.dart';
import 'package:fe_mobile/views/user/post_detail_page.dart';
import 'package:fe_mobile/views/user/profile_page.dart';
import 'package:fe_mobile/views/user/user_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  String _selectedFilter = 'Semua';
  String _searchQuery = '';
  String _username = '';
  String? _avatarUrl;
  int _currentUserId = 0;

  List<PostModel> _posts = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  static const int _perPage = 10;

  final ScrollController _scrollController = ScrollController();
  late AnimationController _fabAnim;

  static const _primaryGreen = Color(0xFF0D631B);
  static const _lightGreen = Color(0xFFC9E7CA);
  static const _bgColor = Color(0xFFF4F8F0);
  static const _cardColor = Colors.white;
  static const _textDark = Color(0xFF1A2218);
  static const _textMid = Color(0xFF4E6952);
  static const _textLight = Color(0xFF8FA89A);

  final List<String> _filterOptions = ['Semua', 'Publik', 'Terpopuler'];

  @override
  void initState() {
    super.initState();
    _fabAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _fabAnim.forward();
    _loadUserInfo();
    _fetchPosts(refresh: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fabAnim.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading && _hasMore) _fetchPosts();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _username = prefs.getString('username') ?? 'User';
      _currentUserId = prefs.getInt('user_id') ?? 0;
      final avatar = prefs.getString('avatar');
      _avatarUrl = (avatar != null && avatar.isNotEmpty) ? ApiConfig.imageUrl(avatar) : null;
    });
  }

  Future<void> _fetchPosts({bool refresh = false}) async {
    if (_isLoading) return;
    if (refresh) { _currentPage = 1; _hasMore = true; }
    setState(() => _isLoading = true);

    String? typeFilter;
    if (_selectedFilter == 'Publik') typeFilter = 'public';

    final result = await PostService.getPosts(type: typeFilter, page: _currentPage, limit: _perPage);
    if (!mounted) return;
    if (result['success'] == true) {
      final newPosts = result['data'] as List<PostModel>;
      setState(() {
        if (refresh) _posts = newPosts; else _posts.addAll(newPosts);
        _hasMore = newPosts.length == _perPage;
        _currentPage++;
      });
    }
    setState(() => _isLoading = false);
  }

  List<PostModel> get _filteredPosts {
    if (_searchQuery.isEmpty) return _posts;
    final q = _searchQuery.toLowerCase();
    return _posts.where((p) {
      return (p.user?.username.toLowerCase() ?? '').contains(q) ||
          (p.content?.toLowerCase() ?? '').contains(q);
    }).toList();
  }

  Future<void> _onLikePost(int postId) async {
    setState(() {
      final idx = _posts.indexWhere((p) => p.id == postId);
      if (idx != -1) {
        final p = _posts[idx];
        _posts[idx] = p.copyWith(isLiked: !p.isLiked, likeCount: p.isLiked ? p.likeCount - 1 : p.likeCount + 1);
      }
    });
    await PostService.toggleLike(postId);
  }

  Future<void> _onDeletePost(PostModel post) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Postingan'),
        content: const Text('Apakah kamu yakin ingin menghapus postingan ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFBA1A1A)),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    final ok = await PostService.deletePost(post.id);
    if (!mounted) return;
    if (ok) {
      setState(() => _posts.removeWhere((p) => p.id == post.id));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Postingan berhasil dihapus'), backgroundColor: Color(0xFF0D631B)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menghapus postingan'), backgroundColor: Color(0xFFBA1A1A)),
      );
    }
  }

  void _showEditPostDialog(PostModel post) {
    showDialog(
      context: context,
      builder: (ctx) => EditPostDialog(
        post: post,
        onSaved: () {
          _fetchPosts(refresh: true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Postingan berhasil diperbarui'), backgroundColor: Color(0xFF0D631B)),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _fetchPosts(refresh: true),
          color: _primaryGreen,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              _buildAppBar(),
              _buildGreeting(),
              _buildSearchAndFilter(),
              _buildPostsList(),
            ],
          ),
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: CurvedAnimation(parent: _fabAnim, curve: Curves.elasticOut),
        child: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const PostCreatePage()));
            if (result == true) _fetchPosts(refresh: true);
          },
          backgroundColor: _primaryGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 6,
          child: const Icon(Icons.edit_rounded, size: 26),
        ),
      ),
    );
  }

  // ── App Bar ──────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      floating: true,
      backgroundColor: _bgColor,
      elevation: 0,
      toolbarHeight: 64,
      titleSpacing: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          color: _bgColor,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: _primaryGreen, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.health_and_safety_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 10),
              const Text('GOTOH', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5, color: _primaryGreen)),
            ]),
            Row(children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none_rounded, color: _textMid, size: 26),
                padding: EdgeInsets.zero,
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () {
                  final userShell = UserPage.of(context);
                  if (userShell != null) {
                    userShell.setTab(3);
                  } else {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
                  }
                },
                child: CircleAvatar(
                  radius: 19,
                  backgroundColor: _lightGreen,
                  backgroundImage: _avatarUrl != null ? NetworkImage(_avatarUrl!) : null,
                  child: _avatarUrl == null
                      ? Text(_username.isNotEmpty ? _username[0].toUpperCase() : '?',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _textMid))
                      : null,
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  // ── Greeting ─────────────────────────────────────────────────────────────
  Widget _buildGreeting() {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Selamat Pagi' : hour < 17 ? 'Selamat Siang' : 'Selamat Malam';
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF0D631B), Color(0xFF1B8C2A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: _primaryGreen.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$greeting,', style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(_username, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.3)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                    child: const Text('Apa kabar hari ini?', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
            ),
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
              child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 32),
            ),
          ],
        ),
      ),
    );
  }

  // ── Search & Filter ───────────────────────────────────────────────────────
  Widget _buildSearchAndFilter() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
        child: Column(
          children: [
            // Search bar
            Container(
              decoration: BoxDecoration(
                color: _cardColor,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3))],
              ),
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Cari postingan, tips kesehatan...',
                  hintStyle: const TextStyle(color: _textLight, fontSize: 13),
                  prefixIcon: const Icon(Icons.search_rounded, size: 22, color: _textLight),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(onPressed: () => setState(() => _searchQuery = ''), icon: const Icon(Icons.close_rounded, size: 20, color: _textLight))
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Filter chips
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _filterOptions.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (ctx, i) {
                  final f = _filterOptions[i];
                  final sel = _selectedFilter == f;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedFilter = f);
                      _fetchPosts(refresh: true);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel ? _primaryGreen : _cardColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6, offset: const Offset(0, 2))],
                      ),
                      child: Text(f,
                          style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600,
                            color: sel ? Colors.white : _textMid,
                          )),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildPostsList() {
    if (_isLoading && _posts.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator(color: _primaryGreen)),
      );
    }
    if (!_isLoading && _filteredPosts.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(color: _lightGreen, borderRadius: BorderRadius.circular(20)),
              child: const Icon(Icons.article_outlined, size: 40, color: _textMid),
            ),
            const SizedBox(height: 16),
            const Text('Belum ada postingan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _textMid)),
            const SizedBox(height: 6),
            const Text('Jadilah yang pertama berbagi!', style: TextStyle(fontSize: 13, color: _textLight)),
          ]),
        ),
      );
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (ctx, i) {
          if (i == _filteredPosts.length) {
            return _isLoading
                ? const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator(color: _primaryGreen)))
                : const SizedBox(height: 100);
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: _buildPostCard(_filteredPosts[i]),
          );
        },
        childCount: _filteredPosts.length + 1,
      ),
    );
  }

  // ── Post Card ─────────────────────────────────────────────────────────────
  Widget _buildPostCard(PostModel post) {
    final user = post.user;
    final avatarUrl = user?.avatarUrl ?? '';
    final isPublic = post.type == 'public';

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PostDetailPage(postId: post.id))),
      child: Container(
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 14, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Card Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  // Avatar with green ring if public
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isPublic
                          ? const LinearGradient(colors: [Color(0xFF0D631B), Color(0xFF4CAF50)])
                          : null,
                      color: isPublic ? null : const Color(0xFFE0E0E0),
                    ),
                    child: CircleAvatar(
                      radius: 21,
                      backgroundColor: _lightGreen,
                      backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                      child: avatarUrl.isEmpty
                          ? Text(user?.initials ?? '?', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _textMid))
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.username ?? 'Unknown',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _textDark),
                        ),
                        const SizedBox(height: 3),
                        Row(children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isPublic ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(children: [
                              Icon(isPublic ? Icons.public_rounded : Icons.lock_outline_rounded,
                                  size: 10, color: isPublic ? _primaryGreen : Colors.orange.shade700),
                              const SizedBox(width: 3),
                              Text(isPublic ? 'Publik' : 'Privat',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                                      color: isPublic ? _primaryGreen : Colors.orange.shade700)),
                            ]),
                          ),
                          if (post.createdAt != null) ...[
                            const SizedBox(width: 6),
                            Text('· ${_formatDate(post.createdAt!)}',
                                style: const TextStyle(fontSize: 11, color: _textLight)),
                          ],
                        ]),
                      ],
                    ),
                  ),
                  if (post.user?.id == _currentUserId)
                    PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.more_horiz_rounded, color: _textLight, size: 22),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      onSelected: (val) {
                        if (val == 'edit') _showEditPostDialog(post);
                        if (val == 'delete') _onDeletePost(post);
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(children: [
                            Icon(Icons.edit_outlined, size: 18, color: Color(0xFF0D631B)),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ]),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(children: [
                            Icon(Icons.delete_outline, size: 18, color: Color(0xFFBA1A1A)),
                            SizedBox(width: 8),
                            Text('Hapus', style: TextStyle(color: Color(0xFFBA1A1A))),
                          ]),
                        ),
                      ],
                    )
                  else
                    const SizedBox(width: 32),
                ],
              ),
            ),

            // ── Content ──
            if (post.content != null && post.content!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Text(
                  post.content!,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, height: 1.6, color: _textDark),
                ),
              ),

            // ── Image ──
            if (post.image != null && post.image!.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(bottom: Radius.zero),
                child: Image.network(
                  post.imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 200,
                    color: const Color(0xFFF0F0F0),
                    child: const Icon(Icons.image_not_supported_rounded, size: 40, color: _textLight),
                  ),
                ),
              ),

            // ── Action Bar ──
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  _actionBtn(
                    icon: post.isLiked ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                    label: '${post.likeCount}',
                    color: post.isLiked ? const Color(0xFFE53935) : _textLight,
                    onTap: () => _onLikePost(post.id),
                  ),
                  const SizedBox(width: 4),
                  _actionBtn(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: '${post.commentCount}',
                    color: _textLight,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PostDetailPage(postId: post.id))),
                  ),
                  const Spacer(),
                  _actionBtn(icon: Icons.share_outlined, label: 'Bagikan', color: _textLight, onTap: () {}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionBtn({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
        ]),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}j';
    if (diff.inDays < 7) return '${diff.inDays}h';
    return '${dt.day}/${dt.month}';
  }

 } // ── Bottom Nav ────────────────────────────────────────────────────────────

class EditPostDialog extends StatefulWidget {
  final PostModel post;
  final VoidCallback onSaved;

  const EditPostDialog({super.key, required this.post, required this.onSaved});

  @override
  State<EditPostDialog> createState() => _EditPostDialogState();
}

class _EditPostDialogState extends State<EditPostDialog> {
  late TextEditingController _controller;
  File? _imageFile;
  bool _removeExistingImage = false;
  bool _isSubmitting = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.post.content ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
          _removeExistingImage = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memilih gambar: $e')),
      );
    }
  }

  void _removeImage() {
    setState(() {
      _imageFile = null;
      _removeExistingImage = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasExistingImage = widget.post.image != null && widget.post.image!.isNotEmpty;
    final showImage = (_imageFile != null) || (hasExistingImage && !_removeExistingImage);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Edit Postingan',
        style: TextStyle(color: Color(0xFF0D631B), fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Isi postingan...',
                filled: true,
                fillColor: const Color(0xFFF4F8F0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Foto Postingan',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF40493D)),
            ),
            const SizedBox(height: 8),
            if (showImage)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _imageFile != null
                        ? Image.file(
                            _imageFile!,
                            width: double.infinity,
                            height: 150,
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            widget.post.imageUrl,
                            width: double.infinity,
                            height: 150,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: 150,
                              color: const Color(0xFFF0F0F0),
                              child: const Icon(Icons.broken_image, size: 40),
                            ),
                          ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: _removeImage,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ],
              )
            else
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE0E4DA)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.add_photo_alternate_outlined, color: Color(0xFF0D631B), size: 32),
                      SizedBox(height: 4),
                      Text(
                        'Pilih Foto dari Galeri',
                        style: TextStyle(color: Color(0xFF0D631B), fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Batal', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0D631B),
            disabledBackgroundColor: Colors.grey,
          ),
          onPressed: _isSubmitting
              ? null
              : () async {
                  setState(() => _isSubmitting = true);
                  final res = await PostService.updatePost(
                    id: widget.post.id,
                    content: _controller.text.trim(),
                    imageFile: _imageFile,
                    removeImage: _removeExistingImage,
                  );
                  if (!mounted) return;
                  setState(() => _isSubmitting = false);
                  if (res['success'] == true) {
                    Navigator.pop(context);
                    widget.onSaved();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(res['message'] ?? 'Gagal memperbarui postingan'),
                        backgroundColor: const Color(0xFFBA1A1A),
                      ),
                    );
                  }
                },
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : const Text('Simpan', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}