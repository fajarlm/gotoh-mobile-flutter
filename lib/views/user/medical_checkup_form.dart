import 'package:flutter/material.dart';
import 'package:fe_mobile/services/health_service.dart';

class MedicalCheckupFormPage extends StatefulWidget {
  const MedicalCheckupFormPage({super.key});

  @override
  State<MedicalCheckupFormPage> createState() => _MedicalCheckupFormPageState();
}

class _MedicalCheckupFormPageState extends State<MedicalCheckupFormPage> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _heartRateController = TextEditingController();
  final TextEditingController _bpController = TextEditingController();
  final TextEditingController _sugarController = TextEditingController();
  final TextEditingController _cholesterolController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  bool _isSubmitting = false;

  String _formatDate(DateTime date) {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatIsoDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _heartRateController.dispose();
    _bpController.dispose();
    _sugarController.dispose();
    _cholesterolController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0D631B),
              onPrimary: Colors.white,
              onSurface: Color(0xFF181D17),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    final weight = double.tryParse(_weightController.text);
    final height = double.tryParse(_heightController.text);
    final heartRate = int.tryParse(_heartRateController.text);
    final bp = _bpController.text.trim();
    final sugar = double.tryParse(_sugarController.text);
    final cholesterol = double.tryParse(_cholesterolController.text);
    final formattedDate = _formatIsoDate(_selectedDate);

    // 1. Simpan checkup medis
    final res = await HealthService.createCheckup(
      date: formattedDate,
      bloodPressure: bp.isEmpty ? null : bp,
      heartRate: heartRate,
      bloodSugar: sugar,
      cholesterol: cholesterol,
      weight: weight,
      height: height,
    );

    if (res['success'] == true) {
      final checkup = res['data'];
      final String bmiCategory = checkup.bmiCategory;

      // 2. Buat rekomendasi latihan otomatis berdasarkan kategori BMI
      await HealthService.createRecommendation(bmiCategory: bmiCategory);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medical checkup berhasil disimpan!')),
        );
        Navigator.pop(context, true); // Pop back to Health Page and trigger refresh
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Gagal menyimpan checkup')),
        );
      }
    }

    setState(() {
      _isSubmitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBF0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D631B),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Input Medical Checkup',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Catat Kesehatan Anda',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF181D17),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Masukkan parameter vital dan laboratorium Anda untuk mendapatkan analisis kesehatan serta rekomendasi olahraga dari sistem.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF40493D),
                  ),
                ),
                const SizedBox(height: 24),

                // Date Picker Input
                InkWell(
                  onTap: () => _selectDate(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE0E4DA)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, color: Color(0xFF0D631B), size: 20),
                            const SizedBox(width: 12),
                            Text(
                              'Tanggal: ${_formatDate(_selectedDate)}',
                              style: const TextStyle(fontSize: 15, color: Color(0xFF181D17)),
                            ),
                          ],
                        ),
                        const Icon(Icons.arrow_drop_down, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Physical Parameters Card
                _buildSectionCard(
                  title: 'Parameter Fisik',
                  icon: Icons.accessibility,
                  children: [
                    _buildTextField(
                      controller: _heightController,
                      label: 'Tinggi Badan (cm)',
                      hint: 'Contoh: 170',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Tinggi badan harus diisi';
                        if (double.tryParse(value) == null) return 'Nilai tidak valid';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _weightController,
                      label: 'Berat Badan (kg)',
                      hint: 'Contoh: 65',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Berat badan harus diisi';
                        if (double.tryParse(value) == null) return 'Nilai tidak valid';
                        return null;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Vitals Parameters Card
                _buildSectionCard(
                  title: 'Parameter Vital',
                  icon: Icons.favorite,
                  children: [
                    _buildTextField(
                      controller: _bpController,
                      label: 'Tekanan Darah (mmHg)',
                      hint: 'Contoh: 120/80',
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Tekanan darah harus diisi';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _heartRateController,
                      label: 'Detak Jantung (BPM)',
                      hint: 'Contoh: 75',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Detak jantung harus diisi';
                        if (int.tryParse(value) == null) return 'Nilai tidak valid';
                        return null;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Laboratory Parameters Card
                _buildSectionCard(
                  title: 'Hasil Laboratorium',
                  icon: Icons.science,
                  children: [
                    _buildTextField(
                      controller: _sugarController,
                      label: 'Gula Darah (mg/dL)',
                      hint: 'Contoh: 95',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Gula darah harus diisi';
                        if (double.tryParse(value) == null) return 'Nilai tidak valid';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _cholesterolController,
                      label: 'Kolesterol (mg/dL)',
                      hint: 'Contoh: 180',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Kolesterol harus diisi';
                        if (double.tryParse(value) == null) return 'Nilai tidak valid';
                        return null;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Save Button
                _isSubmitting
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF0D631B)))
                    : SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0D631B),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _submitForm,
                          child: const Text(
                            'Simpan & Analisis',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF0D631B), size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D631B),
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: Color(0xFFE0E4DA)),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required TextInputType keyboardType,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF40493D)),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF0D631B), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE0E4DA)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
