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
        final recs = await HealthService.getRecommendations(
          bmiCategory: category,
        );
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
      MaterialPageRoute(builder: (context) => const MedicalCheckupFormPage()),
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
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember',
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
        leading: Navigator.canPop(context)
            ? const BackButton(color: Colors.white)
            : null,
        title: const Text(
          'Kesehatan Anda',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF0D631B)),
            )
          : RefreshIndicator(
              onRefresh: _loadHealthData,
              color: const Color(0xFF0D631B),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
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
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F8F4),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE2EFE0)),
          ),
          child: const Icon(
            Icons.favorite_rounded,
            size: 80,
            color: Color(0xFF0D631B),
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'Belum Ada Data Kesehatan',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            color: Color(0xFF1B3C21),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        const Text(
          'Catat medical checkup pertama Anda untuk memantau BMI, kondisi vitalitas, dan mendapatkan rekomendasi latihan olahraga terpersonalisasi.',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF6B8B72),
            fontWeight: FontWeight.w500,
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
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: _navigateToForm,
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: const Text(
              'Mulai Medical Checkup',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
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
                  'ASSESSMENT TERAKHIR',
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF6B8B72),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDateString(checkup.date),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1B3C21),
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.redAccent,
              ),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    title: const Text(
                      'Hapus Data?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B3C21),
                      ),
                    ),
                    content: const Text(
                      'Apakah Anda yakin ingin menghapus data medical checkup terakhir ini?',
                      style: TextStyle(
                        color: Color(0xFF6B8B72),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text(
                          'Batal',
                          style: TextStyle(
                            color: Color(0xFF6B8B72),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        child: const Text(
                          'Hapus',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
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
        const SizedBox(height: 18),

        // Score Card (BMI Gauge design)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE2EFE0)),
          ),
          child: Column(
            children: [
              const Text(
                'Indeks Massa Tubuh (BMI)',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B8B72),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                bmiVal != null ? bmiVal.toStringAsFixed(1) : '-',
                style: TextStyle(
                  fontSize: 54,
                  fontWeight: FontWeight.w900,
                  color: catColor,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: catColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: catColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  checkup.bmiCategory.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
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
                icon: Icons.height_rounded,
                color: Colors.teal,
                bgColor: const Color(0xFFE0F2F1),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                title: 'Berat Badan',
                value: checkup.weight != null ? '${checkup.weight} kg' : '-',
                icon: Icons.monitor_weight_outlined,
                color: Colors.blueAccent,
                bgColor: const Color(0xFFE3F2FD),
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
                bgColor: const Color(0xFFFFEBEE),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                title: 'Detak Jantung',
                value: checkup.heartRate != null
                    ? '${checkup.heartRate} bpm'
                    : '-',
                icon: Icons.favorite_border_rounded,
                color: Colors.pink,
                bgColor: const Color(0xFFFCE4EC),
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
                value: checkup.bloodSugar != null
                    ? '${checkup.bloodSugar} mg/dL'
                    : '-',
                icon: Icons.bloodtype_rounded,
                color: Colors.orange,
                bgColor: const Color(0xFFFFF3E0),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                title: 'Kolesterol',
                value: checkup.cholesterol != null
                    ? '${checkup.cholesterol} mg/dL'
                    : '-',
                icon: Icons.health_and_safety_rounded,
                color: Colors.purple,
                bgColor: const Color(0xFFF3E5F5),
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
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2EFE0)),
                ),
                child: const Text(
                  'Memuat rekomendasi...',
                  style: TextStyle(
                    color: Color(0xFF6B8B72),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            : Column(
                children: _recommendations
                    .map((rec) => _buildRecommendationCard(rec))
                    .toList(),
              ),

        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D631B),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: _navigateToForm,
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: const Text(
              'Input Assessment Baru',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
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
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: Color(0xFF1B3C21),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2EFE0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B8B72),
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1B3C21),
              letterSpacing: -0.2,
            ),
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2EFE0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 10,
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
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F5E9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.fitness_center_rounded,
                      color: Color(0xFF0D631B),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Program Latihan',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0D631B),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  '${rec.duration} mnt',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0D631B),
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: Color(0xFFE2EFE0)),
          Text(
            rec.recommendation,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF5A7561),
              height: 1.55,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
