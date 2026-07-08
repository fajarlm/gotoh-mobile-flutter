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
      backgroundColor: const Color(0xFFF4F8F0),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 240,
              pinned: true,
              backgroundColor: const Color(0xFF0D631B),
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.black.withOpacity(0.4),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
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
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xFFC9E7CA), Color(0xFFE8F5E9)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: const Icon(Icons.diversity_3_rounded, size: 80, color: Color(0xFF0D631B)),
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
                            child: const Icon(Icons.diversity_3_rounded, size: 80, color: Color(0xFF0D631B)),
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
        body: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF4F8F0),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Title and Metadata Area
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _community.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF181D17),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Location & Member Count row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEBEFE5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 12, color: Color(0xFF4E6952)),
                              const SizedBox(width: 4),
                              Text(
                                _community.location ?? 'Publik',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF4E6952),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEBEFE5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.group_outlined, size: 12, color: Color(0xFF4E6952)),
                              const SizedBox(width: 4),
                              Text(
                                '${_community.memberCount} Anggota',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF4E6952),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
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
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
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
                                    icon: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 18),
                                    label: const Text(
                                      'Obrolan Komunitas',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Color(0xFFD32F2F), width: 1.5),
                                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  onPressed: _toggleJoinLeave,
                                  child: const Text(
                                    'Keluar',
                                    style: TextStyle(color: Color(0xFFD32F2F), fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ] else ...[
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0D631B),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    onPressed: _toggleJoinLeave,
                                    icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 18),
                                    label: const Text(
                                      'Gabung Komunitas',
                                      style: TextStyle(fontWeight: FontWeight.bold),
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
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                unselectedLabelColor: const Color(0xFF8FA89A),
                indicatorColor: const Color(0xFF0D631B),
                indicatorSize: TabBarIndicatorSize.label,
                indicatorWeight: 3,
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
                          const SizedBox(height: 10),
                          Text(
                            _community.description,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF40493D),
                              height: 1.6,
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
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      side: const BorderSide(color: Color(0xFFE8EFE9)),
                                    ),
                                    color: Colors.white,
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                      leading: CircleAvatar(
                                        backgroundColor: const Color(0xFFE8F5E9),
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
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: role == 'admin' ? const Color(0xFFFFF3E0) : const Color(0xFFEBEFE5),
                                          borderRadius: BorderRadius.circular(10),
                                          border: role == 'admin' ? Border.all(color: Colors.orange.shade200) : null,
                                        ),
                                        child: Text(
                                          role.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: role == 'admin' ? Colors.orange.shade800 : const Color(0xFF4E6952),
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
      ),
    );
  }
}