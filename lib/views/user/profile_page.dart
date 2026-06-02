import 'package:fe_mobile/views/user/edit_profile.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fe_mobile/services/auth_services.dart';
import 'package:fe_mobile/views/Auth/auth_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _username = '';
  String _email = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _username = prefs.getString('username') ?? 'User';
        _email = prefs.getString('email') ?? '';
      });
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

  void _editProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditProfile()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBF0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7FBF0),
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
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header dengan Gradient
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF0D631B)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  // Avatar
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.white24,
                    child: Text(
                      _username.isNotEmpty ? _username[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _username,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _email,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tombol Edit Profile
                  ElevatedButton.icon(
                    onPressed: _editProfile,
                    icon: const Icon(Icons.edit, size: 20),
                    label: const Text('Edit Profil'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0D631B),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),

            // Konten Utama
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Nutrisi
                  _buildNutritionStatus(),
                  const SizedBox(height: 24),

                  // Komunitas Diikuti
                  _buildCommunitiesSection(),
                  const SizedBox(height: 24),

                  // Riwayat Rekomendasi
                  _buildRecommendationHistory(),
                  const SizedBox(height: 40),

                  // Tombol Logout
                  _buildLogoutButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionStatus() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Status Nutrisi',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0D631B),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC9E7CA),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Sehat',
                    style: TextStyle(
                      color: Color(0xFF4E6952),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'INDEKS MASSA TUBUH',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const Text(
                      '22.5',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D631B),
                      ),
                    ),
                    const Text(
                      'Normal / Ideal',
                      style: TextStyle(fontSize: 16, color: Color(0xFF4A654E)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const LinearProgressIndicator(
              value: 0.85,
              backgroundColor: Color(0xFFE0E4DA),
              color: Color(0xFF0D631B),
              minHeight: 10,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Progress Capaian', style: TextStyle(fontSize: 13)),
                Text('85%', style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Komunitas Diikuti',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF181D17),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildCommunityChip('Gowes Sehat'),
            _buildCommunityChip('Diet Vegan ID'),
            _buildCommunityChip('Yoga Pagi'),
          ],
        ),
      ],
    );
  }

  Widget _buildCommunityChip(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFCCEACD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x4CBFCABA)),
      ),
      child: Text(
        name,
        style: const TextStyle(
          color: Color(0xFF334D37),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildRecommendationHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Riwayat Rekomendasi',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('Lihat Semua'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildRecommendationCard(
          title: 'Peningkatan Asupan Serat',
          subtitle: 'Berdasarkan data nutrisi mingguan Anda.',
          date: '12 Okt 2023 • Selesai',
          color: const Color(0xFFA3F69C),
        ),
        const SizedBox(height: 12),
        _buildRecommendationCard(
          title: 'Konsultasi Jantung Rutin',
          subtitle: 'Jadwalkan pengecekan rutin dengan dokter Spesialis.',
          date: '05 Okt 2023 • Baru',
          color: const Color(0xFFFFD9E2),
        ),
      ],
    );
  }

  Widget _buildRecommendationCard({
    required String title,
    required String subtitle,
    required String date,
    required Color color,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    date,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: _logout,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFBA1A1A), width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'Keluar',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFFBA1A1A),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}