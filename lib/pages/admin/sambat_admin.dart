import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../services/auth_service.dart';
import '../../services/sambat_service.dart';

class SambatAdminPage extends StatefulWidget {
  const SambatAdminPage({super.key});

  @override
  State<SambatAdminPage> createState() => _SambatAdminPageState();
}

class _SambatAdminPageState extends State<SambatAdminPage> {
  bool _isLoading = true;
  String? _errorMessage;

  List<Map<String, dynamic>> _allSambatList = [];
  List<Map<String, dynamic>> _filteredList = [];

  // Filter State
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['Semua', 'Menunggu', 'Diproses', 'Selesai', 'Ditolak'];
  int _selectedCategoryIndex = 0;
  final List<String> _categoryFilters = ['Semua Kategori', 'Sosial', 'Infrastruktur', 'Layanan Umum'];

  @override
  void initState() {
    super.initState();
    _loadSambat();
  }

  Future<void> _loadSambat() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final auth = context.read<AuthController>();
      final sambatService = SambatService(apiClient: auth.apiClient);
      final list = await sambatService.fetchAllSambat();

      if (mounted) {
        setState(() {
          _allSambatList = list;
          _applyFilters();
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

  void _applyFilters() {
    List<Map<String, dynamic>> temp = List.from(_allSambatList);

    // 1. Filter by status chip
    if (_selectedFilterIndex > 0) {
      final filterLabel = _filters[_selectedFilterIndex];
      temp = temp.where((item) {
        final itemStatus = _normalizeStatus(item['status']?.toString());
        return itemStatus == filterLabel;
      }).toList();
    }

    // 2. Filter by category chip
    if (_selectedCategoryIndex > 0) {
      final categoryLabel = _categoryFilters[_selectedCategoryIndex];
      temp = temp.where((item) {
        final itemCategory = (item['kategori'] ?? item['category'] ?? '').toString().trim();
        return itemCategory.toLowerCase() == categoryLabel.toLowerCase();
      }).toList();
    }

    setState(() {
      _filteredList = temp;
    });
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

  String _statusToApiValue(String status) {
    switch (status) {
      case 'Diproses':
        return 'diproses';
      case 'Selesai':
        return 'selesai';
      case 'Ditolak':
        return 'ditolak';
      default:
        return 'pending';
    }
  }

  // --- SHOW BOTTOM SHEET UBAH STATUS ---
  void _showUbahStatusBottomSheet(Map<String, dynamic> sambat) {
    final sambatId = (sambat['idSambat'] ?? sambat['id'] ?? '').toString();
    final currentStatus = _normalizeStatus(sambat['status']?.toString());
    String statusSelected = currentStatus;
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Ubah Status Sambat',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Dropdown/Selector Status
                  DropdownButtonFormField<String>(
                    initialValue: statusSelected,
                    items: ['Menunggu', 'Diproses', 'Selesai', 'Ditolak']
                        .map(
                          (val) => DropdownMenuItem<String>(
                            value: val,
                            child: Text(val),
                          ),
                        )
                        .toList(),
                    onChanged: isSaving
                        ? null
                        : (val) {
                            if (val != null) {
                              setModalState(() => statusSelected = val);
                            }
                          },
                    decoration: const InputDecoration(
                      labelText: 'Status Baru',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tombol Simpan
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isSaving
                          ? null
                          : () async {
                              setModalState(() => isSaving = true);
                              try {
                                final auth = context.read<AuthController>();
                                final sambatService = SambatService(apiClient: auth.apiClient);

                                await sambatService.updateStatus(
                                  sambatId: sambatId,
                                  status: _statusToApiValue(statusSelected),
                                );

                                if (context.mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Status sambat berhasil diperbarui.'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                                _loadSambat();
                              } catch (e) {
                                setModalState(() => isSaving = false);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
                                  );
                                }
                              }
                            },
                      child: isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('Simpan Perubahan'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- SHOW DIALOG DETAIL ---
  void _showDetailDialog(Map<String, dynamic> sambat) {
    final title = (sambat['judul'] ?? sambat['title'] ?? '-').toString();
    final desc = (sambat['deskripsi'] ?? sambat['description'] ?? '-').toString();
    final address = (sambat['alamatLengkap'] ?? sambat['address'] ?? '-').toString();
    final category = (sambat['kategori'] ?? sambat['category'] ?? '-').toString().toUpperCase();
    final status = _normalizeStatus(sambat['status']?.toString());
    final photoUrl = (sambat['fotoUrl'] ?? sambat['photo_url'] ?? '').toString();
    final name = (sambat['namaUser'] ?? sambat['author_name'] ?? '-').toString();
    final email = (sambat['emailUser'] ?? sambat['author_email'] ?? '-').toString();
    final catatan = (sambat['catatan'] ?? '').toString();

    // Coordinates parsing
    double lat = -8.1715;
    double lng = 113.7020;
    try {
      lat = double.parse(sambat['latitude']?.toString() ?? '-8.1715');
      lng = double.parse(sambat['longitude']?.toString() ?? '113.7020');
    } catch (_) {}

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Photo Header
                  if (photoUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      child: Image.network(
                        photoUrl,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          height: 180,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.08),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      child: const Icon(Icons.image_outlined, size: 50, color: AppTheme.primaryColor),
                    ),

                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category & Status Badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                category,
                                style: const TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: status == 'Diproses'
                                    ? Colors.blue.shade50
                                    : status == 'Selesai'
                                        ? Colors.green.shade50
                                        : status == 'Ditolak'
                                            ? Colors.red.shade50
                                            : Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                status,
                                style: TextStyle(
                                  color: status == 'Diproses'
                                      ? Colors.blue
                                      : status == 'Selesai'
                                          ? Colors.green
                                          : status == 'Ditolak'
                                              ? Colors.red
                                              : Colors.orange,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Title & Desc
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          desc,
                          style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
                        ),
                        const Divider(height: 24),

                        // Reporter Info
                        const Text(
                          'Reporter / Pelapor',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.mail_outline, size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(email, style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                        const Divider(height: 24),

                        // Catatan Status
                        if (catatan.isNotEmpty) ...[
                          const Text(
                            'Catatan Tindak Lanjut',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.amber.shade200),
                            ),
                            child: Text(
                              catatan,
                              style: TextStyle(fontSize: 13, color: Colors.amber.shade900),
                            ),
                          ),
                          const Divider(height: 24),
                        ],

                        // Location details
                        const Text(
                          'Lokasi Kejadian',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                address,
                                style: const TextStyle(fontSize: 13, color: Colors.black87),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Interactive Map
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            height: 180,
                            width: double.infinity,
                            child: FlutterMap(
                              options: MapOptions(
                                initialCenter: latlong.LatLng(lat, lng),
                                initialZoom: 15,
                                interactionOptions: const InteractionOptions(
                                  flags: InteractiveFlag.none, // Static map viewing
                                ),
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'aduin_jember',
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: latlong.LatLng(lat, lng),
                                      width: 40,
                                      height: 40,
                                      child: const Icon(
                                        Icons.location_pin,
                                        size: 40,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Close button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppTheme.primaryColor),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Tutup', style: TextStyle(color: AppTheme.primaryColor)),
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
      },
    );
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
          'Sambat Management',
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          // 1. Horizontal Scroll Filter Chips (Status)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(top: 12, bottom: 6),
            child: SingleChildScrollView(
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
          ),

          // Horizontal Scroll Filter Chips (Kategori)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(top: 6, bottom: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: List.generate(
                  _categoryFilters.length,
                  (index) => _buildCategoryFilterChip(index, _categoryFilters[index]),
                ),
              ),
            ),
          ),

          // 2. Daftar Sambat (Search Bar dihapus, Container bawah langsung menyambung)
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadSambat,
              color: AppTheme.primaryColor,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
                  : _errorMessage != null
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            const SizedBox(height: 120),
                            Center(
                              child: Column(
                                children: [
                                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                                  const SizedBox(height: 12),
                                  Text('Gagal memuat data: $_errorMessage', style: const TextStyle(color: Colors.red)),
                                  const SizedBox(height: 12),
                                  ElevatedButton(onPressed: _loadSambat, child: const Text('Coba Lagi')),
                                ],
                              ),
                            ),
                          ],
                        )
                      : _filteredList.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: const [
                                SizedBox(height: 120),
                                Center(child: Text('Tidak ada data sambat ditemukan.')),
                              ],
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(20),
                              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                              itemCount: _filteredList.length,
                              itemBuilder: (context, index) {
                                final item = _filteredList[index];
                                final category = (item['kategori'] ?? item['category'] ?? '-').toString().toUpperCase();
                                final title = (item['judul'] ?? item['title'] ?? '-').toString();
                                final address = (item['alamatLengkap'] ?? item['address'] ?? '').toString();
                                final statusRaw = item['status']?.toString();
                                final status = _normalizeStatus(statusRaw).toUpperCase();
                                final createdAtStr = (item['createdAt'] ?? item['created_at'] ?? '').toString();
                                final dateStr = createdAtStr.length >= 10
                                    ? createdAtStr.substring(0, 10)
                                    : 'Baru saja';
                                final photoUrl = (item['fotoUrl'] ?? item['photo_url'] ?? '').toString();

                                return _buildSambatCard(
                                  sambat: item,
                                  kategori: category,
                                  judul: title,
                                  lokasi: address,
                                  waktu: dateStr,
                                  status: status,
                                  photoUrl: photoUrl,
                                );
                              },
                            ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER: FILTER CHIP ---
  Widget _buildFilterChip(int index, String label) {
    bool isSelected = _selectedFilterIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilterIndex = index;
          _applyFilters();
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : const Color(0xFFEEEEEE),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade600,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilterChip(int index, String label) {
    bool isSelected = _selectedCategoryIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategoryIndex = index;
          _applyFilters();
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.teal : const Color(0xFFEEEEEE),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade600,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPER: KARTU SAMBAT ---
  Widget _buildSambatCard({
    required Map<String, dynamic> sambat,
    required String kategori,
    required String judul,
    required String lokasi,
    required String waktu,
    required String status,
    required String photoUrl,
  }) {
    Color statusColor;
    Color statusBgColor;

    if (status == 'MENUNGGU') {
      statusColor = Colors.orange;
      statusBgColor = Colors.orange.shade50;
    } else if (status == 'DIPROSES' || status == 'PROSES') {
      statusColor = Colors.blue;
      statusBgColor = Colors.blue.shade50;
    } else if (status == 'DITOLAK') {
      statusColor = Colors.red;
      statusBgColor = Colors.red.shade50;
    } else {
      statusColor = Colors.green;
      statusBgColor = Colors.green.shade50;
    }

    final hasImage = photoUrl.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baris 1: Kategori & Pill Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                kategori,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                  letterSpacing: 1,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Baris 2: Gambar, Judul, Lokasi
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEEEEE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: hasImage
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          photoUrl,
                          width: 70,
                          height: 70,
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
                        size: 30,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      judul,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            lokasi,
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Color(0xFFEEEEEE), thickness: 1),
          ),

          // Baris 3: Waktu, Ubah Status, Lihat Detail
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  waktu,
                  style: const TextStyle(fontSize: 12, color: Colors.grey, height: 1.3),
                ),
              ),
              Row(
                children: [
                  InkWell(
                    onTap: () => _showUbahStatusBottomSheet(sambat),
                    child: const Row(
                      children: [
                        Text(
                          'Ubah\nStatus',
                          textAlign: TextAlign.right,
                          style: TextStyle(color: AppTheme.primaryColor, fontSize: 12),
                        ),
                        Icon(Icons.keyboard_arrow_down, color: AppTheme.primaryColor, size: 16),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  InkWell(
                    onTap: () => _showDetailDialog(sambat),
                    child: const Text(
                      'Lihat\nDetail >',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}