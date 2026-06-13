import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../services/auth_service.dart';
import '../../services/woro_service.dart';
import 'tambah_woro_woro_page.dart';

class WoroWoroAdmin extends StatefulWidget {
  const WoroWoroAdmin({super.key});

  @override
  State<WoroWoroAdmin> createState() => _WoroWoroAdminState();
}

class _WoroWoroAdminState extends State<WoroWoroAdmin> {
  late WoroService _woroService;
  List<Map<String, dynamic>> _woroList = [];
  bool _isLoading = true;
  bool _woroLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = context.read<AuthController>();
    _woroService = WoroService(apiClient: auth.apiClient);
    if (!_woroLoaded) {
      _woroLoaded = true;
      _loadWoro();
    }
  }

  Future<void> _loadWoro() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final list = await _woroService.fetchWoro();
      if (mounted) {
        setState(() {
          _woroList = list;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat pengumuman: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteWoro(String idWoro, String title) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pengumuman'),
        content: Text('Apakah Anda yakin ingin menghapus pengumuman "$title"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _woroService.deleteWoro(idWoro);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pengumuman berhasil dihapus'), backgroundColor: Colors.green),
          );
        }
        _loadWoro();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menghapus: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Woro-Woro Management',
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadWoro,
        color: AppTheme.primaryColor,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // 1. REKOMENDASI PENGGANTI SEARCH BAR: Summary Banner
              _buildSummaryBanner(),
              const SizedBox(height: 24),

              // 2. List Woro-Woro
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
                    : _woroList.isEmpty
                        ? const Center(child: Text('Tidak ada pengumuman saat ini.'))
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                            itemCount: _woroList.length,
                            itemBuilder: (context, index) {
                              final item = _woroList[index];
                              final idWoro = item['idWoro']?.toString() ?? '';
                              final title = item['judul']?.toString() ?? '';
                              final createdAtStr = item['createdAt']?.toString() ?? '';
                              final dateStr = createdAtStr.isNotEmpty
                                  ? createdAtStr.substring(0, 10)
                                  : '-';
                              final photoUrl = (item['fotoUrl'] ?? item['photo_url'] ?? '').toString();
                              return _buildWoroItem(
                                idWoro: idWoro,
                                title: title,
                                date: dateStr,
                                photoUrl: photoUrl,
                                item: item,
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
      // 3. Tombol Tambah (+)
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TambahWoroWoroPage(),
            ),
          );
          if (result == true) {
            _loadWoro();
          }
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // --- WIDGET BARU: Banner Rekapitulasi ---
  Widget _buildSummaryBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
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
            child: const Icon(Icons.campaign_rounded, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Pengumuman',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_woroList.length} Woro-Woro Aktif',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Widget Bantuan untuk Baris List Woro-Woro ---
  Widget _buildWoroItem({
    required String idWoro,
    required String title,
    required String date,
    required String photoUrl,
    required Map<String, dynamic> item,
  }) {
    final bool hasImage = photoUrl.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Gambar Thumbnail
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFEEEEEE),
              borderRadius: BorderRadius.circular(8),
            ),
            child: hasImage
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      photoUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => const Icon(
                        Icons.broken_image,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : const Icon(
                    Icons.image_outlined,
                    color: Colors.grey,
                  ),
          ),
          const SizedBox(width: 16),
          // Judul dan Tanggal
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      date,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Tombol Edit & Delete
          Column(
            children: [
              IconButton(
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.edit, color: AppTheme.primaryColor, size: 20),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TambahWoroWoroPage(woro: item),
                    ),
                  );
                  if (result == true) {
                    _loadWoro();
                  }
                },
              ),
              const SizedBox(height: 12),
              IconButton(
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                onPressed: () => _deleteWoro(idWoro, title),
              ),
            ],
          ),
        ],
      ),
    );
  }
}