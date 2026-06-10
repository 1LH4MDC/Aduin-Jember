import 'package:flutter/material.dart';
import '../../core/theme.dart';

class LaporanAdmin extends StatefulWidget {
  const LaporanAdmin({super.key});

  @override
  State<LaporanAdmin> createState() => _LaporanAdminState();
}

class _LaporanAdminState extends State<LaporanAdmin> {
  // State untuk menyimpan index filter yang sedang aktif
  int _selectedFilterIndex = 0;
  
  // Daftar filter status
  final List<String> _filters = ['Semua', 'Menunggu', 'Diproses', 'Selesai'];

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
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppTheme.primaryColor),
            onPressed: () {
              // TODO: Tampilkan kolom pencarian
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Horizontal Scroll Filter Chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
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
          
          // 2. Daftar Laporan (Sambat)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildSambatCard(
                  kategori: 'INFRASTRUKTUR',
                  judul: 'Jalan Berlubang Parah di Area Patrang',
                  lokasi: 'Jl. Slamet Riyadi, Patrang',
                  waktu: '12 Okt 2023,\n09:45',
                  status: 'DIPROSES',
                  hasImage: true,
                ),
                _buildSambatCard(
                  kategori: 'LINGKUNGAN',
                  judul: 'Penumpukan Sampah di Bantaran Sungai',
                  lokasi: 'Sumbersari, Jember',
                  waktu: '10 Okt 2023,\n14:20',
                  status: 'SELESAI',
                  hasImage: false,
                ),
                _buildSambatCard(
                  kategori: 'INFRASTRUKTUR',
                  judul: 'Lampu Jalan Mati di',
                  lokasi: 'Jl. Hayam Wuruk, Jember',
                  waktu: '08 Okt 2023,\n19:30',
                  status: 'DIPROSES',
                  hasImage: false,
                ),
              ],
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

  // --- WIDGET HELPER: KARTU SAMBAT ---
  Widget _buildSambatCard({
    required String kategori,
    required String judul,
    required String lokasi,
    required String waktu,
    required String status,
    required bool hasImage,
  }) {
    // Menentukan warna pill status
    Color statusColor;
    Color statusBgColor;
    
    if (status == 'MENUNGGU') {
      statusColor = Colors.orange;
      statusBgColor = Colors.orange.shade50;
    } else if (status == 'DIPROSES') {
      statusColor = Colors.blue;
      statusBgColor = Colors.blue.shade50;
    } else {
      statusColor = Colors.green;
      statusBgColor = Colors.green.shade50;
    }

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
                  fontSize: 12,
                  letterSpacing: 1,
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
                child: Icon(
                  hasImage ? Icons.image : Icons.image_outlined,
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
                    onTap: () {
                      // TODO: Tampilkan BottomSheet untuk ubah status
                    },
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
                    onTap: () {
                      // TODO: Navigasi ke halaman Detail Sambat
                    },
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