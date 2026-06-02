import 'package:flutter/material.dart';
import 'package:fe_mobile/model/community_model.dart';
import 'package:fe_mobile/services/community_service.dart';
import 'package:fe_mobile/views/user/community_detail.dart';

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
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCommunities();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
    ).then((_) => _fetchCommunities()); // Refresh list when returning
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
                              onChanged: (val) {
                                _fetchCommunities(query: val);
                              },
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
                child: Image.network(
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
          // View Button
          GestureDetector(
            onTap: () => _onViewCommunity(community),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFEBEFE5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'Lihat Komunitas',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF0D631B),
                  ),
                ),
              ),
            ),
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