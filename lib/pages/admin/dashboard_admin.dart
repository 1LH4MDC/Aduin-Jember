import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../services/auth_service.dart';
import '../../services/gawat_service.dart';
import '../../services/sambat_service.dart';
import '../../services/woro_service.dart';
import '../auth/login_page.dart'; // Import untuk fungsi logout
import 'profile_admin_page.dart'; // Import untuk halaman profil admin
import 'users_admin.dart';

class DashboardAdmin extends StatefulWidget {
  final ValueChanged<int>? onNavigateToTab;

  const DashboardAdmin({super.key, this.onNavigateToTab});

  @override
  State<DashboardAdmin> createState() => _DashboardAdminState();
}

class _DashboardAdminState extends State<DashboardAdmin> {
  bool _isLoading = true;
  String? _errorMessage;

  List<Map<String, dynamic>> _sambatList = [];
  List<Map<String, dynamic>> _woroList = [];
  List<Map<String, dynamic>> _gawatList = [];
  int _totalUsersCount = 0;
  int _emergencyCount = 0;
  int _selectedSambatChartTab = 0; // 0: Kategori, 1: Status
  int _selectedGawatChartTab = 0;  // 0: Jenis, 1: Status

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final auth = context.read<AuthController>();
      final sambatService = SambatService(apiClient: auth.apiClient);
      final woroService = WoroService(apiClient: auth.apiClient);
      final gawatService = GawatService(apiClient: auth.apiClient);

      // Fetch all data in parallel
      final results = await Future.wait([
        sambatService.fetchAllSambat(),
        woroService.fetchWoro(),
        gawatService.fetchGawat(),
      ]);

      final sambats = results[0];
      final woros = results[1];
      final gawats = results[2];

      // Extract unique users from sambat list
      final uniqueUsers = <String>{};
      for (final s in sambats) {
        final userId = s['idUser'] ?? s['user_id'] ?? s['iduser'] ?? s['userId'];
        final userEmail = s['emailUser'] ?? s['author_email'] ?? s['email'] ?? '';
        final identifier = userId?.toString() ?? userEmail.toString();
        if (identifier.trim().isNotEmpty) {
          uniqueUsers.add(identifier.trim());
        }
      }

      // If no users are found in database yet, set fallback count from mock data
      final usersCount = uniqueUsers.isEmpty ? 2 : uniqueUsers.length;

