import 'package:flutter/material.dart';

/// Step 2 of 6 – Kebiasaan Makan
/// Dipanggil dari alur multi-step medical checkup.
class MedicalCheckup2 extends StatefulWidget {
  final Map<String, dynamic> formData;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const MedicalCheckup2({
    super.key,
    required this.formData,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<MedicalCheckup2> createState() => _MedicalCheckup2State();
}

class _MedicalCheckup2State extends State<MedicalCheckup2> {
  String? _mealsPerDay;
  String? _fastFoodFreq;
  String? _sweetDrinks;

  static const _primaryGreen = Color(0xFF0D631B);
  static const _labelColor = Color(0xFF6B8B72);
  static const _titleColor = Color(0xFF1B3C21);
  static const _borderColor = Color(0xFFE2EFE0);

  @override
  void initState() {
    super.initState();
    final d = widget.formData;
    _mealsPerDay = d['mealsPerDay'] as String?;
    _fastFoodFreq = d['fastFoodFreq'] as String?;
    _sweetDrinks = d['sweetDrinks'] as String?;
  }

  void _onNext() {
    if (_mealsPerDay == null || _fastFoodFreq == null || _sweetDrinks == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap jawab semua pertanyaan'),
          backgroundColor: Color(0xFFBA1A1A),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    widget.formData['mealsPerDay'] = _mealsPerDay;
    widget.formData['fastFoodFreq'] = _fastFoodFreq;
    widget.formData['sweetDrinks'] = _sweetDrinks;
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Progress Header ──────────────────────────────────────────────────
        _ProgressCard(step: 2, totalSteps: 6, percent: 2 / 6),
        const SizedBox(height: 24),

        // ── Section Title ────────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Kebiasaan Makan',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: _titleColor,
                letterSpacing: -0.24,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F8F4),
                borderRadius: BorderRadius.circular(9999),
                border: Border.all(color: _borderColor),
              ),
              child: const Text(
                'Langkah 2 dari 6',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _labelColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // ── Pertanyaan 1 ─────────────────────────────────────────────────────
        _buildQuestion(
          number: '1',
          question: 'Berapa kali Anda makan dalam sehari?',
          options: const [
            'Sekali',
            'Dua kali',
            'Tiga kali',
            'Lebih dari tiga kali',
          ],
          selected: _mealsPerDay,
          onSelect: (v) => setState(() => _mealsPerDay = v),
          isRadio: false,
        ),
        const SizedBox(height: 28),

        // ── Pertanyaan 2 ─────────────────────────────────────────────────────
        _buildQuestion(
          number: '2',
          question: 'Seberapa sering Anda makan makanan cepat saji?',
          options: const [
            'Tidak pernah',
            '1–2 kali/minggu',
            '3–5 kali/minggu',
            'Hampir setiap hari',
          ],
          selected: _fastFoodFreq,
          onSelect: (v) => setState(() => _fastFoodFreq = v),
          isRadio: true,
        ),
        const SizedBox(height: 28),

        // ── Pertanyaan 3 ─────────────────────────────────────────────────────
        _buildQuestion(
          number: '3',
          question: 'Apakah Anda mengonsumsi minuman manis?',
          options: const [
            'Tidak pernah',
            'Kadang-kadang',
            'Sering',
            'Setiap hari',
          ],
          selected: _sweetDrinks,
          onSelect: (v) => setState(() => _sweetDrinks = v),
          isRadio: true,
        ),
        const SizedBox(height: 36),

        // ── Navigation Buttons ───────────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: widget.onBack,
                style: OutlinedButton.styleFrom(
                  foregroundColor: _primaryGreen,
                  side: const BorderSide(color: _primaryGreen, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                ),
                child: const Text(
                  'Kembali',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                ),
                child: const Text(
                  'Lanjut',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Center(
          child: Text(
            'Data Anda terenkripsi aman sesuai standar privasi kesehatan.',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF8FA89A),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestion({
    required String number,
    required String question,
    required List<String> options,
    required String? selected,
    required ValueChanged<String> onSelect,
    required bool isRadio,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _primaryGreen,
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Center(
                child: Text(
                  number,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                question,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w850,
                  color: _titleColor,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (isRadio)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F8F4),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _borderColor),
            ),
            child: Column(
              children: options.map((opt) {
                final isSelected = selected == opt;
                return GestureDetector(
                  onTap: () => onSelect(opt),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? _primaryGreen : _borderColor,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? _primaryGreen : Colors.white,
                            border: Border.all(
                              color: isSelected
                                  ? _primaryGreen
                                  : const Color(0xFFBFCABA),
                            ),
                          ),
                          child: isSelected
                              ? const Center(
                                  child: Icon(
                                    Icons.check,
                                    size: 13,
                                    color: Colors.white,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 14),
                        Text(
                          opt,
                          style: TextStyle(
                            fontSize: 15,
                            color: _titleColor,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          )
        else
          Column(
            children: options.map((opt) {
              final isSelected = selected == opt;
              return GestureDetector(
                onTap: () => onSelect(opt),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFE8F5E9) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? _primaryGreen : _borderColor,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Text(
                    opt,
                    style: TextStyle(
                      fontSize: 15,
                      color: _titleColor,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}

// ── Shared Progress Card ────────────────────────────────────────────────────

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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2EFE0)),
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
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B8B72),
                ),
              ),
              Text(
                '${(percent * 100).round()}% Selesai',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
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
              backgroundColor: const Color(0xFFE2EFE0),
              valueColor: const AlwaysStoppedAnimation<Color>(primary),
            ),
          ),
        ],
      ),
    );
  }
}
