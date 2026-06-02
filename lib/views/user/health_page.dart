import 'package:flutter/material.dart';
import 'package:fe_mobile/services/health_service.dart';
import 'package:fe_mobile/model/health_model.dart';
import 'package:fe_mobile/views/user/medical_checkup_form.dart';

class HealthPage extends StatefulWidget {
  const HealthPage({super.key});

  @override
  State<HealthPage> createState() => _HealthPageState();
}

class _HealthPageState extends State<HealthPage> {
  bool _isLoading = true;
  MedicalCheckupModel? _latestCheckup;
  List<ExerciseRecommendationModel> _recommendations = [];

  @override
  void initState() {
    super.initState();
    _loadHealthData();
  }

  Future<void> _loadHealthData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Dapatkan daftar checkup (terbaru pertama)
      final checkups = await HealthService.getCheckups();
      if (checkups.isNotEmpty) {
        _latestCheckup = checkups.first;
        
        // 2. Dapatkan rekomendasi latihan berdasarkan kategori BMI terbaru
        final category = _latestCheckup!.bmiCategory;
        final recs = await HealthService.getRecommendations(bmiCategory: category);
        _recommendations = recs;
      } else {
        _latestCheckup = null;
        _recommendations = [];
      }
    } catch (e) {
      print("Error loading health data: $e");
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _navigateToForm() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MedicalCheckupFormPage(),
      ),
    );

    if (result == true) {
      _loadHealthData();
    }
  }

  String _formatDateString(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final dt = DateTime.parse(dateStr);
      final months = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return dateStr;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Normal':
        return const Color(0xFF0D631B);
      case 'Underweight':
        return Colors.blue;
      case 'Overweight':
        return Colors.orange;
      case 'Obese':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBF0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D631B),
        elevation: 0,
        leading: Navigator.canPop(context) ? const BackButton(color: Colors.white) : null,
        title: const Text(
          'Kesehatan Anda',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0D631B)))
          : RefreshIndicator(
              onRefresh: _loadHealthData,
              color: const Color(0xFF0D631B),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: _latestCheckup == null
                    ? _buildEmptyState()
                    : _buildDashboardState(),
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 60),
        Container(
          padding: const EdgeInsets.all(32),
          decoration: const BoxDecoration(
            color: Color(0xFFE8F5E9),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.favorite_rounded,
            size: 100,
            color: Color(0xFF0D631B),
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'Belum Ada Data Kesehatan',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF181D17),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        const Text(
          'Catat medical checkup pertama Anda untuk memantau BMI, kondisi vitalitas, dan mendapatkan rekomendasi latihan olahraga terpersonalisasi.',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF40493D),
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D631B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _navigateToForm,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Mulai Medical Checkup',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardState() {
    final checkup = _latestCheckup!;
    final catColor = _getCategoryColor(checkup.bmiCategory);
    final bmiVal = checkup.bmi;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date / Assessment header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Assessment Terakhir',
                  style: TextStyle(fontSize: 12, color: Color(0xFF40493D), fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDateString(checkup.date),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF181D17)),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Hapus Data?'),
                    content: const Text('Apakah Anda yakin ingin menghapus data medical checkup terakhir ini?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Hapus', style: TextStyle(color: Colors.redAccent)),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  final ok = await HealthService.deleteCheckup(checkup.id);
                  if (ok) {
                    _loadHealthData();
                  }
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Score Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE0E4DA)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              const Text(
                'Indeks Massa Tubuh (BMI)',
                style: TextStyle(fontSize: 13, color: Color(0xFF40493D), fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              Text(
                bmiVal != null ? bmiVal.toStringAsFixed(1) : '-',
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: catColor),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: catColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  checkup.bmiCategory.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: catColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Physical details
        _buildSectionTitle('Detail Fisik'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Tinggi Badan',
                value: checkup.height != null ? '${checkup.height} cm' : '-',
                icon: Icons.height,
                color: Colors.teal,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                title: 'Berat Badan',
                value: checkup.weight != null ? '${checkup.weight} kg' : '-',
                icon: Icons.monitor_weight_outlined,
                color: Colors.blueAccent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Vital details
        _buildSectionTitle('Kondisi Vital'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Tekanan Darah',
                value: checkup.bloodPressure ?? '-',
                icon: Icons.speed_rounded,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                title: 'Detak Jantung',
                value: checkup.heartRate != null ? '${checkup.heartRate} bpm' : '-',
                icon: Icons.favorite_border_rounded,
                color: Colors.pink,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Laboratory details
        _buildSectionTitle('Hasil Laboratorium'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Gula Darah',
                value: checkup.bloodSugar != null ? '${checkup.bloodSugar} mg/dL' : '-',
                icon: Icons.bloodtype,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                title: 'Kolesterol',
                value: checkup.cholesterol != null ? '${checkup.cholesterol} mg/dL' : '-',
                icon: Icons.health_and_safety,
                color: Colors.purple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),

        // Exercise recommendations
        _buildSectionTitle('Rekomendasi Latihan Anda'),
        const SizedBox(height: 12),
        _recommendations.isEmpty
            ? Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5EB),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Memuat rekomendasi...',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              )
            : Column(
                children: _recommendations.map((rec) => _buildRecommendationCard(rec)).toList(),
              ),

        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D631B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _navigateToForm,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Input Assessment Baru',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF181D17),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E4DA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF40493D), fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF181D17)),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(ExerciseRecommendationModel rec) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E4DA)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.fitness_center_rounded, color: Color(0xFF0D631B), size: 22),
                  SizedBox(width: 8),
                  Text(
                    'Program Latihan',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0D631B)),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Durasi: ${rec.duration} menit',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D631B),
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: Color(0xFFE0E4DA)),
          Text(
            rec.recommendation,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF40493D),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}