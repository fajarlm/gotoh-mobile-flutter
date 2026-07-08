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
                  decoration: const InputDecoration(
                    labelText: 'Nama Komunitas',
                    hintText: 'Masukkan nama komunitas',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi',
                    hintText: 'Minimal 10 karakter',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: locController,
                  decoration: const InputDecoration(
                    labelText: 'Lokasi (Opsional)',
                    hintText: 'Contoh: Jakarta',
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
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D631B)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
      backgroundColor: const Color(0xFFF7FBF0),
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF7FBF0).withOpacity(0.8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.menu,
                          size: 24,
                          color: Color(0xFF181D17),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'GOTOH',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                            color: Color(0xFF181D17),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFC9E7CA),
                      ),
                      child: const Icon(Icons.person, size: 16, color: Color(0xFF0D631B)),
                    ),
                  ],
                ),
              ),
            ),
            // Main Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _fetchCommunities(query: _searchController.text),
                color: const Color(0xFF0D631B),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section Header
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Komunitas Kesehatan',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.24,
                              color: Color(0xFF181D17),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Temukan dan kelola komunitas kesehatan Anda untuk hidup yang lebih baik.',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF40493D),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Search and Create Row
                      Column(
                        children: [
                          // Search Input Field
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE0E4DA)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              onChanged: _onSearchChanged,
                              decoration: InputDecoration(
                                hintText: 'Cari diskusi atau komunitas...',
                                prefixIcon: const Icon(Icons.search, color: Color(0xFF0D631B)),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear),
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
                          const SizedBox(height: 16),
                          // Create Button
                          GestureDetector(
                            onTap: _onCreateCommunity,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFF0D631B), width: 2),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.add_circle_outline, size: 20, color: Color(0xFF0D631B)),
                                  SizedBox(width: 8),
                                  Text(
                                    'Buat Komunitas Baru',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF0D631B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (_isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40.0),
                            child: CircularProgressIndicator(color: Color(0xFF0D631B)),
                          ),
                        )
                      else if (_communities.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40.0),
                            child: Text(
                              'Belum ada komunitas. Yuk buat yang pertama!',
                              style: TextStyle(color: Colors.grey, fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      else
                        ..._communities.map((community) => _buildCommunityCard(community)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunityCard(CommunityModel community) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E4DA)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Community Image
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: community.coverImageUrl.isNotEmpty
                    ? Image.network(
                        community.coverImageUrl,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 64,
                            height: 64,
                            color: const Color(0xFFC9E7CA),
                            child: const Icon(Icons.group, size: 32, color: Color(0xFF0D631B)),
                          );
                        },
                      )
                    : Container(
                        width: 64,
                        height: 64,
                        color: const Color(0xFFC9E7CA),
                        child: const Icon(Icons.group, size: 32, color: Color(0xFF0D631B)),
                      ),
              ),
              const SizedBox(width: 16),
              // Community Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            community.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF181D17),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFC9E7CA),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            community.location ?? 'Publik',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF4E6952),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.group, size: 14, color: Color(0xFF4E6952)),
                        const SizedBox(width: 4),
                        Text(
                          '${_formatNumber(community.memberCount)} Anggota',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF4E6952),
                          ),
                        ),
                        if (community.isMember) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.check_circle, size: 14, color: Color(0xFF0D631B)),
                          const SizedBox(width: 2),
                          const Text(
                            'Joined',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0D631B),
                            ),
                          ),
                        ]
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Description
          Text(
            community.description,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF40493D),
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          const SizedBox(height: 16),
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _onViewCommunity(community),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEBEFE5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        'Detail',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF0D631B),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () {
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
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D631B),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        community.isMember ? 'Buka Chat' : 'Gabung',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (community.createdBy == _currentUserId) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _showEditCommunityDialog(community),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF0D631B)),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _onDeleteCommunity(community),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFBA1A1A)),
                  ),
                ),
              ],
            ],
          ),
        ],
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