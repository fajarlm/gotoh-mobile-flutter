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
      setState(
        () => _joinedCommunities = all.where((c) => c.isMember).toList(),
      );
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
      backgroundColor: const Color(0xFFFAFDF9),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? const BackButton(color: Colors.white)
            : null,
        title: const Text(
          'Profil',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
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

                    Transform.translate(
                      offset: const Offset(0, -24),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoCard(),
                            const SizedBox(height: 20),
                            _buildHealthTargetCard(),
                            const SizedBox(height: 20),
                            _buildCommunitiesSection(),
                            const SizedBox(height: 36),
                            _buildLogoutButton(),
                            const SizedBox(height: 40),
                          ],
                        ),
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
          colors: [Color(0xFF0D631B), Color(0xFF1E822E), Color(0xFF38B04D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: kToolbarHeight + 40),
          // Avatar
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 54,
              backgroundColor: _lightGreen,
              backgroundImage:
                  (avatarUrl.isNotEmpty && !avatarUrl.endsWith('/null'))
                  ? NetworkImage(avatarUrl)
                  : null,
              child: (avatarUrl.isEmpty || avatarUrl.endsWith('/null'))
                  ? Text(
                      username.isNotEmpty ? username[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.bold,
                        color: _primaryGreen,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            username.isNotEmpty ? username : 'User',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          // Role badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              (_user?.role ?? 'user').toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Edit button
          ElevatedButton.icon(
            onPressed: _editProfile,
            icon: const Icon(
              Icons.edit_rounded,
              size: 16,
              color: _primaryGreen,
            ),
            label: const Text(
              'Edit Profil',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: _primaryGreen,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 0,
            ),
          ),
          const SizedBox(height: 36),
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

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2EFE0)),
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Akun',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: _primaryGreen,
            ),
          ),
          const SizedBox(height: 20),
          _infoRow(Icons.person_outline_rounded, 'Username', prefs_username),
          const Divider(height: 24, color: Color(0xFFE2EFE0)),
          _infoRow(Icons.email_outlined, 'Email', prefs_email),
          const Divider(height: 24, color: Color(0xFFE2EFE0)),
          _infoRow(Icons.calendar_today_outlined, 'Bergabung', joinDate),
          const Divider(height: 24, color: Color(0xFFE2EFE0)),
          _infoRow(
            Icons.group_outlined,
            'Komunitas',
            '${_joinedCommunities.length} komunitas',
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFF4F8F4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2EFE0)),
          ),
          child: Icon(icon, size: 20, color: _primaryGreen),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF6B8B72),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1B3C21),
                ),
              ),
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

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2EFE0)),
      ),
      padding: const EdgeInsets.all(22),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: info != null
                  ? info['color'] as Color
                  : const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              info != null
                  ? info['icon'] as IconData
                  : Icons.track_changes_rounded,
              size: 28,
              color: info != null ? info['iconColor'] as Color : _primaryGreen,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Target Kesehatan',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B8B72),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  info != null ? info['label'] as String : 'Belum diatur',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1B3C21),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _editProfile,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Text(
                'Ubah',
                style: TextStyle(
                  fontSize: 12,
                  color: _primaryGreen,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
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
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1B3C21),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F8F4),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: const Color(0xFFE2EFE0)),
              ),
              child: Text(
                '${_joinedCommunities.length}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: _primaryGreen,
                ),
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
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2EFE0)),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.group_add_outlined,
                  size: 40,
                  color: Color(0xFF6B8B72),
                ),
                SizedBox(height: 8),
                Text(
                  'Belum bergabung komunitas',
                  style: TextStyle(
                    color: Color(0xFF6B8B72),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
        else
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _joinedCommunities
                .map((c) => _buildCommunityChip(c))
                .toList(),
          ),
      ],
    );
  }

  Widget _buildCommunityChip(CommunityModel community) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2EFE0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: _lightGreen,
              borderRadius: BorderRadius.circular(6),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child:
                  (community.coverImageUrl.isNotEmpty &&
                      !community.coverImageUrl.endsWith('/null'))
                  ? Image.network(
                      community.coverImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.group,
                        size: 14,
                        color: _primaryGreen,
                      ),
                    )
                  : const Icon(Icons.group, size: 14, color: _primaryGreen),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            community.name,
            style: const TextStyle(
              color: Color(0xFF334D37),
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
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
          color: const Color(0xFFFFEBEE),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFBA1A1A).withOpacity(0.15)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFFBA1A1A), size: 20),
            SizedBox(width: 8),
            Text(
              'Keluar dari GOTOH',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFFBA1A1A),
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
