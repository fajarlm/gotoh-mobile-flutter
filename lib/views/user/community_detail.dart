import 'package:flutter/material.dart';
import 'package:fe_mobile/model/community_model.dart';
import 'package:fe_mobile/services/community_service.dart';
import 'package:fe_mobile/views/user/chat_room.dart';

// Alias agar konsisten dengan routes / nama figma
typedef DetailKomunitas = CommunityDetailPage;

class CommunityDetailPage extends StatefulWidget {
  final CommunityModel community;
  const CommunityDetailPage({super.key, required this.community});

  @override
  State<CommunityDetailPage> createState() => _CommunityDetailPageState();
}

class _CommunityDetailPageState extends State<CommunityDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late CommunityModel _community;
  List<Map<String, dynamic>> _members = [];
  bool _isLoadingDetails = false;
  bool _isLoadingMembers = false;
  bool _isActionInProgress = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _community = widget.community;
    _refreshCommunityDetails();
    _fetchMembers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshCommunityDetails() async {
    setState(() {
      _isLoadingDetails = true;
    });
    final updated = await CommunityService.getCommunity(_community.id);
    if (mounted) {
      setState(() {
        if (updated != null) {
          _community = updated;
        }
        _isLoadingDetails = false;
      });
    }
  }

  Future<void> _fetchMembers() async {
    setState(() {
      _isLoadingMembers = true;
    });
    final membersList = await CommunityService.getCommunityMembers(_community.id);
    setState(() {
      _members = membersList;
      _isLoadingMembers = false;
    });
  }

  Future<void> _toggleJoinLeave() async {
    if (_isActionInProgress) return;
    setState(() {
      _isActionInProgress = true;
    });

    if (_community.isMember) {
      // Confirm leaving
      final confirm = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Keluar Komunitas'),
          content: Text('Yakin ingin keluar dari komunitas "${_community.name}"?'),
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
        setState(() {
          _isActionInProgress = false;
        });
        return;
      }
      final success = await CommunityService.leaveCommunity(_community.id);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Anda telah keluar dari ${_community.name}'), backgroundColor: const Color(0xFF0D631B)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal keluar dari komunitas'), backgroundColor: Color(0xFFBA1A1A)),
        );
      }
    } else {
      // Join
      final success = await CommunityService.joinCommunity(_community.id);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selamat! Anda bergabung dengan ${_community.name}'), backgroundColor: const Color(0xFF0D631B)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal bergabung dengan komunitas'), backgroundColor: Color(0xFFBA1A1A)),
        );
      }
    }

    await _refreshCommunityDetails();
    await _fetchMembers();
    setState(() {
      _isActionInProgress = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBF0),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 240,
              pinned: true,
              backgroundColor: const Color(0xFF0D631B),
              iconTheme: const IconThemeData(color: Colors.white),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    _community.coverImageUrl.isNotEmpty
                        ? Image.network(
                            _community.coverImageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: const Color(0xFFC9E7CA),
                                child: const Icon(Icons.group, size: 80, color: Color(0xFF0D631B)),
                              );
                            },
                          )
                        : Container(
                            color: const Color(0xFFC9E7CA),
                            child: const Icon(Icons.group, size: 80, color: Color(0xFF0D631B)),
                          ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.4),
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: Column(
          children: [
            // Title and Metadata Area
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _community.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF181D17),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC9E7CA),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _community.location ?? 'Publik',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0D631B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_community.memberCount} Anggota',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF40493D),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // CTA Button Row
                  _isActionInProgress
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF0D631B)))
                      : Row(
                          children: [
                            if (_community.isMember) ...[
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0D631B),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChatRoomKomunitas(community: _community),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
                                  label: const Text(
                                    'Obrolan Komunitas',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.redAccent),
                                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: _toggleJoinLeave,
                                child: const Text(
                                  'Keluar',
                                  style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ] else ...[
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0D631B),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: _toggleJoinLeave,
                                  icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                                  label: const Text(
                                    'Gabung Komunitas',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                ],
              ),
            ),
            // Tabs Header
            TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF0D631B),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF0D631B),
              tabs: const [
                Tab(text: 'Informasi'),
                Tab(text: 'Anggota'),
              ],
            ),
            // Tab Contents
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Informasi
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tentang Komunitas',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF181D17),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _community.description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF40493D),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Tab 2: Anggota
                  _isLoadingMembers
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF0D631B)))
                      : _members.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Text('Belum ada anggota di komunitas ini.'),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              itemCount: _members.length,
                              itemBuilder: (context, index) {
                                final member = _members[index];
                                final user = member['User'] as Map<String, dynamic>?;
                                final name = user?['name'] ?? 'Anggota Gotoh';
                                final role = member['role'] ?? 'member';

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  color: Colors.white,
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: const Color(0xFFC9E7CA),
                                      child: Text(
                                        name.substring(0, 1).toUpperCase(),
                                        style: const TextStyle(color: Color(0xFF0D631B), fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    title: Text(
                                      name,
                                      style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF181D17)),
                                    ),
                                    trailing: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: role == 'admin' ? const Color(0xFFFFD9E2) : const Color(0xFFEBEFE5),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        role.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: role == 'admin' ? const Color(0xFF7F2448) : const Color(0xFF4E6952),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}