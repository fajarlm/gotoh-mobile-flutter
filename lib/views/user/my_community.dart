import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fe_mobile/model/community_model.dart';
import 'package:fe_mobile/services/community_service.dart';
import 'package:fe_mobile/views/user/community_detail.dart';
import 'package:fe_mobile/views/user/chat_room.dart';

// Alias agar konsisten dengan navigasi dari home_page.dart
typedef MyCommunityPage = CommunityListPage;

class CommunityListPage extends StatefulWidget {
  const CommunityListPage({super.key});

  @override
  State<CommunityListPage> createState() => _CommunityListPageState();
}

class _CommunityListPageState extends State<CommunityListPage> {
  List<CommunityModel> _communities = [];
  bool _isLoading = true;
  int _currentUserId = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _fetchCommunities();
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => _currentUserId = prefs.getInt('user_id') ?? 0);
  }

  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchCommunities(query: query);
    });
  }

  Future<void> _toggleJoinCommunity(CommunityModel community) async {
    setState(() => _isLoading = true);
    final isMember = community.isMember;
    bool success;

    if (isMember) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Keluar Komunitas'),
          content: Text('Yakin ingin keluar dari komunitas "${community.name}"?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFBA1A1A)),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Keluar', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
      if (confirm != true) {
        setState(() => _isLoading = false);
        return;
      }
      success = await CommunityService.leaveCommunity(community.id);
      if (success) {
        setState(() {
          final idx = _communities.indexWhere((c) => c.id == community.id);
          if (idx != -1) {
            _communities[idx] = _communities[idx].copyWith(
              isMember: false,
              memberCount: _communities[idx].memberCount - 1,
            );
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Anda telah keluar dari ${community.name}'), backgroundColor: const Color(0xFF0D631B)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal keluar dari komunitas'), backgroundColor: Color(0xFFBA1A1A)),
        );
      }
    } else {
      success = await CommunityService.joinCommunity(community.id);
      if (success) {
        setState(() {
          final idx = _communities.indexWhere((c) => c.id == community.id);
          if (idx != -1) {
            _communities[idx] = _communities[idx].copyWith(
              isMember: true,
              memberCount: _communities[idx].memberCount + 1,
            );
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selamat! Anda bergabung dengan ${community.name}'), backgroundColor: const Color(0xFF0D631B)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal bergabung dengan komunitas'), backgroundColor: Color(0xFFBA1A1A)),
        );
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _fetchCommunities({String? query}) async {
    setState(() {
      _isLoading = true;
    });
    final res = await CommunityService.getCommunities(name: query);
    if (res['success'] == true) {
      setState(() {
        _communities = res['data'] as List<CommunityModel>;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onCreateCommunity() {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final locController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Buat Komunitas Baru',
            style: TextStyle(color: Color(0xFF0D631B), fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nama Komunitas',
                    filled: true,
                    fillColor: const Color(0xFFF4F8F0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Deskripsi',
                    hintText: 'Minimal 10 karakter',
                    filled: true,
                    fillColor: const Color(0xFFF4F8F0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: locController,
                  decoration: InputDecoration(
                    labelText: 'Lokasi (Opsional)',
                    hintText: 'Contoh: Jakarta',
                    filled: true,
                    fillColor: const Color(0xFFF4F8F0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D631B),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                final name = nameController.text.trim();
                final desc = descController.text.trim();
                final loc = locController.text.trim();

                if (name.length < 3) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nama minimal 3 karakter')),
                  );
                  return;
                }
                if (desc.length < 10) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Deskripsi minimal 10 karakter')),
                  );
                  return;
                }

                Navigator.pop(context);
                final res = await CommunityService.createCommunity(
                  name: name,
                  description: desc,
                  location: loc.isEmpty ? 'Publik' : loc,
                );

                if (res['success'] == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Komunitas berhasil dibuat!')),
                  );
                  _fetchCommunities();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(res['message'] ?? 'Gagal membuat komunitas')),
                  );
                }
              },
              child: const Text('Buat', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _onViewCommunity(CommunityModel community) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommunityDetailPage(community: community),
      ),
    ).then((_) => _fetchCommunities());
  }

  Future<void> _onDeleteCommunity(CommunityModel community) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Komunitas'),
        content: Text('Yakin hapus komunitas "${community.name}"? Aksi ini tidak bisa dibatalkan.'),
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
    final ok = await CommunityService.deleteCommunity(community.id);
    if (!mounted) return;
    if (ok) {
      setState(() => _communities.removeWhere((c) => c.id == community.id));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Komunitas berhasil dihapus'), backgroundColor: Color(0xFF0D631B)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menghapus komunitas'), backgroundColor: Color(0xFFBA1A1A)),
      );
    }
  }

  void _showEditCommunityDialog(CommunityModel community) {
    final nameCtrl = TextEditingController(text: community.name);
    final descCtrl = TextEditingController(text: community.description);
    final locCtrl = TextEditingController(text: community.location ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit Komunitas', style: TextStyle(color: Color(0xFF0D631B), fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Nama Komunitas',
                  filled: true,
                  fillColor: const Color(0xFFF4F8F0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: descCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Deskripsi',
                  filled: true,
                  fillColor: const Color(0xFFF4F8F0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: locCtrl,
                decoration: InputDecoration(
                  labelText: 'Lokasi',
                  filled: true,
                  fillColor: const Color(0xFFF4F8F0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D631B)),
            onPressed: () async {
              final name = nameCtrl.text.trim();
              final desc = descCtrl.text.trim();
              final loc = locCtrl.text.trim();
              if (name.length < 3) {
                ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Nama minimal 3 karakter')));
                return;
              }
              if (desc.length < 10) {
                ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Deskripsi minimal 10 karakter')));
                return;
              }
              Navigator.pop(ctx);
              final res = await CommunityService.updateCommunity(
                id: community.id,
                name: name,
                description: desc,
                location: loc.isEmpty ? null : loc,
              );
              if (!mounted) return;
              if (res['success'] == true) {
                _fetchCommunities();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Komunitas berhasil diperbarui'), backgroundColor: Color(0xFF0D631B)),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(res['message'] ?? 'Gagal memperbarui'), backgroundColor: const Color(0xFFBA1A1A)),
                );
              }
            },
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8F0),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _fetchCommunities(query: _searchController.text),
          color: const Color(0xFF0D631B),
          child: Column(
            children: [
              // Beautiful Gradient Top Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0D631B), Color(0xFF1B8C2A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Logo and User Profile Info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.health_and_safety_rounded, color: Colors.white, size: 18),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'GOTOH',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        // Add Community Button (Glassmorphism look)
                        ElevatedButton.icon(
                          onPressed: _onCreateCommunity,
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text(
                            'Buat',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Komunitas Kesehatan',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Temukan teman diskusi dan kelola komunitas hidup sehat Anda.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              // Search Bar overlapping and margin
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Cari komunitas kesehatan...',
                      hintStyle: const TextStyle(color: Color(0xFF8FA89A), fontSize: 13),
                      prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF0D631B)),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                _fetchCommunities();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    ),
                  ),
                ),
              ),

              // Main List Content
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Color(0xFF0D631B)),
                      )
                    : _communities.isEmpty
                        ? Center(
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 72,
                                    height: 72,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFC9E7CA).withOpacity(0.5),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.diversity_3_rounded, size: 36, color: Color(0xFF0D631B)),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Belum ada komunitas',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF181D17)),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Yuk, mulai buat komunitas kesehatan pertamamu!',
                                    style: TextStyle(fontSize: 12, color: Color(0xFF4E6952)),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(20),
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: _communities.length,
                            itemBuilder: (context, index) {
                              return _buildCommunityCard(_communities[index]);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommunityCard(CommunityModel community) {
    final isOwner = community.createdBy == _currentUserId;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: const Color(0xFFE8EFE9)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row of Card (Image and Info)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Community Image / Placeholder
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: community.coverImageUrl.isNotEmpty
                          ? Image.network(
                              community.coverImageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Color(0xFFC9E7CA), Color(0xFFE8F5E9)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: const Icon(Icons.diversity_3_rounded, size: 32, color: Color(0xFF0D631B)),
                                );
                              },
                            )
                          : Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xFFC9E7CA), Color(0xFFE8F5E9)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: const Icon(Icons.diversity_3_rounded, size: 32, color: Color(0xFF0D631B)),
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Community Main Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                community.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF181D17),
                                  letterSpacing: -0.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Role Badge (Owner vs Joined)
                            if (isOwner)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF3E0),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.orange),
                                ),
                                child: Text(
                                  'Owner',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.orange.shade800,
                                  ),
                                ),
                              )
                            else if (community.isMember)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFC9E7CA)),
                                ),
                                child: const Text(
                                  'Joined',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0D631B),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Location and Members
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5EB),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.location_on_outlined, size: 10, color: Color(0xFF4E6952)),
                                  const SizedBox(width: 4),
                                  Text(
                                    community.location ?? 'Publik',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF4E6952),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5EB),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.group_outlined, size: 10, color: Color(0xFF4E6952)),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${_formatNumber(community.memberCount)} Anggota',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF4E6952),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Description paragraph
            if (community.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(
                  community.description,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF40493D),
                    height: 1.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            // Bottom Action Row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: const Color(0xFFF7FBF0),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF0D631B), width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => _onViewCommunity(community),
                      child: const Text(
                        'Detail',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D631B),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D631B),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        if (community.isMember) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatRoomKomunitas(community: community),
                            ),
                          );
                        } else {
                          _toggleJoinCommunity(community);
                        }
                      },
                      child: Text(
                        community.isMember ? 'Buka Chat' : 'Gabung',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (isOwner) ...[
                    const SizedBox(width: 8),
                    // Edit Icon Button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _showEditCommunityDialog(community),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFC9E7CA)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF0D631B)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Delete Icon Button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _onDeleteCommunity(community),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFFFCDD2)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.delete_outline_rounded, size: 16, color: Color(0xFFD32F2F)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }
}