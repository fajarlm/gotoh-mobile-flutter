import 'package:fe_mobile/services/auth_services.dart';
import 'package:fe_mobile/views/Auth/auth_page.dart';
import 'package:flutter/material.dart';
import 'package:fe_mobile/model/user_model.dart';
import 'package:fe_mobile/services/user_service.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  String _searchQuery = '';
  List<UserModel> _users = [];
  bool _isLoading = false;
  int _currentPage = 1;
  final int _itemsPerPage = 6;
  int _totalUsers = 0;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    final res = await UserService.getUsers(
      username: _searchQuery.isNotEmpty ? _searchQuery : null,
      page: _currentPage,
      limit: _itemsPerPage,
    );
    if (mounted) {
      if (res['success'] == true) {
        setState(() {
          _users = List<UserModel>.from(res['data']);
          _totalUsers = res['total'] ?? 0;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    }
  }

  int get _totalPages => (_totalUsers / _itemsPerPage).ceil();

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _currentPage = 1;
    });
    _fetchUsers();
  }

  void _onDeleteUser(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus User'),
        content: Text('Apakah Anda yakin ingin menghapus "${user.username}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await UserService.deleteUser(user.id);
              if (success) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${user.username} telah dihapus')),
                  );
                }
                _fetchUsers();
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Gagal menghapus user')),
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

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar dari portal Admin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await AuthService.logout();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const AuthPage()),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Keluar'),
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
          'Kelola User',
          style: TextStyle(color: Color(0xFF00450D), fontWeight: FontWeight.bold, fontSize: 18),
        ),
         actions: [
          IconButton(
            onPressed: _handleLogout,
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            tooltip: 'Logout',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchUsers,
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
                      hintText: 'Cari user...',
                      prefixIcon: Icon(Icons.search, color: Color(0xFF717A6D), size: 20),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Table Card
                _isLoading
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: CircularProgressIndicator(color: Color(0xFF00450D)),
                        ),
                      )
                    : _users.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: Text('Tidak ada user ditemukan', style: TextStyle(color: Colors.grey)),
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
                              itemCount: _users.length,
                              separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFE0E4DA)),
                              itemBuilder: (context, index) {
                                final user = _users[index];
                                final avatarUrl = user.avatarUrl;
                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  leading: CircleAvatar(
                                    radius: 22,
                                    backgroundColor: const Color(0xFFE8F5E9),
                                    backgroundImage: user.avatar != null ? NetworkImage(avatarUrl) : null,
                                    child: user.avatar == null
                                        ? Text(
                                            user.initials,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF00450D),
                                            ),
                                          )
                                        : null,
                                  ),
                                  title: Text(
                                    user.username,
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF181D17)),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(user.email, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color
                                              : const Color(0xFFE8F5E9),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          user.role.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: user.role == 'admin'
                                                ? const Color(0xFFC62828)
                                                : const Color(0xFF2E7D32),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                    onPressed: () => _onDeleteUser(user),
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
                                _fetchUsers();
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
                                _fetchUsers();
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