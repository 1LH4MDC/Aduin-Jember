import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../services/auth_service.dart';
import '../../services/sambat_service.dart';
import 'create_sambat_page.dart';

class SambatkuPage extends StatefulWidget {
  const SambatkuPage({super.key});

  @override
  State<SambatkuPage> createState() => _SambatkuPageState();
}

class _SambatkuPageState extends State<SambatkuPage> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['Semua', 'Menunggu', 'Diproses', 'Selesai'];

  Future<List<Map<String, dynamic>>>? _futureSambat;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _futureSambat ??= _loadSambat();
  }

  Future<List<Map<String, dynamic>>> _loadSambat() async {
    final auth = context.read<AuthController>();
    final sambatService = SambatService(apiClient: auth.apiClient);
    return sambatService.fetchMySambat(auth.userId);
  }

  Future<void> _refresh() async {
    setState(() {
      _futureSambat = _loadSambat();
    });
    await _futureSambat;
  }

  /// Filter status from API to match filter chip labels.
  String _normalizeStatus(String? raw) {
    final status = (raw ?? '').toLowerCase().trim();
    switch (status) {
      case 'diproses':
        return 'Diproses';
      case 'selesai':
        return 'Selesai';
      case 'ditolak':
        return 'Ditolak';
      default:
        return 'Menunggu';
    }
  }

  List<Map<String, dynamic>> _applyFilter(List<Map<String, dynamic>> data) {
    if (_selectedFilterIndex == 0) return data; // Semua
    final filterLabel = _filters[_selectedFilterIndex];
    return data.where((item) {
      final status = _normalizeStatus(item['status']?.toString());
      return status == filterLabel;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Aduin Jember',
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sambatku',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pantau status sambat yang Anda kirimkan.',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: List.generate(
                _filters.length,
                (index) => _buildFilterChip(index, _filters[index]),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // List Sambat from API
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              color: AppTheme.primaryColor,
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _futureSambat,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppTheme.primaryColor),
                    );
                  }

                  if (snapshot.hasError) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 120),
                        Center(
                          child: Column(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red.shade300, size: 48),
                              const SizedBox(height: 12),
                              Text(
                                'Gagal memuat data sambat.',
                                style: TextStyle(color: Colors.red.shade700, fontSize: 14),
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: _refresh,
                                child: const Text('Coba Lagi'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  final allData = snapshot.data ?? [];
                  final filteredData = _applyFilter(allData);

                  if (allData.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 120),
                        Center(
                          child: Column(
                            children: [
                              Icon(Icons.inbox_outlined, color: Colors.grey.shade300, size: 48),
                              const SizedBox(height: 12),
                              const Text(
                                'Belum ada sambat yang dibuat.',
                                style: TextStyle(color: Colors.grey, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  if (filteredData.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 120),
                        Center(
                          child: Text(
                            'Tidak ada sambat dengan status "${_filters[_selectedFilterIndex]}".',
                            style: const TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ),
                      ],
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    itemCount: filteredData.length,
                    itemBuilder: (context, index) {
                      final item = filteredData[index];
                      final status = _normalizeStatus(item['status']?.toString());
                      final kategori = (item['kategori'] ?? item['category'] ?? '-')
                          .toString()
                          .toUpperCase();
                      final judul = (item['judul'] ?? item['title'] ?? '-').toString();
                      final lokasi =
                          (item['alamatLengkap'] ?? item['address'] ?? '').toString();
                      final photoUrl =
                          (item['fotoUrl'] ?? item['photo_url'] ?? '').toString();
                      final createdAtStr =
                          (item['createdAt'] ?? item['created_at'] ?? '').toString();
                      final dateStr = createdAtStr.length >= 10
                          ? createdAtStr.substring(0, 10)
                          : '';

                      return _buildReportCard(
                        kategori: kategori,
                        judul: judul,
                        lokasi: lokasi,
                        status: status,
                        photoUrl: photoUrl,
                        date: dateStr,
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      // Floating Action Button (+)
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<dynamic>(
            context,
            MaterialPageRoute(builder: (context) => const CreateSambatPage()),
          );
          // Refresh data setelah kembali dari form sambat
          if (result != null || mounted) {
            _refresh();
          }
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterChip(int index, String label) {
    bool isSelected = _selectedFilterIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilterIndex = index),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildReportCard({
    required String kategori,
    required String judul,
    required String lokasi,
    required String status,
    required String photoUrl,
    required String date,
  }) {
    Color statusColor;
    Color statusBg;

    switch (status) {
      case 'Diproses':
        statusColor = Colors.orange.shade700;
        statusBg = Colors.orange.shade50;
        break;
      case 'Selesai':
        statusColor = Colors.green.shade700;
        statusBg = Colors.green.shade50;
        break;
      case 'Ditolak':
        statusColor = Colors.red.shade700;
        statusBg = Colors.red.shade50;
        break;
      default: // Menunggu
        statusColor = Colors.grey.shade700;
        statusBg = Colors.grey.shade200;
    }

    final bool hasImage = photoUrl.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasImage) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                photoUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        kategori,
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  judul,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                if (lokasi.isNotEmpty)
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          lokasi,
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                if (date.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          date,
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}