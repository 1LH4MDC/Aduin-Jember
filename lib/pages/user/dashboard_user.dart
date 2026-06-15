import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../services/auth_service.dart';
import '../../services/woro_service.dart';
import 'create_sambat_page.dart';
import 'woro_woro_detail_page.dart';
import 'gawat_page.dart';

class DashboardUser extends StatefulWidget {
  // Tambahkan parameter fungsi callback ini
  final Function(int)? onNavigateToTab;

  const DashboardUser({super.key, this.onNavigateToTab});

  @override
  State<DashboardUser> createState() => _DashboardUserState();
}

class _DashboardUserState extends State<DashboardUser> {
  late Future<List<Map<String, dynamic>>> _woroFuture;
  bool _woroLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_woroLoaded) {
      _woroLoaded = true;
      _loadWoro();
    }
  }

  void _loadWoro() {
    final auth = context.read<AuthController>();
    _woroFuture = WoroService(apiClient: auth.apiClient).fetchWoro();
  }

  Future<void> _refresh() async {
    setState(() {
      _loadWoro();
    });
    await _woroFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: AppTheme.primaryColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              _buildInfoBanner(),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Woro-Woro Jember',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    'Geser ->',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildWoroWoroList(context),
              const SizedBox(height: 24),

              const Text(
                'Fitur Utama',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              _buildFiturUtama(context),
              const SizedBox(height: 24),

              _buildGawatButton(context),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // --- KOMPONEN HEADER ---
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final auth = Provider.of<AuthController>(context, listen: false);
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(
          Icons.account_circle_outlined,
          color: Colors.black87,
          size: 28,
        ),
        onPressed: () {
          // PERBAIKAN: Gunakan fungsi callback untuk pindah ke tab Profil (index 2)
          if (widget.onNavigateToTab != null) {
            widget.onNavigateToTab!(2);
          }
        },
      ),
      title: Column(
        children: [
          const Text(
            'Aduin Jember',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Text(
            'Halo, ${auth.displayName}!',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET BARU: BANNER INFORMASI ---
  Widget _buildInfoBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.primaryColor.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.campaign_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Suarakan Aspirasimu!',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Bersama membangun Jember yang lebih baik melalui layanan pengaduan terpadu.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- KOMPONEN WORO-WORO TETAP ---
  Widget _buildWoroWoroList(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _woroFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 180,
            child: Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            ),
          );
        }
        if (snapshot.hasError) {
          debugPrint('Woro-woro error: ${snapshot.error}');
          return SizedBox(
            height: 180,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Gagal memuat pengumuman',
                    style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => setState(() => _loadWoro()),
                    child: Text(
                      'Coba lagi',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        final woroList = snapshot.data ?? [];
        if (woroList.isEmpty) {
          return SizedBox(
            height: 160,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, color: Colors.grey.shade300, size: 40),
                  const SizedBox(height: 8),
                  Text(
                    'Belum ada pengumuman terbaru.',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        }

        return SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: woroList.length,
            itemBuilder: (context, index) {
              final item = woroList[index];
              final createdAtStr = (item['createdAt'] ?? item['created_at'] ?? '').toString();
              final dateStr = createdAtStr.isNotEmpty
                  ? createdAtStr.substring(0, 10)
                  : '-';

              final fotoUrl = (item['fotoUrl'] ?? item['photo_url'] ?? '').toString();
              final hasImage = fotoUrl.isNotEmpty;

              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WoroWoroDetailPage(
                        title: (item['judul'] ?? item['title'] ?? '').toString(),
                        date: dateStr,
                        konten: (item['konten'] ?? item['content'] ?? '').toString(), 
                        kategori: (item['kategori'] ?? item['category'] ?? 'Lainnya').toString(),
                        fotoUrl: fotoUrl,
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 240,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        child: Container(
                          height: 100,
                          color: const Color(0xFFE0E0E0),
                          child: hasImage
                              ? Image.network(
                                  fotoUrl,
                                  width: double.infinity,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => const Center(
                                    child: Icon(
                                      Icons.broken_image_outlined,
                                      color: Colors.grey,
                                      size: 40,
                                    ),
                                  ),
                                )
                              : const Center(
                                  child: Icon(
                                    Icons.campaign_rounded,
                                    color: Colors.grey,
                                    size: 40,
                                  ),
                                ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dateStr,
                              style: const TextStyle(
                                color: AppTheme.primaryColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              (item['judul'] ?? item['title'] ?? '').toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppTheme.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
        );
      },
    );
  }

  // --- KOMPONEN FITUR UTAMA ---
  Widget _buildFiturUtama(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildFiturCard(
            backgroundColor: AppTheme.primaryColor,
            textColor: Colors.white,
            iconRow: const Row(
              children: [
                Icon(Icons.camera_alt_outlined, color: Colors.white, size: 28),
                SizedBox(width: 4),
                Icon(
                  Icons.insert_drive_file_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ],
            ),
            title: 'SAMBAT',
            subtitle: 'Sambat Jalan Rusak, Sampah, dll',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => const CreateSambatPage(),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildFiturCard(
            backgroundColor: const Color(0xFFE4E6FB), 
            textColor: AppTheme.primaryColor,
            iconRow: const Icon(
              Icons.manage_search_rounded,
              color: AppTheme.primaryColor,
              size: 32,
            ),
            title: 'TRACKING',
            subtitle: 'Pantau kemajuan sambat Anda',
            onTap: () {
              // PERBAIKAN: Gunakan fungsi callback untuk pindah ke tab Sambatku (index 1)
              if (widget.onNavigateToTab != null) {
                widget.onNavigateToTab!(1);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFiturCard({
    required Color backgroundColor,
    required Color textColor,
    required Widget iconRow,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: SizedBox(
          height: 160,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                iconRow,
                const Spacer(),
                Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.8),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- KOMPONEN GAWAT DARURAT TETAP ---
  Widget _buildGawatButton(BuildContext context) {
    return Material(
      color: const Color(0xFFB71C1C), 
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const GawatPage()),
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  'SOS',
                  style: TextStyle(
                    color: Color(0xFFB71C1C),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GAWAT',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Hanya untuk situasi mengancam jiwa\n(Kecelakaan, Kriminal)',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
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
}