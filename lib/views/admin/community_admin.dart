import 'package:flutter/material.dart';
import 'package:fe_mobile/model/community_model.dart';
import 'package:fe_mobile/services/community_service.dart';

class CommunityManagementPage extends StatefulWidget {
  const CommunityManagementPage({super.key});

  @override
  State<CommunityManagementPage> createState() => _CommunityManagementPageState();
}

class _CommunityManagementPageState extends State<CommunityManagementPage> {
  String _searchQuery = '';
  List<CommunityModel> _communities = [];
  bool _isLoading = false;
  int _currentPage = 1;
  final int _itemsPerPage = 6;
  int _totalCommunities = 0;

  @override
  void initState() {
    super.initState();
    _fetchCommunities();
  }

  Future<void> _fetchCommunities() async {
    setState(() => _isLoading = true);
    final res = await CommunityService.getCommunities(
      name: _searchQuery.isNotEmpty ? _searchQuery : null,
      page: _currentPage,
      limit: _itemsPerPage,
    );
    if (mounted) {
      if (res['success'] == true) {
        setState(() {
          _communities = List<CommunityModel>.from(res['data']);
          _totalCommunities = res['total'] ?? 0;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    }
  }

  int get _totalPages => (_totalCommunities / _itemsPerPage).ceil();

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _currentPage = 1;
    });
    _fetchCommunities();
  }

  void _onDeleteCommunity(CommunityModel community) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Komunitas'),
        content: Text('Apakah Anda yakin ingin menghapus komunitas "${community.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await CommunityService.deleteCommunity(community.id);
              if (success) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Komunitas "${community.name}" telah dihapus')),
                  );
                }
                _fetchCommunities();
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Gagal menghapus komunitas')),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBF0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Kelola Komunitas',
          style: TextStyle(color: Color(0xFF00450D), fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchCommunities,
          color: const Color(0xFF00450D),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Input
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFC0C9BB)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: _onSearchChanged,
                    decoration: const InputDecoration(
                      hintText: 'Cari komunitas...',
                      prefixIcon: Icon(Icons.search, color: Color(0xFF717A6D), size: 20),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Communities Grid/List
                _isLoading
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: CircularProgressIndicator(color: Color(0xFF00450D)),
                        ),
                      )
                    : _communities.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: Text('Tidak ada komunitas ditemukan', style: TextStyle(color: Colors.grey)),
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE0E4DA)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _communities.length,
                              separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFE0E4DA)),
                              itemBuilder: (context, index) {
                                final community = _communities[index];
                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  leading: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE8F5E9),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.people, color: Color(0xFF00450D)),
                                  ),
                                  title: Text(
                                    community.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF181D17)),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        community.description,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${community.memberCount} Anggota • ${community.location ?? "Tanpa Lokasi"}',
                                        style: const TextStyle(color: Color(0xFF00450D), fontSize: 11, fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                    onPressed: () => _onDeleteCommunity(community),
                                  ),
                                );
                              },
                            ),
                          ),
                const SizedBox(height: 24),

                // Pagination
                if (_totalPages > 1)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: _currentPage > 1
                            ? () {
                                setState(() => _currentPage--);
                                _fetchCommunities();
                              }
                            : null,
                        icon: const Icon(Icons.chevron_left),
                      ),
                      Text(
                        'Halaman $_currentPage dari $_totalPages',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF40493D)),
                      ),
                      IconButton(
                        onPressed: _currentPage < _totalPages
                            ? () {
                                setState(() => _currentPage++);
                                _fetchCommunities();
                              }
                            : null,
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}