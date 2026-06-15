import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../services/auth_service.dart';
import '../../services/gawat_service.dart';

class GawatAdminPage extends StatefulWidget {
  const GawatAdminPage({super.key});

  @override
  State<GawatAdminPage> createState() => _GawatAdminPageState();
}

class _GawatAdminPageState extends State<GawatAdminPage> {
  bool _isLoading = true;
  String? _errorMessage;

  List<Map<String, dynamic>> _allGawatList = [];
  List<Map<String, dynamic>> _filteredList = [];

  // Filter & Search State
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['Semua', 'Kecelakaan', 'Kriminal', 'Bencana'];

  int _selectedStatusIndex = 0;
  final List<String> _statusFilters = [
    'Semua',
    'Mencari Bantuan',
    'Ditangani',
    'Selesai',
  ];

  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadGawat();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadGawat() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final auth = context.read<AuthController>();
      final gawatService = GawatService(apiClient: auth.apiClient);
      final list = await gawatService.fetchGawat();

      if (mounted) {
        setState(() {
          _allGawatList = list;
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
    List<Map<String, dynamic>> temp = List.from(_allGawatList);

    // 1. Filter by emergency type chip
    if (_selectedFilterIndex > 0) {
      final filterLabel = _filters[_selectedFilterIndex].toLowerCase();
      temp = temp.where((item) {
        final type = (item['jenisDarurat'] ?? '').toString().toLowerCase();
        return type == filterLabel;
      }).toList();
    }

    // 2. Filter by status chip
    if (_selectedStatusIndex > 0) {
      final targetStatus = _statusFilters[_selectedStatusIndex];
      temp = temp.where((item) {
        return _normalizeStatus(item['status']?.toString()) == targetStatus;
      }).toList();
    }

    // 3. Filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      temp = temp.where((item) {
        final name = (item['namaUser'] ?? '').toString().toLowerCase();
        final email = (item['emailUser'] ?? '').toString().toLowerCase();
        final type = (item['jenisDarurat'] ?? '').toString().toLowerCase();
        final status = (item['status'] ?? '').toString().toLowerCase();

        return name.contains(query) ||
            email.contains(query) ||
            type.contains(query) ||
            status.contains(query);
      }).toList();
    }

