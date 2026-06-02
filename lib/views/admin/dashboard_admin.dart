import 'dart:io';
import 'package:fe_mobile/views/admin/health_admin.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

import 'package:fe_mobile/views/admin/user_admin.dart';
import 'package:fe_mobile/views/admin/community_admin.dart';
import 'package:fe_mobile/widget/custom_bottom_bar_admin.dart';
import 'package:fe_mobile/services/user_service.dart';
import 'package:fe_mobile/services/community_service.dart';
import 'package:fe_mobile/services/post_service.dart';
import 'package:fe_mobile/services/health_service.dart';
import 'package:fe_mobile/services/auth_services.dart';
import 'package:fe_mobile/views/Auth/auth_page.dart';

// Master Shell Navigation Page for Admin
class DashboardAdminPage extends StatefulWidget {
  const DashboardAdminPage({super.key});

  @override
  State<DashboardAdminPage> createState() => _DashboardAdminPageState();
}

class _DashboardAdminPageState extends State<DashboardAdminPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    AdminDashboardContentView(),
    UserManagementPage(),
    HealthAdmin(),
    CommunityManagementPage(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: CustomBottomBarAdmin(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

class AdminDashboardContentView extends StatefulWidget {
  const AdminDashboardContentView({super.key});

  @override
  State<AdminDashboardContentView> createState() => _AdminDashboardContentViewState();
}

class _AdminDashboardContentViewState extends State<AdminDashboardContentView> {
  int _totalUsers = 0;
  int _totalCommunities = 0;
  int _totalPosts = 0;
  int _totalCheckups = 0;
  bool _isLoading = true;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    setState(() => _isLoading = true);
    try {
      final userRes = await UserService.getUsers(limit: 1);
      final commRes = await CommunityService.getCommunities(limit: 1);
      final postRes = await PostService.getPosts(limit: 1);
      final checkups = await HealthService.getCheckups();

      if (mounted) {
        setState(() {
          _totalUsers = userRes['total'] ?? 0;
          _totalCommunities = commRes['total'] ?? 0;
          _totalPosts = postRes['total'] ?? 0;
          _totalCheckups = checkups.length;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _exportPdfReport() async {
    setState(() => _isExporting = true);
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(
                  level: 0,
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('LAPORAN PORTAL GOTOH',
                          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text('Tanggal Dibuat: ${DateTime.now().toLocal().toString().split(".")[0]}'),
                pw.SizedBox(height: 30),
                pw.Text('Ringkasan Data Ekosistem Kesehatan:',
                    style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 12),
                pw.Table.fromTextArray(
                  context: context,
                  headers: ['Parameter Portal', 'Jumlah / Total Aktif'],
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  data: [
                    ['Total Pengguna Terdaftar', '$_totalUsers'],
                    ['Total Komunitas Terbuka', '$_totalCommunities'],
                    ['Total Postingan Member', '$_totalPosts'],
                    ['Total Rekam Medis Checkup', '$_totalCheckups'],
                  ],
                ),
                pw.SizedBox(height: 50),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text('Disahkan Oleh,', style: const pw.TextStyle(fontSize: 12)),
                      pw.SizedBox(height: 60),
                      pw.Text('GOTOH',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    try {
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/laporan_portal_gotoh.pdf');
      await file.writeAsBytes(await pdf.save());
      await OpenFile.open(file.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengekspor PDF: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar dari portal Admin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await AuthService.logout();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const AuthPage()),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBF0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const Icon(Icons.admin_panel_settings_rounded, color: Color(0xFF00450D)),
            const SizedBox(width: 8),
            const Text(
              'GOTOH ADMIN',
              style: TextStyle(
                color: Color(0xFF00450D),
                fontWeight: FontWeight.w900,
                fontSize: 18,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
          actions: [
            IconButton(
              onPressed: _handleLogout,
              icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              tooltip: 'Logout',
            ),
            const SizedBox(width: 8),
          ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchStats,
          color: const Color(0xFF00450D),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00450D), Color(0xFF1B5E20)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00450D).withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ringkasan Performa Sistem',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Selamat datang kembali di dashboard utama GOTOH. Pantau ekosistem secara real-time.',
                        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13, height: 1.4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Statistics Grid
                _isLoading
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: CircularProgressIndicator(color: Color(0xFF00450D)),
                        ),
                      )
                    : GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.4,
                        children: [
                          _buildStatCard(
                            'Total Users',
                            '$_totalUsers',
                            Icons.group_rounded,
                            const Color(0xFFE8F5E9),
                            const Color(0xFF00450D),
                          ),
                          _buildStatCard(
                            'Komunitas',
                            '$_totalCommunities',
                            Icons.diversity_3_rounded,
                            const Color(0xFFE8F5E9),
                            const Color(0xFF00450D),
                          ),
                          _buildStatCard(
                            'Total Postingan',
                            '$_totalPosts',
                            Icons.dynamic_feed_rounded,
                            const Color(0xFFE8F5E9),
                            const Color(0xFF00450D),
                          ),
                          _buildStatCard(
                            'Checkups',
                            '$_totalCheckups',
                            Icons.medical_services_rounded,
                            const Color(0xFFE8F5E9),
                            const Color(0xFF00450D),
                          ),
                        ],
                      ),
                const SizedBox(height: 24),

                // fl_chart bar chart
                const Text(
                  'Statistik Postingan Mingguan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF00450D)),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 220,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE0E4DA)),
                  ),
                  child: _buildBarChart(),
                ),
                const SizedBox(height: 24),

                // Action Card PDF Export
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE0E4DA)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFEBEE),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.picture_as_pdf_rounded, color: Colors.red, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ekspor Laporan PDF',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF181D17)),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Unduh rekapitulasi data portal kesehatan resmi.',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _isExporting ? null : _exportPdfReport,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00450D),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: _isExporting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('Unduh'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 300,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => const Color(0xFF00450D),
            tooltipBorder: const BorderSide(color: Colors.white10),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.toInt()} Post',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
                if (value >= 0 && value < days.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      days[value.toInt()],
                      style: const TextStyle(color: Color(0xFF717A6D), fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  );
                }
                return const SizedBox();
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: [
          _makeBarGroup(0, 120),
          _makeBarGroup(1, 195),
          _makeBarGroup(2, 165),
          _makeBarGroup(3, 255, isHighest: true),
          _makeBarGroup(4, 135),
          _makeBarGroup(5, 210),
          _makeBarGroup(6, 90),
        ],
      ),
    );
  }

  BarChartGroupData _makeBarGroup(int x, double y, {bool isHighest = false}) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: isHighest ? const Color(0xFF00450D) : const Color(0xFF90D689),
          width: 16,
          borderRadius: const BorderRadius.all(Radius.circular(4)),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 300,
            color: const Color(0xFFE8F5E9),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color bgColor,
    Color iconColor,
  ) {
    return Container(
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF181D17)),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

