import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Step 1 of 6 – Informasi Pribadi (Usia, Jenis Kelamin, BB, TB)
/// Dipanggil dari MedicalCheckupFormPage sebagai alternatif flow multi-step.
class MedicalCheckup1 extends StatefulWidget {
  final Map<String, dynamic> formData;
  final VoidCallback onNext;

  const MedicalCheckup1({
    super.key,
    required this.formData,
    required this.onNext,
  });

  @override
  State<MedicalCheckup1> createState() => _MedicalCheckup1State();
}

class _MedicalCheckup1State extends State<MedicalCheckup1> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _ageCtrl;
  late final TextEditingController _weightCtrl;
  late final TextEditingController _heightCtrl;

  String? _selectedGender;

  static const _primaryGreen = Color(0xFF0D631B);
  static const _cardColor = Colors.white;
  static const _borderColor = Color(0xFFE0E4DA);
  static const _labelColor = Color(0xFF40493D);
  static const _titleColor = Color(0xFF181D17);

  @override
  void initState() {
    super.initState();
    final d = widget.formData;
    _ageCtrl = TextEditingController(text: d['age']?.toString() ?? '');
    _weightCtrl = TextEditingController(text: d['weight']?.toString() ?? '');
    _heightCtrl = TextEditingController(text: d['height']?.toString() ?? '');
    _selectedGender = d['gender'] as String?;
  }

  @override
  void dispose() {
    _ageCtrl.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    super.dispose();
  }

  void _onNext() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih jenis kelamin terlebih dahulu'),
          backgroundColor: Color(0xFFBA1A1A),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    widget.formData['age'] = int.tryParse(_ageCtrl.text);
    widget.formData['weight'] = double.tryParse(_weightCtrl.text);
    widget.formData['height'] = double.tryParse(_heightCtrl.text);
    widget.formData['gender'] = _selectedGender;
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Progress Header ──────────────────────────────────────────────────
        _ProgressCard(step: 1, totalSteps: 6, percent: 0.15),
        const SizedBox(height: 24),

        // ── Section Title ────────────────────────────────────────────────────
        const Text(
          'Informasi Pribadi',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: _titleColor,
            letterSpacing: -0.24,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Bantu kami mengenal Anda lebih baik untuk memberikan analisis kesehatan yang akurat.',
          style: TextStyle(fontSize: 14, color: _labelColor, height: 1.5),
        ),
        const SizedBox(height: 24),

        // ── Form ─────────────────────────────────────────────────────────────
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Usia
              _buildInputCard(
                label: 'Usia (Tahun)',
                child: _buildNumberField(
                  controller: _ageCtrl,
                  hint: 'Contoh: 25',
                  unit: 'thn',
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Usia harus diisi';
                    final n = int.tryParse(v);
                    if (n == null || n < 1 || n > 120) return 'Usia tidak valid';
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Jenis Kelamin
              _buildInputCard(
                label: 'Jenis Kelamin',
                child: Row(
                  children: [
                    Expanded(
                      child: _GenderChip(
                        label: 'Laki-laki',
                        icon: Icons.male_rounded,
                        selected: _selectedGender == 'male',
                        onTap: () => setState(() => _selectedGender = 'male'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _GenderChip(
                        label: 'Perempuan',
                        icon: Icons.female_rounded,
                        selected: _selectedGender == 'female',
                        onTap: () => setState(() => _selectedGender = 'female'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Berat Badan
              _buildInputCard(
                label: 'Berat Badan',
                child: _buildNumberField(
                  controller: _weightCtrl,
                  hint: 'Contoh: 65',
                  unit: 'kg',
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Berat badan harus diisi';
                    final n = double.tryParse(v);
                    if (n == null || n < 1 || n > 500) return 'Nilai tidak valid';
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Tinggi Badan
              _buildInputCard(
                label: 'Tinggi Badan',
                child: _buildNumberField(
                  controller: _heightCtrl,
                  hint: 'Contoh: 170',
                  unit: 'cm',
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Tinggi badan harus diisi';
                    final n = double.tryParse(v);
                    if (n == null || n < 50 || n > 300) return 'Nilai tidak valid';
                    return null;
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // ── Info Box ─────────────────────────────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0x4CC9E8CA),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0x33C9E8CA)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline_rounded, color: _primaryGreen, size: 22),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Mengapa data ini penting?\n\nInformasi fisik dasar membantu algoritma kami menghitung BMI dan memetakan standar kesehatan yang sesuai dengan profil demografis Anda.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF4E6952), height: 1.5),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // ── Next Button ──────────────────────────────────────────────────────
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _onNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 4,
              shadowColor: _primaryGreen.withValues(alpha: 0.3),
            ),
            child: const Text(
              'Lanjut',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // ── Privacy Note ─────────────────────────────────────────────────────
        const Center(
          child: Text(
            'Data Anda terenkripsi aman sesuai standar privasi kesehatan.',
            style: TextStyle(fontSize: 11, color: Color(0xFF8FA89A)),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildInputCard({required String label, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _labelColor,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String hint,
    required String unit,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 15),
        suffixText: unit,
        suffixStyle: const TextStyle(
          color: _labelColor,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: const Color(0xFFF1F5EB),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _primaryGreen, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFBA1A1A)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFBA1A1A), width: 1.5),
        ),
      ),
    );
  }
}

// ── Subwidgets ──────────────────────────────────────────────────────────────

class _GenderChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _GenderChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF0D631B);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? primary : const Color(0xFFF1F5EB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? primary : const Color(0xFFE0E4DA),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: selected ? Colors.white : const Color(0xFF40493D)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : const Color(0xFF40493D),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final int step;
  final int totalSteps;
  final double percent;

  const _ProgressCard({
    required this.step,
    required this.totalSteps,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF0D631B);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
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
              Text(
                'Langkah $step dari $totalSteps',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF40493D),
                ),
              ),
              Text(
                '${(percent * 100).round()}% Selesai',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(9999),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 8,
              backgroundColor: const Color(0xFFC9E8CA),
              valueColor: const AlwaysStoppedAnimation<Color>(primary),
            ),
          ),
        ],
      ),
    );
  }
}