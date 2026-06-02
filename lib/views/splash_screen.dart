import 'package:fe_mobile/views/Auth/auth_page.dart';
import 'package:flutter/material.dart';
import 'package:fe_mobile/services/auth_services.dart';
import 'package:fe_mobile/views/admin/dashboard_admin.dart';
import 'package:fe_mobile/views/user/user_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
  with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  double progress = 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_controller);

    _controller.forward();

    _startLoading();
  }

  Future<void> _startLoading() async {
    for (int i = 0; i <= 100; i++) {
      await Future.delayed(const Duration(milliseconds: 25));

      if (mounted) {
        setState(() {
          progress = i / 100;
        });
      }
    }

    if (!mounted) return;

    final loggedIn = await AuthService.isLoggedIn();
    if (loggedIn) {
      final role = await AuthService.getRole();
      if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardAdminPage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const UserPage()),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthPage()),
      );
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffE8F2E8),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: -100,
              left: -100,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.25),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 15,
                              color: Colors.black.withOpacity(.05),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/logo_bg.png',
                          width: 100,
                          height: 100,
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        "GOTOH", 
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff0F6A42),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        "Go To Health",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: 80,
              left: 40,
              right: 40,
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: Colors.white,
                      valueColor: const AlwaysStoppedAnimation(
                        Color(0xff0F6A42),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    "${(progress * 100).toInt()}%",
                    style: const TextStyle(
                      color: Color(0xff0F6A42),
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 25),

                  Text(
                    "HARMONIZING WELLNESS",
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 11,
                      letterSpacing: 2,
                    ),
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