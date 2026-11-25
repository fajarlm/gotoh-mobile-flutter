import 'package:flutter/material.dart';
import 'package:fe_mobile/services/extended_service.dart';

class ChallengesPage extends StatefulWidget {
  const ChallengesPage({super.key});

  @override
  State<ChallengesPage> createState() => _ChallengesPageState();
}

class _ChallengesPageState extends State<ChallengesPage>
    with SingleTickerProviderStateMixin {
  static const _primaryGreen = Color(0xFF085041);
  static const _bgColor = Color(0xFFF7F4EC);
  static const _borderColor = Color(0xFFE3DDD0);

  late TabController _tabController;
  bool _loading = true;
  List<Map<String, dynamic>> _challenges = [];
  List<Map<String, dynamic>> _articles = [];
  String _articleCategory = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final results = await Future.wait([
      ChallengeService.getChallenges(),
      ArticleService.getArticles(category: _articleCategory),
    ]);
    if (!mounted) return;
    setState(() {
      _challenges = results[0];
      _articles = results[1];
      _loading = false;
    });
  }

  void _showCreateChallengeDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final daysCtrl = TextEditingController(text: '7');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFCFBF7),
        title: const Text('Buat Tantangan Baru',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Judul Tantangan',
                  hintText: 'Contoh: 7 Hari Jalan 5.000 Langkah',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi Singkat',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: daysCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Target Hari',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _primaryGreen),
            onPressed: () async {
              if (titleCtrl.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              await ChallengeService.createChallenge(
                title: titleCtrl.text.trim(),
                description: descCtrl.text.trim(),
                targetDays: int.tryParse(daysCtrl.text) ?? 7,
              );
              _loadData();
            },
            child: const Text('Buat', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showArticleDetail(Map<String, dynamic> art) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFFCFBF7),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        maxChildSize: 0.92,
        builder: (_, scrollCtrl) => SingleChildScrollView(
          controller: scrollCtrl,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${(art['category'] ?? 'umum').toString().toUpperCase()} · ${art['read_time'] ?? 3} MNT BACA',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _primaryGreen,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                art['title'] ?? '',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF18181B),
                ),
              ),
              const Divider(height: 24, color: _borderColor),
              Text(
                art['content'] ?? '',
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: Color(0xFF374151),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCFBF7),
        elevation: 0,
        foregroundColor: const Color(0xFF18181B),
        title: const Text(
          'Tantangan & Edukasi',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: _primaryGreen,
          unselectedLabelColor: const Color(0xFF6B7280),
          indicatorColor: _primaryGreen,
          tabs: const [
            Tab(icon: Icon(Icons.emoji_events_outlined), text: 'Tantangan'),
            Tab(icon: Icon(Icons.menu_book_outlined), text: 'Artikel'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _primaryGreen,
        onPressed: _showCreateChallengeDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _primaryGreen))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildChallengesTab(),
                _buildArticlesTab(),
              ],
            ),
    );
  }

  Widget _buildChallengesTab() {
    if (_challenges.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada tantangan aktif.\nTap tombol + untuk membuat tantangan baru.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF6B7280)),
        ),
      );
    }

    final today = DateTime.now().toIso8601String().split('T')[0];

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _challenges.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, idx) {
          final c = _challenges[idx];
          final myPart = c['my_participation'];
          final targetDays = (c['target_days'] ?? 7) as int;
          final myProg = (myPart?['progress'] ?? 0) as int;
          final pct = (myProg / (targetDays > 0 ? targetDays : 1)).clamp(0.0, 1.0);
          final checkedToday = myPart?['last_checkin_date'] == today;

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      c['Community']?['name'] ?? 'Tantangan Terbuka',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _primaryGreen,
                      ),
                    ),
                    Text(
                      '${c['participants_count'] ?? 0} peserta',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  c['title'] ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF18181B),
                  ),
                ),
                if ((c['description'] ?? '').toString().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    c['description'],
                    style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563)),
                  ),
                ],
                if (myPart != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Progress Anda', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                      Text(
                        '$myProg / $targetDays ${c['unit'] ?? 'hari'}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: pct,
                    backgroundColor: const Color(0xFFEFECE3),
                    color: _primaryGreen,
                    minHeight: 7,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: myPart == null
                      ? ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: _primaryGreen),
                          onPressed: () async {
                            await ChallengeService.joinChallenge(c['id']);
                            _loadData();
                          },
                          child: const Text('Gabung', style: TextStyle(color: Colors.white)),
                        )
                      : ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: checkedToday || myProg >= targetDays
                                ? Colors.grey.shade400
                                : _primaryGreen,
                          ),
                          onPressed: (checkedToday || myProg >= targetDays)
                              ? null
                              : () async {
                                  final res = await ChallengeService.checkinChallenge(c['id']);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(res['message'] ?? 'Check-in selesai')),
                                    );
                                  }
                                  _loadData();
                                },
                          icon: const Icon(Icons.check, size: 16, color: Colors.white),
                          label: Text(
                            myProg >= targetDays
                                ? 'Selesai'
                                : checkedToday
                                    ? 'Sudah Check-in'
                                    : 'Check-in Hari Ini',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildArticlesTab() {
    final cats = ['all', 'nutrisi', 'olahraga', 'medis', 'mental', 'umum'];
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: cats.map((cat) {
              final selected = _articleCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(cat == 'all' ? 'Semua' : cat.toUpperCase()),
                  selected: selected,
                  selectedColor: _primaryGreen,
                  labelStyle: TextStyle(
                    fontSize: 11,
                    color: selected ? Colors.white : const Color(0xFF374151),
                  ),
                  onSelected: (_) {
                    setState(() => _articleCategory = cat);
                    _loadData();
                  },
                ),
              );
            }).toList(),
          ),
        ),
        Expanded(
          child: _articles.isEmpty
              ? const Center(
                  child: Text('Belum ada artikel edukasi.',
                      style: TextStyle(color: Color(0xFF6B7280))),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _articles.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, idx) {
                    final art = _articles[idx];
                    return InkWell(
                      onTap: () => _showArticleDetail(art),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _borderColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${(art['category'] ?? 'umum').toString().toUpperCase()} · ${art['read_time'] ?? 3} MNT BACA',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _primaryGreen,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              art['title'] ?? '',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF18181B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              art['summary'] ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
