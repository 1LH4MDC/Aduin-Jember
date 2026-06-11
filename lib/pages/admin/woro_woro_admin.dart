import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../services/woro_service.dart';
import 'tambah_woro_woro_page.dart';

class WoroWoroAdmin extends StatefulWidget {
  const WoroWoroAdmin({super.key});

  @override
  State<WoroWoroAdmin> createState() => _WoroWoroAdminState();
}

class _WoroWoroAdminState extends State<WoroWoroAdmin> {
  final _woroService = WoroService();
  List<Map<String, dynamic>> _woroList = [];
  List<Map<String, dynamic>> _filteredList = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadWoro();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadWoro() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final list = await _woroService.fetchWoro();
      setState(() {
        _woroList = list;
        _filterWoro();
      });
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

  void _filterWoro() {
    if (_searchQuery.isEmpty) {
      _filteredList = List.from(_woroList);
    } else {
      _filteredList = _woroList.where((item) {
        final title = (item['judul'] ?? '').toString().toLowerCase();
        final content = (item['konten'] ?? '').toString().toLowerCase();
        final category = (item['kategori'] ?? '').toString().toLowerCase();
        final query = _searchQuery.toLowerCase();
        return title.contains(query) || content.contains(query) || category.contains(query);
      }).toList();
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
              // 1. Search Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                      _filterWoro();
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'Cari Pengumuman...',
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 2. List Woro-Woro
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
                    : _filteredList.isEmpty
                        ? const Center(child: Text('Tidak ada pengumuman ditemukan.'))
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                            itemCount: _filteredList.length,
                            itemBuilder: (context, index) {
                              final item = _filteredList[index];
                              final idWoro = item['idWoro']?.toString() ?? '';
                              final title = item['judul']?.toString() ?? '';
                              final createdAtStr = item['createdAt']?.toString() ?? '';
                              final dateStr = createdAtStr.isNotEmpty
                                  ? createdAtStr.substring(0, 10)
                                  : '-';
                              return _buildWoroItem(
                                idWoro: idWoro,
                                title: title,
                                date: dateStr,
                                hasImage: false,
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

  // Widget Bantuan untuk Baris List Woro-Woro
  Widget _buildWoroItem({
    required String idWoro,
    required String title,
    required String date,
    required bool hasImage,
    required Map<String, dynamic> item,
  }) {
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
            child: Icon(
              hasImage ? Icons.image : Icons.image_outlined,
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