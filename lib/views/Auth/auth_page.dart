import 'package:fe_mobile/views/user/medical_checkup1.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fe_mobile/services/auth_services.dart';
import 'package:fe_mobile/views/admin/dashboard_admin.dart';
import 'package:fe_mobile/views/user/user_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Form keys
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();
  
  // Login controllers
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  
  // Register controllers
  final _registerNameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _registerConfirmPasswordController = TextEditingController();
  
  // Visibility toggles
  bool _isLoginPasswordVisible = false;
  bool _isRegisterPasswordVisible = false;
  bool _isRegisterConfirmPasswordVisible = false;
  
  // Loading state
  bool _isLoading = false;
  
  // Error messages
  String? _loginError;
  String? _registerError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _loginError = null;
          _registerError = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerNameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _registerConfirmPasswordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_loginFormKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _loginError = null;
      });

      final result = await AuthService.login(
        _loginEmailController.text.trim(),
        _loginPasswordController.text,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        final role = prefs.getString('role') ?? 'user';

        setState(() => _isLoading = false);

        if (role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DashboardAdminPage()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MedicalCheckup1()),
          );
        }
      } else {
        setState(() {
          _isLoading = false;
          _loginError = result['message'] ?? 'Email atau kata sandi salah';
        });
      }
    }
  }

  void _handleRegister() async {
    if (_registerFormKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _registerError = null;
      });

      final result = await AuthService.register(
        _registerNameController.text.trim(),
        _registerEmailController.text.trim(),
        _registerPasswordController.text,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        setState(() => _isLoading = false);
        _showSuccessDialog(
          'Pendaftaran Berhasil',
          'Akun Anda telah berhasil dibuat. Silakan masuk ke akun Anda.',
          onConfirm: () {
            _tabController.animateTo(0);
            _registerNameController.clear();
            _registerEmailController.clear();
            _registerPasswordController.clear();
            _registerConfirmPasswordController.clear();
          },
        );
      } else {
        setState(() {
          _isLoading = false;
          _registerError = result['message'] ?? 'Registrasi gagal';
        });
      }
    }
  }

  // void _handleGoogleSignIn() {
  //   setState(() => _isLoading = true);
    
  //   Future.delayed(const Duration(milliseconds: 800), () {
  //     if (mounted) {
  //       setState(() => _isLoading = false);
  //       _showSuccessDialog('Google Sign In', 'Fitur Google Sign In akan segera tersedia');
  //     }
  //   });
  // }

  void _showSuccessDialog(String title, String message, {VoidCallback? onConfirm}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 28),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          ],
        ),
        content: Text(message, style: const TextStyle(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // onconfirm = () = call() manggil function itu sendiri
              onConfirm?.call();
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF2E7D32),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Lupa Kata Sandi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Masukkan email Anda untuk menerima link reset kata sandi.'),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                hintText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (emailController.text.isNotEmpty) {
                _showSuccessDialog(
                  'Link Reset Dikirim',
                  'Silakan cek email Anda untuk mereset kata sandi.',
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF2E7D32),
            ),
            child: const Text('Kirim'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F7),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo Header
                  Column(
                    children: [
                      Text(
                        AuthConstants.appName,
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -0.64, height: 1.25, color: Color(0xFF556158)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AuthConstants.tagline,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.5, color: Color(0xFF434844)),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Illustration
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2E7D32).withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        AuthConstants.illustrationUrl,
                        fit: BoxFit.cover,
                        opacity: const AlwaysStoppedAnimation(0.8),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: const Color(0xFFE4E2E0),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: const Color(0xFFE4E2E0),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.image_not_supported, size: 40, color: Color(0xFF747873)),
                                  const SizedBox(height: 8),
                                  const Text('Gambar tidak tersedia', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.43, color: Color(0xFF434844))),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Auth Card
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2E7D32).withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Tabs
                        Container(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _tabController.animateTo(0),
                                  child: Column(
                                    children: [
                                      Text(
                                        'Masuk',
                                        style: TextStyle(
                                          fontSize: 16, 
                                          fontWeight: FontWeight.w600, 
                                          height: 1.5,
                                          color: _tabController.index == 0 
                                              ? const Color(0xFF556158) 
                                              : const Color(0xFF434844),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        height: 2,
                                        color: _tabController.index == 0 
                                            ? const Color(0xFF556158) 
                                            : Colors.transparent,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _tabController.animateTo(1),
                                  child: Column(
                                    children: [
                                      Text(
                                        'Daftar',
                                        style: TextStyle(
                                          fontSize: 16, 
                                          fontWeight: FontWeight.w600, 
                                          height: 1.5,
                                          color: _tabController.index == 1 
                                              ? const Color(0xFF556158) 
                                              : const Color(0xFF434844),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        height: 2,
                                        color: _tabController.index == 1 
                                            ? const Color(0xFF556158) 
                                            : Colors.transparent,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Tab Content
                        SizedBox(
                          height: _tabController.index == 0 ? 350 : 480,
                          child: TabBarView(
                            controller: _tabController,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              _buildLoginForm(),
                              _buildRegisterForm(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Footer
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Dengan melanjutkan, Anda menyetujui\n',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, height: 1.33, letterSpacing: 0.6, color: Color(0xFF434844)),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF556158),
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Ketentuan Layanan',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, decoration: TextDecoration.underline, color: Color(0xFF556158)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('&', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, height: 1.33, letterSpacing: 0.6, color: Color(0xFF434844))),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF556158),
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Kebijakan Privasi',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, decoration: TextDecoration.underline, color: Color(0xFF556158)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Form(
        key: _loginFormKey,
        child: Column(
          children: [
            // Email Field
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Text('Email', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, height: 1.33, letterSpacing: 0.6, color: Color(0xFF434844))),
                ),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _loginEmailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email tidak boleh kosong';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Masukkan email yang valid';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: Icon(Icons.mail_outline, size: 20, color: Color(0xFF747873)),
                    hintText: 'nama@email.com',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide(color: Color(0xFFC8E6C9)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide(color: Color(0xFFC8E6C9)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide(color: Color(0xFF2E7D32), width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide(color: Color(0xFFBA1A1A)),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide(color: Color(0xFFBA1A1A), width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Password Field
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Kata Sandi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, height: 1.33, letterSpacing: 0.6, color: Color(0xFF434844))),
                      Text(
                        'Lupa Sandi?',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF556158)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _loginPasswordController,
                  obscureText: !_isLoginPasswordVisible,
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Kata sandi tidak boleh kosong';
                    }
                    if (value.length < 6) {
                      return 'Kata sandi minimal 6 karakter';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => _handleLogin(),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.lock_outline, size: 20, color: Color(0xFF747873)),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _isLoginPasswordVisible = !_isLoginPasswordVisible),
                      icon: Icon(
                        _isLoginPasswordVisible ? Icons.visibility_off : Icons.visibility,
                        size: 20,
                        color: const Color(0xFF747873),
                      ),
                    ),
                    hintText: '••••••••',
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide(color: Color(0xFFC8E6C9)),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide(color: Color(0xFFC8E6C9)),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide(color: Color(0xFF2E7D32), width: 2),
                    ),
                    errorBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide(color: Color(0xFFBA1A1A)),
                    ),
                    focusedErrorBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide(color: Color(0xFFBA1A1A), width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
              ],
            ),
            if (_loginError != null) ...[
              const SizedBox(height: 8),
              Text(
                _loginError!,
                style: const TextStyle(color: Color(0xFFBA1A1A), fontSize: 12),
              ),
            ],
            const SizedBox(height: 16),
            // Login Button
            SizedBox(
              width: double.infinity,
              child: _isLoading && _tabController.index == 0
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        elevation: 8,
                        shadowColor: Color(0xFF2E7D32).withOpacity(0.3),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      child: const Text('Masuk'),
                    ),
            ),
            const SizedBox(height: 20),
            // Divider
            // Row(
            //   children: [
            //     Expanded(child: Container(height: 1, color: const Color(0xFFC3C8C2))),
            //     const Padding(
            //       padding: EdgeInsets.symmetric(horizontal: 16),
            //       child: Text('Atau', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, height: 1.33, letterSpacing: 0.6, color: Color(0xFF747873))),
            //     ),
            //     Expanded(child: Container(height: 1, color: const Color(0xFFC3C8C2))),
            //   ],
            // ),
            // const SizedBox(height: 20),
            // // Google Sign In
            // SizedBox(
            //   width: double.infinity,
            //   child: OutlinedButton.icon(
            //     onPressed: _isLoading ? null : _handleGoogleSignIn,
            //     icon: _buildGoogleIcon(),
            //     label: const Text('Masuk dengan Google'),
            //     style: OutlinedButton.styleFrom(
            //       foregroundColor: const Color(0xFF2E7D32),
            //       side: const BorderSide(color: Color(0xFF2E7D32)),
            //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            //       padding: const EdgeInsets.symmetric(vertical: 16),
            //       textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        child: Form(
          key: _registerFormKey,
          child: Column(
            children: [
              // Name Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Text('Nama Lengkap', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, height: 1.33, letterSpacing: 0.6, color: Color(0xFF434844))),
                  ),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: _registerNameController,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama tidak boleh kosong';
                      }
                      if (value.length < 3) {
                        return 'Nama minimal 3 karakter';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: Icon(Icons.person_outline, size: 20, color: Color(0xFF747873)),
                      hintText: 'Nama lengkap Anda',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Color(0xFFC8E6C9)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Color(0xFFC8E6C9)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Color(0xFF2E7D32), width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Color(0xFFBA1A1A)),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Color(0xFFBA1A1A), width: 2),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Email Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Text('Email', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, height: 1.33, letterSpacing: 0.6, color: Color(0xFF434844))),
                  ),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: _registerEmailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email tidak boleh kosong';
                      }
                      if (!value.contains('@') || !value.contains('.')) {
                        return 'Masukkan email yang valid';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: Icon(Icons.mail_outline, size: 20, color: Color(0xFF747873)),
                      hintText: 'nama@email.com',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Color(0xFFC8E6C9)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Color(0xFFC8E6C9)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Color(0xFF2E7D32), width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Color(0xFFBA1A1A)),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Color(0xFFBA1A1A), width: 2),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Password Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Text('Kata Sandi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, height: 1.33, letterSpacing: 0.6, color: Color(0xFF434844))),
                  ),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: _registerPasswordController,
                    obscureText: !_isRegisterPasswordVisible,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Kata sandi tidak boleh kosong';
                      }
                      if (value.length < 6) {
                        return 'Kata sandi minimal 6 karakter';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.lock_outline, size: 20, color: Color(0xFF747873)),
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => _isRegisterPasswordVisible = !_isRegisterPasswordVisible),
                        icon: Icon(
                          _isRegisterPasswordVisible ? Icons.visibility_off : Icons.visibility,
                          size: 20,
                          color: const Color(0xFF747873),
                        ),
                      ),
                      hintText: '••••••••',
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Color(0xFFC8E6C9)),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Color(0xFFC8E6C9)),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Color(0xFF2E7D32), width: 2),
                      ),
                      errorBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Color(0xFFBA1A1A)),
                      ),
                      focusedErrorBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Color(0xFFBA1A1A), width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Confirm Password Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Text('Konfirmasi Kata Sandi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, height: 1.33, letterSpacing: 0.6, color: Color(0xFF434844))),
                  ),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: _registerConfirmPasswordController,
                    obscureText: !_isRegisterConfirmPasswordVisible,
                    textInputAction: TextInputAction.done,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Konfirmasi kata sandi tidak boleh kosong';
                      }
                      if (value != _registerPasswordController.text) {
                        return 'Kata sandi tidak cocok';
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) => _handleRegister(),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.lock_outline, size: 20, color: Color(0xFF747873)),
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => _isRegisterConfirmPasswordVisible = !_isRegisterConfirmPasswordVisible),
                        icon: Icon(
                          _isRegisterConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                          size: 20,
                          color: const Color(0xFF747873),
                        ),
                      ),
                      hintText: '••••••••',
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Color(0xFFC8E6C9)),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Color(0xFFC8E6C9)),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Color(0xFF2E7D32), width: 2),
                      ),
                      errorBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Color(0xFFBA1A1A)),
                      ),
                      focusedErrorBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Color(0xFFBA1A1A), width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                ],
              ),
              if (_registerError != null) ...[
                const SizedBox(height: 8),
                Text(
                  _registerError!,
                  style: const TextStyle(color: Color(0xFFBA1A1A), fontSize: 12),
                ),
              ],
              const SizedBox(height: 20),
              // Register Button
              SizedBox(
                width: double.infinity,
                child: _isLoading && _tabController.index == 1
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _handleRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          elevation: 8,
                          shadowColor: Color(0xFF2E7D32).withOpacity(0.3),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        child: const Text('Daftar'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleIcon() {
    return Image.network(
      'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
      width: 20,
      height: 20,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.g_mobiledata, size: 20);
      },
    );
  }
}

// ==================== CONSTANTS ====================

class AuthConstants {
  static const String appName = 'GOTOH';
  static const String tagline = 'Temukan Ketenangan Dalam Perjalanan Kesehatanmu';
  static const String illustrationUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuCca2GFv5yZvmqxuPS5q0NIYd_lxuuRdliNZDKrUcumSE-R206oRNddneivKqCSw0Ot097B_tkJtRTm8T5yXta7JZKaiR_tZtdb1S3YlgsTAxKmi5ERszFUQYqsMMID_OqlGQqE1LIr1Sm1wc6r8kEiyPARJ6EZdbcXtlnhoE0OPNhPVS2pPkVWJf4OVbrZ4PeU9LJhh_ygW6xji7NNvcH33AgFRDL_0chNcMQcecmsi0lsqxCQaM9n6D80wy3XI-7AvZq0dd1mMAic';
}