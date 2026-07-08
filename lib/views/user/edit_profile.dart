import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fe_mobile/services/user_service.dart';
import 'package:fe_mobile/services/health_service.dart';
import 'package:fe_mobile/services/auth_services.dart';
import 'package:fe_mobile/model/user_model.dart';
import 'package:fe_mobile/model/health_model.dart';
import 'package:fe_mobile/views/Auth/auth_page.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _selectedHealthTarget;
  bool _isLoading = false;
  bool _isInitLoading = true;
  UserModel? _currentUser;
  MedicalCheckupModel? _latestCheckup;
  bool _showPasswordInput = false;

  final List<Map<String, String>> _healthTargets = [
    {'value': 'gaya_hidup_sehat', 'label': 'Gaya Hidup Sehat'},
    {'value': 'menurunkan_berat_badan', 'label': 'Menurunkan Berat Badan'},
    {'value': 'membangun_otot', 'label': 'Membangun Otot'},
  ];

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    setState(() {
      _isInitLoading = true;
    });

    try {
      final user = await UserService.getProfile();
      if (user != null) {
        _currentUser = user;
        _usernameController.text = user.username;
        _emailController.text = user.email;
        _selectedHealthTarget = user.healthTarget;

        // Ambil data medical checkup terakhir untuk mendapatkan berat & tinggi badan
        final checkups = await HealthService.getCheckups();
        if (checkups.isNotEmpty) {
          checkups.sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));
          _latestCheckup = checkups.first;
          _weightController.text = _latestCheckup?.weight?.toString() ?? '';
          _heightController.text = _latestCheckup?.height?.toString() ?? '';
        }
      }
    } catch (e) {
      print("Error loading profile: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isInitLoading = false;
        });
      }
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Update Core Profile di backend
      final res = await UserService.updateProfile(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        healthTarget: _selectedHealthTarget,
        password: _showPasswordInput ? _passwordController.text : null,
      );

      if (res['success'] == true) {
        final updatedUser = res['data'] as UserModel;
        
        // Simpan data profil baru ke SharedPreferences agar sinkron di seluruh halaman
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('username', updatedUser.username);
        await prefs.setString('email', updatedUser.email);
        if (updatedUser.healthTarget != null) {
          await prefs.setString('health_target', updatedUser.healthTarget!);
        }

        // 2. Simpan rekam medis (berat/tinggi badan) jika ada perubahan
        final newWeight = double.tryParse(_weightController.text.trim());
        final newHeight = double.tryParse(_heightController.text.trim());

        if (newWeight != null || newHeight != null) {
          if (_latestCheckup == null || 
              _latestCheckup!.weight != newWeight || 
              _latestCheckup!.height != newHeight) {
            
            await HealthService.createCheckup(
              weight: newWeight,
              height: newHeight,
              date: DateTime.now().toIso8601String().split('T')[0],
              bloodPressure: _latestCheckup?.bloodPressure ?? "120/80",
              heartRate: _latestCheckup?.heartRate ?? 80,
              bloodSugar: _latestCheckup?.bloodSugar ?? 90.0,
              cholesterol: _latestCheckup?.cholesterol ?? 150.0,
            );
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profil berhasil diperbarui!'),
              backgroundColor: Color(0xFF0D631B),
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(res['message'] ?? 'Gagal memperbarui profil'),
              backgroundColor: const Color(0xFFBA1A1A),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: const Color(0xFFBA1A1A),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _confirmDeleteAccount() async {
    if (_currentUser == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Akun'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus akun Anda secara permanen? Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Color(0xFFBA1A1A))),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _isLoading = true;
      });

      final success = await UserService.deleteUser(_currentUser!.id);
      if (success) {
        await AuthService.logout();
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const AuthPage()),
            (_) => false,
          );
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal menghapus akun'),
              backgroundColor: Color(0xFFBA1A1A),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFDF9),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0D631B), Color(0xFF2E7D32)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        title: const Text(
          'Edit Profil',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isInitLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0D631B)),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar Section
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 96,
                            height: 96,
                            decoration: ShapeDecoration(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(width: 4, color: Colors.white),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              shadows: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                _currentUser?.initials ?? '?',
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0D631B),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              _currentUser?.role.toUpperCase() ?? 'USER',
                              style: const TextStyle(
                                color: Color(0xFF0D631B),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Inputs Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                          side: const BorderSide(color: Color(0xFFE2EFE0)),
                        ),
                        shadows: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Username
                          const Text(
                            'Nama Pengguna',
                            style: TextStyle(
                              color: Color(0xFF6B8B72),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _usernameController,
                            style: const TextStyle(
                              color: Color(0xFF1A2218),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.person_outline_rounded, color: Color(0xFF0D631B)),
                              filled: true,
                              fillColor: const Color(0xFFF4F8F4),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (val) => val == null || val.trim().isEmpty
                                ? 'Nama tidak boleh kosong'
                                : null,
                          ),
                          const SizedBox(height: 16),

                          // Email
                          const Text(
                            'Email',
                            style: TextStyle(
                              color: Color(0xFF6B8B72),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(
                              color: Color(0xFF1A2218),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF0D631B)),
                              filled: true,
                              fillColor: const Color(0xFFF4F8F4),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) return 'Email tidak boleh kosong';
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val.trim())) {
                                return 'Format email tidak valid';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Weight
                          const Text(
                            'Berat Badan (kg)',
                            style: TextStyle(
                              color: Color(0xFF6B8B72),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _weightController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                              color: Color(0xFF1A2218),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.scale_outlined, color: Color(0xFF0D631B)),
                              suffixText: 'kg',
                              suffixStyle: const TextStyle(color: Color(0xFF6B8B72), fontWeight: FontWeight.bold),
                              filled: true,
                              fillColor: const Color(0xFFF4F8F4),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Height
                          const Text(
                            'Tinggi Badan (cm)',
                            style: TextStyle(
                              color: Color(0xFF6B8B72),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _heightController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                              color: Color(0xFF1A2218),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.height_rounded, color: Color(0xFF0D631B)),
                              suffixText: 'cm',
                              suffixStyle: const TextStyle(color: Color(0xFF6B8B72), fontWeight: FontWeight.bold),
                              filled: true,
                              fillColor: const Color(0xFFF4F8F4),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Target Kesehatan
                          const Text(
                            'Target Kesehatan',
                            style: TextStyle(
                              color: Color(0xFF6B8B72),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _selectedHealthTarget,
                            onChanged: (val) {
                              setState(() {
                                _selectedHealthTarget = val;
                              });
                            },
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.track_changes_rounded, color: Color(0xFF0D631B)),
                              filled: true,
                              fillColor: const Color(0xFFF4F8F4),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            items: _healthTargets.map((item) {
                              return DropdownMenuItem<String>(
                                value: item['value'],
                                child: Text(
                                  item['label']!,
                                  style: const TextStyle(
                                    color: Color(0xFF1A2218),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 20),

                          // Ubah Kata Sandi Toggle
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _showPasswordInput = !_showPasswordInput;
                              });
                            },
                            child: Row(
                              children: [
                                Icon(
                                  _showPasswordInput ? Icons.keyboard_arrow_up : Icons.lock_outline_rounded,
                                  color: const Color(0xFF0D631B),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _showPasswordInput ? 'Batal Ubah Kata Sandi' : 'Ubah Kata Sandi',
                                  style: const TextStyle(
                                    color: Color(0xFF0D631B),
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          if (_showPasswordInput) ...[
                            const SizedBox(height: 16),
                            const Text(
                              'Kata Sandi Baru',
                              style: TextStyle(
                                color: Color(0xFF6B8B72),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              style: const TextStyle(
                                color: Color(0xFF1A2218),
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF0D631B)),
                                filled: true,
                                fillColor: const Color(0xFFF4F8F4),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              validator: (val) {
                                if (_showPasswordInput && (val == null || val.length < 6)) {
                                  return 'Kata sandi minimal 6 karakter';
                                }
                                return null;
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Buttons
                    _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0D631B)),
                            ),
                          )
                        : Column(
                            children: [
                              // Save Button
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: _saveChanges,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0D631B),
                                    foregroundColor: Colors.white,
                                    elevation: 4,
                                    shadowColor: const Color(0xFF0D631B).withOpacity(0.3),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: const Text(
                                    'Simpan Perubahan',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Delete Account Button
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: OutlinedButton(
                                  onPressed: _confirmDeleteAccount,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFFBA1A1A),
                                    side: const BorderSide(color: Color(0xFFBA1A1A), width: 1.5),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: const Text(
                                    'Hapus Akun',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ),
    );
  }
}