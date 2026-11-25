import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fe_mobile/services/health_service.dart';
import 'package:fe_mobile/services/extended_service.dart';
import 'package:fe_mobile/model/health_model.dart';
import 'package:fe_mobile/views/user/medical_checkup_form.dart';
import 'package:fe_mobile/widget/custom_dialog.dart';

class HealthPage extends StatefulWidget {
  const HealthPage({super.key});

  @override
  State<HealthPage> createState() => _HealthPageState();
}

class _HealthPageState extends State<HealthPage> {
  bool _isLoading = true;
  MedicalCheckupModel? _latestCheckup;
  List<MedicalCheckupModel> _allCheckups = [];
  List<ExerciseRecommendationModel> _recommendations = [];
  List<Map<String, dynamic>> _workouts = [];
  Map<String, dynamic>? _summary;

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
      final results = await Future.wait([
        HealthService.getCheckups(),
        WorkoutService.getWorkouts(),
        WorkoutService.getSummary(),
      ]);
      final checkups = results[0] as List<MedicalCheckupModel>;
      _allCheckups = checkups;
      _workouts = results[1] as List<Map<String, dynamic>>;
      _summary = results[2] as Map<String, dynamic>?;

      if (checkups.isNotEmpty) {
        _latestCheckup = checkups.first;
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

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
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
                final confirm = await CustomDialog.showConfirm(
                  context: context,
                  title: 'Hapus Data?',
                  message: 'Apakah Anda yakin ingin menghapus data medical checkup terakhir ini?',
                  confirmLabel: 'Hapus',
                  cancelLabel: 'Batal',
                  isDestructive: true,
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

        // Trend Chart + Workout Log & Streak
        _buildTrendChartCard(),
        const SizedBox(height: 20),
        _buildWorkoutLogCard(),
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

  Widget _buildTrendChartCard() {
    final bmiPoints = _allCheckups.reversed
        .where((c) => c.bmi != null)
        .toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE3DDD0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Grafik Tren BMI',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF18181B),
            ),
          ),
          const SizedBox(height: 12),
          if (bmiPoints.length < 2)
            const Text(
              'Catat minimal 2 medical checkup untuk melihat grafik perkembangan BMI.',
              style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            )
          else
            SizedBox(
              height: 160,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true, drawVerticalLine: false),
                  titlesData: const FlTitlesData(
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      color: const Color(0xFF085041),
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      spots: List.generate(
                        bmiPoints.length,
                        (i) => FlSpot(i.toDouble(), bmiPoints[i].bmi!),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWorkoutLogCard() {
    final streak = _summary?['streak'] ?? 0;
    final weeklyMin = _summary?['weekly_minutes'] ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE3DDD0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Aktivitas Olahraga',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF18181B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Streak: $streak hari · $weeklyMin mnt minggu ini',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF085041),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onPressed: _showAddWorkoutDialog,
                icon: const Icon(Icons.add, size: 16, color: Colors.white),
                label: const Text('Catat', style: TextStyle(fontSize: 12, color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_workouts.isEmpty)
            const Text(
              'Belum ada catatan olahraga hari ini.',
              style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            )
          else
            Column(
              children: _workouts.take(4).map((w) {
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.check_circle_outline, color: Color(0xFF085041), size: 20),
                  title: Text(w['title'] ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    '${w['completed_date']} · ${w['category']} · ${w['duration_minutes']} mnt',
                    style: const TextStyle(fontSize: 11),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                    onPressed: () async {
                      await WorkoutService.deleteWorkout(w['id']);
                      _loadHealthData();
                    },
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  void _showAddWorkoutDialog() {
    final titleCtrl = TextEditingController();
    final minCtrl = TextEditingController(text: '30');
    String category = 'cardio';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Catat Olahraga', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nama Aktivitas',
                  hintText: 'Contoh: Jalan cepat pagi',
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: category,
                decoration: const InputDecoration(labelText: 'Kategori'),
                items: const [
                  DropdownMenuItem(value: 'cardio', child: Text('Kardio')),
                  DropdownMenuItem(value: 'strength', child: Text('Latihan Kekuatan')),
                  DropdownMenuItem(value: 'flexibility', child: Text('Peregangan / Yoga')),
                  DropdownMenuItem(value: 'walking', child: Text('Jalan Kaki')),
                ],
                onChanged: (v) => setDialogState(() => category = v ?? 'cardio'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: minCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Durasi (menit)'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF085041)),
              onPressed: () async {
                if (titleCtrl.text.trim().isEmpty) return;
                Navigator.pop(ctx);
                await WorkoutService.createWorkout(
                  title: titleCtrl.text.trim(),
                  category: category,
                  durationMinutes: int.tryParse(minCtrl.text) ?? 30,
                );
                _loadHealthData();
              },
              child: const Text('Simpan', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
