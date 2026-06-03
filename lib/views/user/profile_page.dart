import 'package:fe_mobile/views/user/edit_profile.dart';
import 'package:flutter/material.dart';
import 'package:fe_mobile/services/auth_services.dart';
import 'package:fe_mobile/services/user_service.dart';
import 'package:fe_mobile/services/community_service.dart';
import 'package:fe_mobile/model/user_model.dart';
import 'package:fe_mobile/model/community_model.dart';
import 'package:fe_mobile/views/Auth/auth_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const _primaryGreen = Color(0xFF0D631B);
  static const _lightGreen = Color(0xFFC9E7CA);
  static const _bgColor = Color(0xFFF7FBF0);

  UserModel? _user;
  List<CommunityModel> _joinedCommunities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.wait([_loadProfile(), _loadCommunities()]);
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _loadProfile() async {
    final user = await UserService.getProfile();
    if (mounted && user != null) setState(() => _user = user);
  }

  Future<void> _loadCommunities() async {
    final res = await CommunityService.getCommunities(limit: 50);
    if (res['success'] == true && mounted) {
      final all = res['data'] as List<CommunityModel>;
      setState(() => _joinedCommunities = all.where((c) => c.isMember).toList());
    }
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AuthPage()),
        (_) => false,
      );
    }
  }

  void _editProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditProfile()),
    );
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? const BackButton(color: Color(0xFF0D631B))
            : null,
        title: const Text(
          'Profil',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF064E3B),
          ),
        ),
        actions: [
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh_rounded, color: _primaryGreen),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _primaryGreen))
          : RefreshIndicator(
              onRefresh: _loadData,
              color: _primaryGreen,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _buildHeader(),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoCard(),
                          const SizedBox(height: 20),
                          _buildHealthTargetCard(),
                          const SizedBox(height: 20),
                          _buildCommunitiesSection(),
                          const SizedBox(height: 32),
                          _buildLogoutButton(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    final username = _user?.username ?? '';
    final email = _user?.email ?? '';
    final avatarUrl = _user?.avatarUrl ?? '';

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF43A047)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 32),
          // Avatar
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 16, spreadRadius: 2)],
            ),
            child: CircleAvatar(
              radius: 52,
              backgroundColor: _lightGreen,
              backgroundImage: (avatarUrl.isNotEmpty && !avatarUrl.endsWith('/null'))
                  ? NetworkImage(avatarUrl)
                  : null,
              child: (avatarUrl.isEmpty || avatarUrl.endsWith('/null'))
                  ? Text(
                      username.isNotEmpty ? username[0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 44, fontWeight: FontWeight.bold, color: _primaryGreen),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            username.isNotEmpty ? username : 'User',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.3),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: const TextStyle(fontSize: 14, color: Colors.white70),
          ),
          const SizedBox(height: 6),
          // Role badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              (_user?.role ?? 'user').toUpperCase(),
              style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700, letterSpacing: 1),
            ),
          ),
          const SizedBox(height: 20),
          // Edit button
          ElevatedButton.icon(
            onPressed: _editProfile,
            icon: const Icon(Icons.edit_rounded, size: 18),
            label: const Text('Edit Profil', style: TextStyle(fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: _primaryGreen,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 0,
            ),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }

  // ── Info Card ─────────────────────────────────────────────────────────────
  Widget _buildInfoCard() {
    final prefs_username = _user?.username ?? '-';
    final prefs_email = _user?.email ?? '-';
    final joinDate = _user?.createdAt != null
        ? '${_user!.createdAt!.day}/${_user!.createdAt!.month}/${_user!.createdAt!.year}'
        : '-';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE0E4DA)),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informasi Akun',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _primaryGreen),
            ),
            const SizedBox(height: 16),
            _infoRow(Icons.person_outline_rounded, 'Username', prefs_username),
            const Divider(height: 20, color: Color(0xFFF0F4EA)),
            _infoRow(Icons.email_outlined, 'Email', prefs_email),
            const Divider(height: 20, color: Color(0xFFF0F4EA)),
            _infoRow(Icons.calendar_today_outlined, 'Bergabung', joinDate),
            const Divider(height: 20, color: Color(0xFFF0F4EA)),
            _infoRow(Icons.group_outlined, 'Komunitas', '${_joinedCommunities.length} komunitas'),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: _lightGreen, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 18, color: _primaryGreen),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A2218))),
            ],
          ),
        ),
      ],
    );
  }

  // ── Health Target Card ────────────────────────────────────────────────────
  Widget _buildHealthTargetCard() {
    final target = _user?.healthTarget;
    final Map<String, Map<String, dynamic>> targets = {
      'menurunkan_berat_badan': {
        'label': 'Menurunkan Berat Badan',
        'icon': Icons.fitness_center_rounded,
        'color': const Color(0xFFE3F2FD),
        'iconColor': const Color(0xFF1565C0),
      },
      'gaya_hidup_sehat': {
        'label': 'Gaya Hidup Sehat',
        'icon': Icons.spa_rounded,
        'color': const Color(0xFFE8F5E9),
        'iconColor': _primaryGreen,
      },
      'membangun_otot': {
        'label': 'Membangun Otot',
        'icon': Icons.sports_gymnastics_rounded,
        'color': const Color(0xFFFFF3E0),
        'iconColor': const Color(0xFFE65100),
      },
    };

    final info = target != null ? targets[target] : null;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE0E4DA)),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: info != null ? info['color'] as Color : _lightGreen,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                info != null ? info['icon'] as IconData : Icons.track_changes_rounded,
                size: 28,
                color: info != null ? info['iconColor'] as Color : _primaryGreen,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Target Kesehatan', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(
                    info != null ? info['label'] as String : 'Belum diatur',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A2218)),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: _editProfile,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _lightGreen,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Ubah', style: TextStyle(fontSize: 12, color: _primaryGreen, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Joined Communities ────────────────────────────────────────────────────
  Widget _buildCommunitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Komunitas Diikuti',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF1A2218)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: _lightGreen, borderRadius: BorderRadius.circular(12)),
              child: Text(
                '${_joinedCommunities.length}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _primaryGreen),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (_joinedCommunities.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE0E4DA)),
            ),
            child: const Column(
              children: [
                Icon(Icons.group_add_outlined, size: 40, color: Colors.grey),
                SizedBox(height: 8),
                Text('Belum bergabung komunitas', style: TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          )
        else
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _joinedCommunities.map((c) => _buildCommunityChip(c)).toList(),
          ),
      ],
    );
  }

  Widget _buildCommunityChip(CommunityModel community) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD0E8D2)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(color: _lightGreen, borderRadius: BorderRadius.circular(6)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: (community.coverImageUrl.isNotEmpty && !community.coverImageUrl.endsWith('/null'))
                  ? Image.network(community.coverImageUrl, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.group, size: 14, color: _primaryGreen))
                  : const Icon(Icons.group, size: 14, color: _primaryGreen),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            community.name,
            style: const TextStyle(color: Color(0xFF334D37), fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: _logout,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFEBEE), Color(0xFFFFCDD2)],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFBA1A1A).withOpacity(0.3)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFFBA1A1A), size: 20),
            SizedBox(width: 8),
            Text(
              'Keluar',
              style: TextStyle(fontSize: 15, color: Color(0xFFBA1A1A), fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}