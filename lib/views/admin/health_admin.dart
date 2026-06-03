import 'package:flutter/material.dart';
import 'package:fe_mobile/model/health_model.dart';
import 'package:fe_mobile/services/health_service.dart';

class HealthAdmin extends StatefulWidget {
  const HealthAdmin({super.key});

  @override
  State<HealthAdmin> createState() => _HealthAdminState();
}

class _HealthAdminState extends State<HealthAdmin> {
  List<MedicalCheckupModel> _allCheckups = [];
  List<MedicalCheckupModel> _filteredCheckups = [];
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchCheckups();
  }

  Future<void> _fetchCheckups() async {
    setState(() => _isLoading = true);
    try {
      final list = await HealthService.getCheckups();
      if (mounted) {
        setState(() {
          _allCheckups = list;
          _filterList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _filterList() {
    if (_searchQuery.isEmpty) {
      _filteredCheckups = _allCheckups;
    } else {
      _filteredCheckups = _allCheckups.where((mc) {
        final username = mc.user?.username.toLowerCase() ?? '';
        return username.contains(_searchQuery.toLowerCase());
      }).toList();
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _filterList();
    });
  }

  Future<void> _onDeleteCheckup(MedicalCheckupModel checkup) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Rekam Medis'),
        content: Text(
          'Apakah Anda yakin ingin menghapus rekam medis user "${checkup.user?.username ?? 'User ID: ${checkup.userId}'}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      final success = await HealthService.deleteCheckup(checkup.id);
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Rekam medis berhasil dihapus')),
          );
        }
        _fetchCheckups();
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal menghapus rekam medis')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBF0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Kelola Medical Checkup',
          style: TextStyle(
            color: Color(0xFF00450D),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchCheckups,
          color: const Color(0xFF00450D),
          child: Column(
            children: [
              // Search Input Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFC0C9BB)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: _onSearchChanged,
                    decoration: const InputDecoration(
                      hintText: 'Cari berdasarkan nama user...',
                      prefixIcon: Icon(
                        Icons.search,
                        color: Color(0xFF717A6D),
                        size: 20,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),

              // Checkups List
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF00450D),
                        ),
                      )
                    : _filteredCheckups.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(height: 100),
                          Center(
                            child: Text(
                              'Tidak ada rekam medis ditemukan',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredCheckups.length,
                        itemBuilder: (context, index) {
                          final mc = _filteredCheckups[index];
                          final formattedDate = mc.createdAt != null
                              ? mc.createdAt!.toLocal().toString().split(' ')[0]
                              : (mc.date ?? '-');

                          return Card(
                            elevation: 1,
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: const BorderSide(color: Color(0xFFE0E4DA)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header Card (User name and Delete)
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: const Color(
                                              0xFFE8F5E9,
                                            ),
                                            child: Text(
                                              mc.user?.initials ?? '?',
                                              style: const TextStyle(
                                                color: Color(0xFF00450D),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                mc.user?.username ??
                                                    'User ID: ${mc.userId}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                  color: Color(0xFF181D17),
                                                ),
                                              ),
                                              Text(
                                                'Tanggal: $formattedDate',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.redAccent,
                                        ),
                                        onPressed: () => _onDeleteCheckup(mc),
                                      ),
                                    ],
                                  ),
                                  const Divider(
                                    height: 24,
                                    color: Color(0xFFE0E4DA),
                                  ),

                                  // Parameters Grid
                                  GridView(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          childAspectRatio: 2.8,
                                          crossAxisSpacing: 12,
                                          mainAxisSpacing: 8,
                                        ),
                                    children: [
                                      _buildParamItem(
                                        'Berat Badan',
                                        '${mc.weight ?? "-"} kg',
                                        Icons.scale,
                                      ),
                                      _buildParamItem(
                                        'Tinggi Badan',
                                        '${mc.height ?? "-"} cm',
                                        Icons.height,
                                      ),
                                      _buildParamItem(
                                        'Tekanan Darah',
                                        mc.bloodPressure ?? '-',
                                        Icons.bloodtype,
                                      ),
                                      _buildParamItem(
                                        'Detak Jantung',
                                        mc.heartRate != null
                                            ? '${mc.heartRate} bpm'
                                            : '-',
                                        Icons.favorite,
                                      ),
                                      _buildParamItem(
                                        'Gula Darah',
                                        mc.bloodSugar != null
                                            ? '${mc.bloodSugar} mg/dL'
                                            : '-',
                                        Icons.water_drop,
                                      ),
                                      _buildParamItem(
                                        'Kolesterol',
                                        mc.cholesterol != null
                                            ? '${mc.cholesterol} mg/dL'
                                            : '-',
                                        Icons.health_and_safety,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // BMI Category Banner
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE8F5E9),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Kategori BMI: ${mc.bmiCategory}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF00450D),
                                            fontSize: 13,
                                          ),
                                        ),
                                        Text(
                                          'Skor: ${mc.bmi != null ? mc.bmi!.toStringAsFixed(1) : "-"}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF2E7D32),
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParamItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF00450D)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF181D17),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
