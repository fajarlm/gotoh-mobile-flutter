import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = const [
    {
      'title': 'GOTOH',
      'subtitle': 'Fokus Hari Ini\nKetenangan Diri',
    },
    {
      'title': 'GOTOH',
      'subtitle': '300+ Member\nGrup Delbetas\n\nDilemas! Aktif\nSaling Berbagi',
    },
    {
      'title': 'GOTOH',
      'subtitle': 'Amt Tersedia\n24/7',
    },
  ];

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      // Navigate to main app or login
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Onboarding completed!')),
      );
    }
  }

  void _onSkip() {
    // Handle skip onboarding
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Onboarding skipped!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header with Lantut button and skip
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Lantut →',
                      style: TextStyle(
                        color: Color(0xFF2D6A4F),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _onSkip,
                    child: const Text(
                      'Lewati Onboarding',
                      style: TextStyle(
                        color: Color(0xFF9E9E9E),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final data = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(flex: 1),
                        // Circle avatar placeholder
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.favorite_outline,
                            size: 60,
                            color: const Color(0xFF2D6A4F),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          data['title']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B3A2A),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          data['subtitle']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF5D6B5D),
                            height: 1.6,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(flex: 2),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Dots indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: _currentPage == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == i
                        ? const Color(0xFF2D6A4F)
                        : const Color(0xFFD0D5D0),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Bottom section with features and button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Features row
                  Row(
                    children: [
                      Expanded(
                        child: _buildFeatureCard(
                          icon: Icons.people_outline,
                          title: 'Komunitas\nPendukung',
                          subtitle: 'Temukan ribuan grup diskusi kesehatan',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildFeatureCard(
                          icon: Icons.medical_services_outlined,
                          title: 'Konsultasi\nAhli',
                          subtitle: 'Akses langsung ke dokter & ahli gizi',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Quote text
                  const Text(
                    'Langkah Tenang untuk Hidup Sehat',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4A5B4A),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Text(
                    'Kelola kesehatan Anda dengan cara yang lebih tenang',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8A9A8A),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D6A4F),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentPage < _pages.length - 1
                            ? 'Lantut →'
                            : 'Mulai Sekarang →',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Login link
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Sudah punya akun? Masuk',
                      style: TextStyle(
                        color: Color(0xFF2D6A4F),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: const Color(0xFF2D6A4F)),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B3A2A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF8A9A8A),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}