    // Urutkan berdasarkan tanggal terbaru jika ada
    temp.sort((a, b) {
      final dateA =
          DateTime.tryParse(a['createdAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final dateB =
          DateTime.tryParse(b['createdAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0);
      return dateB.compareTo(dateA); // Descending
    });

    setState(() {
      _filteredList = temp;
    });
  }

  String _normalizeStatus(String? raw) {
    final status = (raw ?? '').toLowerCase().trim();
    switch (status) {
      case 'proses':
      case 'diproses':
      case 'ditangani':
        return 'Ditangani';
      case 'selesai':
        return 'Selesai';
      default:
        return 'Mencari Bantuan';
    }
  }

  String _statusToApiValue(String status) {
    switch (status) {
      case 'Ditangani':
        return 'ditangani';
      case 'Selesai':
        return 'selesai';
      default:
        return 'mencari bantuan';
    }
  }

  // --- SHOW BOTTOM SHEET UBAH STATUS ---
  void _showUbahStatusBottomSheet(Map<String, dynamic> gawat) {
    final gawatId = (gawat['idGawat'] ?? gawat['id'] ?? '').toString();
    final currentStatus = _normalizeStatus(gawat['status']?.toString());
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
                    'Ubah Status Laporan Gawat',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFB71C1C),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Dropdown/Selector Status
                  DropdownButtonFormField<String>(
                    initialValue: statusSelected,
                    items: ['Mencari Bantuan', 'Ditangani', 'Selesai']
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
                                final gawatService = GawatService(
                                  apiClient: auth.apiClient,
                                );

                                await gawatService.updateStatus(
                                  gawatId: gawatId,
                                  status: _statusToApiValue(statusSelected),
                                );

                                if (context.mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Status laporan gawat berhasil diperbarui.',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                                _loadGawat();
                              } catch (e) {
                                setModalState(() => isSaving = false);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Gagal: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB71C1C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Simpan Perubahan',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
  void _showDetailDialog(Map<String, dynamic> gawat) {
    final name = (gawat['namaUser'] ?? 'Pengguna').toString();
    final email = (gawat['emailUser'] ?? 'tidak ada email').toString();
    final type = (gawat['jenisDarurat'] ?? 'Umum').toString().toUpperCase();
    final statusRaw = (gawat['status'] ?? 'Aktif').toString();
    final status = _normalizeStatus(statusRaw);
    final createdAtStr = (gawat['createdAt'] ?? '').toString();
    final catatan = (gawat['catatan'] ?? '').toString();

    String dateStr = '-';
    if (createdAtStr.isNotEmpty) {
      try {
        final parsed = DateTime.parse(createdAtStr).toLocal();
        dateStr =
            "${parsed.day.toString().padLeft(2, '0')}-${parsed.month.toString().padLeft(2, '0')}-${parsed.year} ${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}";
      } catch (_) {
        dateStr = createdAtStr.length >= 10
            ? createdAtStr.substring(0, 10)
            : createdAtStr;
      }
    }

    // Coordinates parsing
    double lat = -8.1715;
    double lng = 113.7020;
    try {
      lat = double.parse(gawat['latitude']?.toString() ?? '-8.1715');
      lng = double.parse(gawat['longitude']?.toString() ?? '113.7020');
    } catch (_) {}

    Color statusColor;
    Color statusBgColor;
    if (status == 'Ditangani') {
      statusColor = Colors.blue;
      statusBgColor = Colors.blue.shade50;
    } else if (status == 'Selesai') {
      statusColor = Colors.green;
      statusBgColor = Colors.green.shade50;
    } else {
      statusColor = const Color(0xFFD32F2F);
      statusBgColor = Colors.red.shade50;
    }

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 24,
                      horizontal: 20,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFFB71C1C), // Merah Pekat
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.emergency_share,
                          color: Colors.white,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'LAPORAN DARURAT: $type',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                dateStr,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status Badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Status Laporan:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: statusBgColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                status.toUpperCase(),
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),

                        // Reporter Info
                        const Text(
                          'Identitas Pelapor',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.red.shade50,
                              child: const Icon(
                                Icons.person,
                                color: Color(0xFFB71C1C),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    email,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),

                        // Catatan Status
                        if (catatan.isNotEmpty) ...[
                          const Text(
                            'Catatan Tindak Lanjut',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                              fontSize: 12,
                            ),
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
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.amber.shade900,
                              ),
                            ),
                          ),
                          const Divider(height: 24),
                        ],

                        // Coordinates
                        const Text(
                          'Koordinat Lokasi',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 18,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$lat, $lng',
                              style: const TextStyle(
                                fontSize: 14,
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Interactive Map
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            height: 200,
                            width: double.infinity,
                            child: FlutterMap(
                              options: MapOptions(
                                initialCenter: latlong.LatLng(lat, lng),
                                initialZoom: 15,
                                interactionOptions: const InteractionOptions(
                                  flags: InteractiveFlag.all,
                                ),
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'aduin_jember',
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: latlong.LatLng(lat, lng),
                                      width: 44,
                                      height: 44,
                                      child: const Icon(
                                        Icons.location_pin,
                                        size: 44,
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

                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 50,
                                child: OutlinedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                      color: Color(0xFFB71C1C),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'TUTUP',
                                    style: TextStyle(
                                      color: Color(0xFFB71C1C),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SizedBox(
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _showUbahStatusBottomSheet(gawat);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFB71C1C),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'UBAH STATUS',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
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
          'Pemantauan Darurat (GAWAT)',
          style: TextStyle(
            color: Color(0xFFB71C1C),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          // 1. Horizontal Scroll Filter Chips — Jenis Darurat
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(top: 12, bottom: 4),
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

          // 2. Horizontal Scroll Filter Chips — Status
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(top: 4, bottom: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: List.generate(
                  _statusFilters.length,
                  (index) => _buildStatusChip(index, _statusFilters[index]),
                ),
              ),
            ),
          ),

          // Search Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 12),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1F3F5),
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                    _applyFilters();
                  });
                },
                decoration: const InputDecoration(
                  hintText:
                      'Cari laporan darurat berdasarkan nama atau jenis...',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          // 2. Daftar Laporan
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadGawat,
              color: const Color(0xFFB71C1C),
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFB71C1C),
                      ),
                    )
                  : _errorMessage != null
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 120),
                        Center(
                          child: Column(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 48,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Gagal memuat data: $_errorMessage',
                                style: const TextStyle(color: Colors.red),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: _loadGawat,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFB71C1C),
                                ),
                                child: const Text(
                                  'Coba Lagi',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
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
                        Center(
                          child: Text('Tidak ada laporan darurat ditemukan.'),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      itemCount: _filteredList.length,
                      itemBuilder: (context, index) {
                        final item = _filteredList[index];
                        final type = (item['jenisDarurat'] ?? 'Umum')
                            .toString()
                            .toUpperCase();
                        final name = (item['namaUser'] ?? 'Pengguna')
                            .toString();
                        final email = (item['emailUser'] ?? 'tidak ada email')
                            .toString();
                        final statusRaw = (item['status'] ?? 'Aktif')
                            .toString();
                        final status = _normalizeStatus(
                          statusRaw,
                        ).toUpperCase();
                        final createdAtStr = (item['createdAt'] ?? '')
                            .toString();

                        String dateStr = '-';
                        if (createdAtStr.isNotEmpty) {
                          try {
                            final parsed = DateTime.parse(
                              createdAtStr,
                            ).toLocal();
                            dateStr =
                                "${parsed.day.toString().padLeft(2, '0')}-${parsed.month.toString().padLeft(2, '0')}-${parsed.year} ${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}";
                          } catch (_) {
                            dateStr = createdAtStr.length >= 10
                                ? createdAtStr.substring(0, 10)
                                : createdAtStr;
                          }
                        }

                        return _buildGawatCard(
                          gawat: item,
                          jenisDarurat: type,
                          nama: name,
                          email: email,
                          waktu: dateStr,
                          status: status,
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
          color: isSelected ? const Color(0xFFB71C1C) : const Color(0xFFEEEEEE),
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

  // --- WIDGET HELPER: STATUS CHIP ---
  Widget _buildStatusChip(int index, String label) {
    bool isSelected = _selectedStatusIndex == index;

    Color activeColor;
    switch (label) {
      case 'Mencari Bantuan':
        activeColor = const Color(0xFFD32F2F);
        break;
      case 'Ditangani':
        activeColor = Colors.blue.shade700;
        break;
      case 'Selesai':
        activeColor = Colors.green.shade700;
        break;
      default:
        activeColor = const Color(0xFFB71C1C);
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStatusIndex = index;
          _applyFilters();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : const Color(0xFFEEEEEE),
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(color: activeColor, width: 1.5)
              : Border.all(color: Colors.transparent),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade600,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPER: KARTU GAWAT ---
  Widget _buildGawatCard({
    required Map<String, dynamic> gawat,
    required String jenisDarurat,
    required String nama,
    required String email,
    required String waktu,
    required String status,
  }) {
    Color statusColor;
    Color statusBgColor;

    final normalizedStatus = _normalizeStatus(status);
    if (normalizedStatus == 'Ditangani') {
      statusColor = Colors.blue;
      statusBgColor = Colors.blue.shade50;
    } else if (normalizedStatus == 'Selesai') {
      statusColor = Colors.green;
      statusBgColor = Colors.green.shade50;
    } else {
      statusColor = const Color(0xFFD32F2F);
      statusBgColor = Colors.red.shade50;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.red.withValues(alpha: 0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Baris 1: Ikon & Jenis Darurat & Pill Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.emergency,
                          color: Color(0xFFB71C1C),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        jenisDarurat,
                        style: const TextStyle(
                          color: Color(0xFFB71C1C),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
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
              const SizedBox(height: 16),

              // Baris 2: Detail pelapor
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        nama,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.mail_outline,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          email,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 24),

              // Baris 3: Waktu, Ubah Status, Lihat Detail
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      waktu,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        height: 1.3,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      InkWell(
                        onTap: () => _showUbahStatusBottomSheet(gawat),
                        child: const Row(
                          children: [
                            Text(
                              'Ubah\nStatus',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: Color(0xFFB71C1C),
                                fontSize: 12,
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_down,
                              color: Color(0xFFB71C1C),
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      InkWell(
                        onTap: () => _showDetailDialog(gawat),
                        child: const Row(
                          children: [
                            Text(
                              'Lihat\nDetail',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: Color(0xFFB71C1C),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: Color(0xFFB71C1C),
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