      if (mounted) {
        setState(() {
          _sambatList = sambats;
          _woroList = woros;
          _gawatList = gawats;
          _totalUsersCount = usersCount;
          _emergencyCount = gawats.length;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  String _normalizeStatus(String? raw) {
    final status = (raw ?? '').toLowerCase().trim();
    switch (status) {
      case 'diproses':
      case 'proses':
        return 'Diproses';
      case 'selesai':
        return 'Selesai';
      case 'ditolak':
        return 'Ditolak';
      default:
        return 'Menunggu';
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Diproses':
        return Colors.blue;
      case 'Selesai':
        return Colors.green;
      case 'Ditolak':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get latest 3 sambats
    final recentSambats = _sambatList.take(3).toList();
    // Inisialisasi auth untuk kebutuhan fitur logout
    final auth = Provider.of<AuthController>(context, listen: false); 

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        // PERBAIKAN 1: Ikon Profil di kiri atas
        leading: IconButton(
          icon: const Icon(
            Icons.account_circle_outlined,
            color: AppTheme.primaryColor,
            size: 28,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileAdminPage()),
            ).then((_) => _loadData());
          },
        ),
        title: const Text(
          'Aduin Jember Admin',
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        // PERBAIKAN 2: Ikon Logout di kanan atas
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout_rounded,
              color: Color(0xFFC62828),
              size: 24,
            ),
            onPressed: auth.isBusy
                ? null
                : () async {
                    final confirmLogout = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Keluar Aplikasi'),
                        content: const Text('Apakah Anda yakin ingin keluar dari sesi admin?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Batal'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC62828)),
                            child: const Text('Keluar', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    );

                    if (confirmLogout == true) {
                      await auth.signOut();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                          (route) => false,
                        );
                      }
                    }
                  },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppTheme.primaryColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Salam Admin
              const Text(
                'Halo, Admin!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Selamat bertugas hari ini.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),

              if (_isLoading)
                const SizedBox(
                  height: 300,
                  child: Center(
                    child: CircularProgressIndicator(color: AppTheme.primaryColor),
                  ),
                )
              else if (_errorMessage != null)
                SizedBox(
                  height: 300,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          'Gagal memuat dashboard: $_errorMessage',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadData,
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                )
              else ...[
                // 2. Grid Statistik Ringkas (2x2)
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  children: [
                    _buildStatCard(
                      icon: Icons.description,
                      iconColor: AppTheme.primaryColor,
                      label: 'Total Sambat\nMasuk',
                      count: _sambatList.length.toString(),
                      badgeColor: const Color(0xFFE4E6FB),
                      onTap: () => widget.onNavigateToTab?.call(2), // Sambat Page Tab
                    ),
                    _buildStatCard(
                      icon: Icons.emergency,
                      iconColor: const Color(0xFFB71C1C),
                      label: 'Laporan Gawat',
                      count: _emergencyCount.toString(),
                      badgeColor: const Color(0xFFFFEBEE),
                      isEmergency: true,
                      onTap: () => widget.onNavigateToTab?.call(3), // Gawat Page Tab (index 3)
                    ),
                    _buildStatCard(
                      icon: Icons.campaign,
                      iconColor: Colors.green.shade700,
                      label: 'Woro-Woro\nAktif',
                      count: _woroList.length.toString(),
                      badgeColor: Colors.green.shade50,
                      onTap: () => widget.onNavigateToTab?.call(1), // Woro-Woro Tab
                    ),
                    _buildStatCard(
                      icon: Icons.people,
                      iconColor: Colors.grey.shade700,
                      label: 'Total\nPengguna',
                      count: _totalUsersCount.toString(),
                      badgeColor: Colors.grey.shade100,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const UsersAdmin(),
                          ),
                        ).then((_) => _loadData());
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // 2.5. Grafik Rekap Laporan Sambat & Gawat beserta Tren Harian
                _buildRecapChartCard(),
                const SizedBox(height: 20),
                _buildSambatDateBarChart(),
                const SizedBox(height: 20),
                _buildGawatRecapChartCard(),
                const SizedBox(height: 20),
                _buildGawatDateBarChart(),
                const SizedBox(height: 28),

                // 3. Header Sambat Terbaru
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Sambat Terbaru',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () => widget.onNavigateToTab?.call(2),
                      child: const Text(
                        'LIHAT SEMUA',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // 4. List Sambat
                if (recentSambats.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text('Belum ada sambat masuk.'),
                  )
                else
                  ...recentSambats.map((sambat) {
                    final rawStatus = sambat['status']?.toString();
                    final statusNormalized = _normalizeStatus(rawStatus);
                    final title = (sambat['judul'] ?? sambat['title'] ?? '-').toString();
                    final createdAtStr = (sambat['createdAt'] ?? sambat['created_at'] ?? '').toString();
                    final dateStr = createdAtStr.length >= 10
                        ? createdAtStr.substring(0, 10)
                        : 'Baru saja';

                    return _buildRecentSambatItem(
                      title: title,
                      date: dateStr,
                      statusText: statusNormalized,
                      statusColor: _statusColor(statusNormalized),
                      onTap: () => widget.onNavigateToTab?.call(2),
                    );
                  }),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPER: KARTU STATISTIK ---
  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String count,
    required Color badgeColor,
    bool isEmergency = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Positioned(
                top: -10,
                right: -10,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: badgeColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 16,
                child: Text(
                  count,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isEmergency
                        ? const Color(0xFFB71C1C)
                        : AppTheme.textPrimary,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(icon, color: iconColor, size: 28),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isEmergency
                            ? const Color(0xFFB71C1C)
                            : Colors.black87,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPER: BARIS LIST SAMBAT TERBARU ---
  Widget _buildRecentSambatItem({
    required String title,
    required String date,
    required String statusText,
    required Color statusColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.01),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        date,
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecapChartCard() {
    int countSosial = 0;
    int countInfrastruktur = 0;
    int countLayananUmum = 0;
    int countLainnya = 0;

    for (final s in _sambatList) {
      final kat = (s['kategori'] ?? s['category'] ?? '').toString().toLowerCase().trim();
      if (kat == 'sosial') {
        countSosial++;
      } else if (kat == 'infrastruktur') {
        countInfrastruktur++;
      } else if (kat == 'layanan umum') {
        countLayananUmum++;
      } else if (kat.isNotEmpty) {
        countLainnya++;
      }
    }
    final int totalCategory = countSosial + countInfrastruktur + countLayananUmum + countLainnya;

    int countMenunggu = 0;
    int countDiproses = 0;
    int countSelesai = 0;
    int countDitolak = 0;

    for (final s in _sambatList) {
      final stat = _normalizeStatus(s['status']?.toString());
      if (stat == 'Diproses') {
        countDiproses++;
      } else if (stat == 'Selesai') {
        countSelesai++;
      } else if (stat == 'Ditolak') {
        countDitolak++;
      } else {
        countMenunggu++;
      }
    }
    final int totalStatus = countMenunggu + countDiproses + countSelesai + countDitolak;

    final total = _sambatList.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PERBAIKAN 3: Wrap header text with Expanded to avoid overflow
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rekapitulasi Sambat',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Statistik aduan masuk',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    _buildChartTab(
                      label: 'Kategori',
                      isSelected: _selectedSambatChartTab == 0,
                      onTap: () => setState(() => _selectedSambatChartTab = 0),
                    ),
                    _buildChartTab(
                      label: 'Status',
                      isSelected: _selectedSambatChartTab == 1,
                      onTap: () => setState(() => _selectedSambatChartTab = 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          if (total == 0)
            const SizedBox(
              height: 120,
              child: Center(
                child: Text(
                  'Belum ada data laporan masuk',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
            )
          else if (_selectedSambatChartTab == 0) ...[
            _buildChartBar(
              label: 'Sosial',
              count: countSosial,
              total: totalCategory,
              color: Colors.orange,
            ),
            const SizedBox(height: 14),
            _buildChartBar(
              label: 'Infrastruktur',
              count: countInfrastruktur,
              total: totalCategory,
              color: Colors.blue,
            ),
            const SizedBox(height: 14),
            _buildChartBar(
              label: 'Layanan Umum',
              count: countLayananUmum,
              total: totalCategory,
              color: Colors.teal,
            ),
            if (countLainnya > 0) ...[
              const SizedBox(height: 14),
              _buildChartBar(
                label: 'Lainnya',
                count: countLainnya,
                total: totalCategory,
                color: Colors.grey,
              ),
            ],
          ] else ...[
            _buildChartBar(
              label: 'Menunggu',
              count: countMenunggu,
              total: totalStatus,
              color: Colors.orange,
            ),
            const SizedBox(height: 14),
            _buildChartBar(
              label: 'Diproses',
              count: countDiproses,
              total: totalStatus,
              color: Colors.blue,
            ),
            const SizedBox(height: 14),
            _buildChartBar(
              label: 'Selesai',
              count: countSelesai,
              total: totalStatus,
              color: Colors.green,
            ),
            const SizedBox(height: 14),
            _buildChartBar(
              label: 'Ditolak',
              count: countDitolak,
              total: totalStatus,
              color: Colors.red,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSambatDateBarChart() {
    final Map<DateTime, int> dateCounts = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    for (int i = 4; i >= 0; i--) {
      final d = today.subtract(Duration(days: i));
      dateCounts[d] = 0;
    }

    for (final s in _sambatList) {
      final createdAtStr = (s['createdAt'] ?? s['created_at'] ?? '').toString();
      if (createdAtStr.isNotEmpty) {
        try {
          final parsed = DateTime.parse(createdAtStr);
          final dateOnly = DateTime(parsed.year, parsed.month, parsed.day);
          dateCounts[dateOnly] = (dateCounts[dateOnly] ?? 0) + 1;
        } catch (_) {
          dateCounts[today] = (dateCounts[today] ?? 0) + 1;
        }
      }
    }

    final sortedEntries = dateCounts.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final displayEntries = sortedEntries.length > 5
        ? sortedEntries.sublist(sortedEntries.length - 5)
        : sortedEntries;

    final int total = displayEntries.fold<int>(0, (sum, entry) => sum + entry.value);

    int maxCount = 0;
    if (displayEntries.isNotEmpty) {
      maxCount = displayEntries.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    }

    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tren Laporan Sambat (Harian)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Total aduan 5 hari terakhir: $total Laporan',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          if (displayEntries.isEmpty)
            const SizedBox(
              height: 140,
              child: Center(
                child: Text('Belum ada data tren harian', style: TextStyle(color: Colors.grey, fontSize: 13)),
              ),
            )
          else
            SizedBox(
              height: 140,
              child: Stack(
                children: [
                  Positioned(
                    top: 25,
                    bottom: 25,
                    left: 0,
                    right: 0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildGridLine(),
                        _buildGridLine(),
                        _buildGridLine(),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15, bottom: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: displayEntries.map((entry) {
                        final double fraction = maxCount > 0 ? (entry.value / maxCount) : 0.0;
                        return Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                '${entry.value}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                height: 80 * fraction,
                                width: 24,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Colors.deepPurple,
                                      Colors.purpleAccent,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${entry.key.day} ${months[entry.key.month - 1]}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGawatRecapChartCard() {
    int countKecelakaan = 0;
    int countKriminal = 0;
    int countBencana = 0;
    int countLainnya = 0;

    for (final g in _gawatList) {
      final tipe = (g['jenisDarurat'] ?? '').toString().toLowerCase().trim();
      if (tipe == 'kecelakaan') {
        countKecelakaan++;
      } else if (tipe == 'kriminal') {
        countKriminal++;
      } else if (tipe == 'bencana') {
        countBencana++;
      } else if (tipe.isNotEmpty) {
        countLainnya++;
      }
    }
    final int totalType = countKecelakaan + countKriminal + countBencana + countLainnya;

    int countAktif = 0;
    int countDiproses = 0;
    int countSelesai = 0;

    for (final g in _gawatList) {
      final stat = _normalizeGawatStatus(g['status']?.toString());
      if (stat == 'Diproses') {
        countDiproses++;
      } else if (stat == 'Selesai') {
        countSelesai++;
      } else {
        countAktif++;
      }
    }
    final int totalStatus = countAktif + countDiproses + countSelesai;

    final total = _gawatList.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PERBAIKAN 3: Wrap header text with Expanded to avoid overflow
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rekapitulasi Gawat',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFB71C1C),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Statistik laporan darurat masuk',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    _buildChartTab(
                      label: 'Jenis',
                      isSelected: _selectedGawatChartTab == 0,
                      onTap: () => setState(() => _selectedGawatChartTab = 0),
                    ),
                    _buildChartTab(
                      label: 'Status',
                      isSelected: _selectedGawatChartTab == 1,
                      onTap: () => setState(() => _selectedGawatChartTab = 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          if (total == 0)
            const SizedBox(
              height: 120,
              child: Center(
                child: Text(
                  'Belum ada data laporan darurat masuk',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
            )
          else if (_selectedGawatChartTab == 0) ...[
            _buildChartBar(
              label: 'Kecelakaan',
              count: countKecelakaan,
              total: totalType,
              color: Colors.red.shade700,
            ),
            const SizedBox(height: 14),
            _buildChartBar(
              label: 'Kriminal',
              count: countKriminal,
              total: totalType,
              color: Colors.deepPurple,
            ),
            const SizedBox(height: 14),
            _buildChartBar(
              label: 'Bencana',
              count: countBencana,
              total: totalType,
              color: Colors.blue,
            ),
            if (countLainnya > 0) ...[
              const SizedBox(height: 14),
              _buildChartBar(
                label: 'Lainnya',
                count: countLainnya,
                total: totalType,
                color: Colors.grey,
              ),
            ],
          ] else ...[
            _buildChartBar(
              label: 'Aktif',
              count: countAktif,
              total: totalStatus,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 14),
            _buildChartBar(
              label: 'Diproses',
              count: countDiproses,
              total: totalStatus,
              color: Colors.blue,
            ),
            const SizedBox(height: 14),
            _buildChartBar(
              label: 'Selesai',
              count: countSelesai,
              total: totalStatus,
              color: Colors.green,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGawatDateBarChart() {
    final Map<DateTime, int> dateCounts = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    for (int i = 4; i >= 0; i--) {
      final d = today.subtract(Duration(days: i));
      dateCounts[d] = 0;
    }

    for (final g in _gawatList) {
      final createdAtStr = (g['createdAt'] ?? '').toString();
      if (createdAtStr.isNotEmpty) {
        try {
          final parsed = DateTime.parse(createdAtStr);
          final dateOnly = DateTime(parsed.year, parsed.month, parsed.day);
          dateCounts[dateOnly] = (dateCounts[dateOnly] ?? 0) + 1;
        } catch (_) {
          dateCounts[today] = (dateCounts[today] ?? 0) + 1;
        }
      }
    }

    final sortedEntries = dateCounts.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final displayEntries = sortedEntries.length > 5
        ? sortedEntries.sublist(sortedEntries.length - 5)
        : sortedEntries;

    final int total = displayEntries.fold<int>(0, (sum, entry) => sum + entry.value);

    int maxCount = 0;
    if (displayEntries.isNotEmpty) {
      maxCount = displayEntries.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    }

    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tren Laporan Gawat (Harian)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFFB71C1C),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Total darurat 5 hari terakhir: $total Laporan',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          if (displayEntries.isEmpty)
            const SizedBox(
              height: 140,
              child: Center(
                child: Text('Belum ada data tren harian', style: TextStyle(color: Colors.grey, fontSize: 13)),
              ),
            )
          else
            SizedBox(
              height: 140,
              child: Stack(
                children: [
                  Positioned(
                    top: 25,
                    bottom: 25,
                    left: 0,
                    right: 0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildGridLine(),
                        _buildGridLine(),
                        _buildGridLine(),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15, bottom: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: displayEntries.map((entry) {
                        final double fraction = maxCount > 0 ? (entry.value / maxCount) : 0.0;
                        return Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                '${entry.value}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                height: 80 * fraction,
                                width: 24,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Colors.red.shade800,
                                      Colors.red.shade400,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${entry.key.day} ${months[entry.key.month - 1]}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _normalizeGawatStatus(String? raw) {
    final status = (raw ?? '').toLowerCase().trim();
    switch (status) {
      case 'proses':
      case 'diproses':
        return 'Diproses';
      case 'selesai':
        return 'Selesai';
      default:
        return 'Aktif';
    }
  }

  Widget _buildChartTab({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildChartBar({
    required String label,
    required int count,
    required int total,
    required Color color,
  }) {
    final percentage = total > 0 ? (count / total) : 0.0;
    final percentageText = '${(percentage * 100).toStringAsFixed(0)}%';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              '$count Laporan ($percentageText)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Stack(
          children: [
            Container(
              height: 10,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F3F5),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            FractionallySizedBox(
              widthFactor: percentage,
              child: Container(
                height: 10,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color,
                      color.withValues(alpha: 0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGridLine() {
    return CustomPaint(
      size: const Size(double.infinity, 1),
      painter: DashedLinePainter(
        color: Colors.grey.shade200,
        dashWidth: 4.0,
        dashSpace: 4.0,
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  DashedLinePainter({
    this.color = const Color(0xFFE0E0E0),
    this.strokeWidth = 1.0,
    this.dashWidth = 4.0,
    this.dashSpace = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double startX = 0;
    final y = size.height / 2;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, y), Offset(startX + dashWidth, y), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}