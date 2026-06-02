import 'package:flutter/material.dart';

class HealthAdmin extends StatefulWidget {
  const HealthAdmin({super.key});

  @override
  State<HealthAdmin> createState() => _HealthAdminState();
}

class _HealthAdminState extends State<HealthAdmin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBF0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Riwayat Medical Checkup',
          style: TextStyle(color: Color(0xFF00450D), fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.verified_user_outlined,
                color: Color(0xFF00450D),
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Belum Ada Riwayat Medical Checkup',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF00450D)),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Semua riwayat medical checkup dari pengguna akan ditampilkan di sini.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
