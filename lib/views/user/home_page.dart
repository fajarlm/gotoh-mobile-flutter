import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fe_mobile/config/api_config.dart';
import 'package:fe_mobile/model/post_model.dart';
import 'package:fe_mobile/services/post_service.dart';
import 'package:fe_mobile/views/user/edit_post_page.dart';
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
  static const _bgColor = Color(0xFFFAFDF9);
  static const _cardColor = Colors.white;
  static const _textDark = Color(0xFF1B3C21);
  static const _textMid = Color(0xFF5A7561);
  static const _textLight = Color(0xFF6B8B72);

  final List<String> _filterOptions = ['Semua', 'Publik', 'Terpopuler'];

  @override
  void initState() {
    super.initState();
    _fabAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
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
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMore)
      _fetchPosts();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _username = prefs.getString('username') ?? 'User';
      _currentUserId = prefs.getInt('user_id') ?? 0;
      final avatar = prefs.getString('avatar');
      _avatarUrl = (avatar != null && avatar.isNotEmpty)
          ? ApiConfig.imageUrl(avatar)
          : null;
    });
  }

  Future<void> _fetchPosts({bool refresh = false}) async {
    if (_isLoading) return;
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
    }
    setState(() => _isLoading = true);

    String? typeFilter;
    if (_selectedFilter == 'Publik') typeFilter = 'public';

    final result = await PostService.getPosts(
      type: typeFilter,
      page: _currentPage,
      limit: _perPage,
    );
    if (!mounted) return;
    if (result['success'] == true) {
      final newPosts = result['data'] as List<PostModel>;
      setState(() {
        if (refresh)
          _posts = newPosts;
        else
          _posts.addAll(newPosts);
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
        _posts[idx] = p.copyWith(
          isLiked: !p.isLiked,
          likeCount: p.isLiked ? p.likeCount - 1 : p.likeCount + 1,
        );
      }
    });
    await PostService.toggleLike(postId);
  }

  Future<void> _onDeletePost(PostModel post) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Hapus Postingan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B3C21),
          ),
        ),
        content: const Text(
          'Apakah kamu yakin ingin menghapus postingan ini?',
          style: TextStyle(
            color: Color(0xFF6B8B72),
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Batal',
              style: TextStyle(
                color: Color(0xFF6B8B72),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFBA1A1A),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text(
              'Hapus',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
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
        const SnackBar(
          content: Text('Postingan berhasil dihapus'),
          backgroundColor: Color(0xFF0D631B),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menghapus postingan'),
          backgroundColor: Color(0xFFBA1A1A),
        ),
      );
    }
  }

  Future<void> _showEditPostDialog(PostModel post) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => EditPostPage(post: post)),
    );
    if (result == true && mounted) {
      _fetchPosts(refresh: true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Postingan berhasil diperbarui'),
          backgroundColor: Color(0xFF0D631B),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PostCreatePage()),
            );
            if (result == true) _fetchPosts(refresh: true);
          },
          backgroundColor: _primaryGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
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
        decoration: const BoxDecoration(
          color: _bgColor,
          border: Border(bottom: BorderSide(color: Color(0xFFE2EFE0))),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _primaryGreen,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.health_and_safety_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'GOTOH',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    color: _primaryGreen,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                    color: _textMid,
                    size: 26,
                  ),
                  padding: EdgeInsets.zero,
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () {
                    final userShell = UserPage.of(context);
                    if (userShell != null) {
                      userShell.setTab(3);
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfilePage()),
                      );
                    }
                  },
                  child: CircleAvatar(
                    radius: 19,
                    backgroundColor: _lightGreen,
                    backgroundImage: _avatarUrl != null
                        ? NetworkImage(_avatarUrl!)
                        : null,
                    child: _avatarUrl == null
                        ? Text(
                            _username.isNotEmpty
                                ? _username[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _textMid,
                            ),
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Greeting ─────────────────────────────────────────────────────────────
  Widget _buildGreeting() {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Selamat Pagi'
        : hour < 17
        ? 'Selamat Siang'
        : 'Selamat Malam';
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0D631B), Color(0xFF1E822E), Color(0xFF38B04D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              top: -10,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$greeting,',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _username,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Text(
                          'Mulai hari sehatmu hari ini! ✨',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    color: Color(0xFF0D631B),
                    size: 28,
                  ),
                ),
              ],
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
                border: Border.all(color: const Color(0xFFE2EFE0)),
              ),
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Cari postingan, tips kesehatan...',
                  hintStyle: const TextStyle(color: _textLight, fontSize: 13),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    size: 22,
                    color: _textLight,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          onPressed: () => setState(() => _searchQuery = ''),
                          icon: const Icon(
                            Icons.close_rounded,
                            size: 20,
                            color: _textLight,
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: sel ? _primaryGreen : _cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: sel ? _primaryGreen : const Color(0xFFE2EFE0),
                        ),
                      ),
                      child: Text(
                        f,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: sel ? Colors.white : _textMid,
                        ),
                      ),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F8F4),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2EFE0)),
                ),
                child: const Icon(
                  Icons.article_outlined,
                  size: 40,
                  color: _textMid,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Belum ada postingan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _textMid,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Jadilah yang pertama berbagi!',
                style: TextStyle(fontSize: 13, color: _textLight),
              ),
            ],
          ),
        ),
      );
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate((ctx, i) {
        if (i == _filteredPosts.length) {
          return _isLoading
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: CircularProgressIndicator(color: _primaryGreen),
                  ),
                )
              : const SizedBox(height: 100);
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: _buildPostCard(_filteredPosts[i]),
        );
      }, childCount: _filteredPosts.length + 1),
    );
  }

  // ── Post Card ─────────────────────────────────────────────────────────────
  Widget _buildPostCard(PostModel post) {
    final user = post.user;
    final avatarUrl = user?.avatarUrl ?? '';
    final isPublic = post.type == 'public';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PostDetailPage(postId: post.id)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2EFE0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Card Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  // Avatar with green gradient ring if public
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isPublic
                          ? const LinearGradient(
                              colors: [Color(0xFF0D631B), Color(0xFF38B04D)],
                            )
                          : null,
                      color: isPublic ? null : const Color(0xFFD0DCD0),
                    ),
                    child: CircleAvatar(
                      radius: 21,
                      backgroundColor: _lightGreen,
                      backgroundImage: avatarUrl.isNotEmpty
                          ? NetworkImage(avatarUrl)
                          : null,
                      child: avatarUrl.isEmpty
                          ? Text(
                              user?.initials ?? '?',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: _primaryGreen,
                              ),
                            )
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
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: _textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: isPublic
                                    ? const Color(0xFFE8F5E9)
                                    : const Color(0xFFFFF3E0),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isPublic
                                        ? Icons.public_rounded
                                        : Icons.lock_outline_rounded,
                                    size: 11,
                                    color: isPublic
                                        ? _primaryGreen
                                        : Colors.orange.shade800,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isPublic ? 'Publik' : 'Privat',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: isPublic
                                          ? _primaryGreen
                                          : Colors.orange.shade800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (post.createdAt != null) ...[
                              const SizedBox(width: 8),
                              Text(
                                '· ${_formatDate(post.createdAt!)}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: _textLight,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (post.user?.id == _currentUserId)
                    PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(
                        Icons.more_horiz_rounded,
                        color: _textLight,
                        size: 22,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      onSelected: (val) {
                        if (val == 'edit') _showEditPostDialog(post);
                        if (val == 'delete') _onDeletePost(post);
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit_outlined,
                                size: 18,
                                color: Color(0xFF0D631B),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Edit',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline,
                                size: 18,
                                color: Color(0xFFBA1A1A),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Hapus',
                                style: TextStyle(
                                  color: Color(0xFFBA1A1A),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
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
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.55,
                    color: _textDark,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

            // ── Image with proper padding and rounding ──
            if (post.image != null && post.image!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    post.imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 180,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F6F4),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.image_not_supported_rounded,
                        size: 36,
                        color: _textLight,
                      ),
                    ),
                  ),
                ),
              ),

            // ── Action Bar ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Row(
                children: [
                  _actionBtn(
                    icon: post.isLiked
                        ? Icons.favorite_rounded
                        : Icons.favorite_outline_rounded,
                    label: '${post.likeCount}',
                    color: post.isLiked
                        ? const Color(0xFFD32F2F)
                        : const Color(0xFF5A7561),
                    bgColor: post.isLiked
                        ? const Color(0xFFFFEBEE)
                        : const Color(0xFFF4F8F4),
                    onTap: () => _onLikePost(post.id),
                  ),
                  const SizedBox(width: 8),
                  _actionBtn(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: '${post.commentCount}',
                    color: const Color(0xFF0D631B),
                    bgColor: const Color(0xFFE8F5E9),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PostDetailPage(postId: post.id),
                      ),
                    ),
                  ),
                  const Spacer(),
                  _actionBtn(
                    icon: Icons.share_outlined,
                    label: 'Bagikan',
                    color: const Color(0xFF4A6B51),
                    bgColor: const Color(0xFFF4F8F4),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionBtn({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
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
}
