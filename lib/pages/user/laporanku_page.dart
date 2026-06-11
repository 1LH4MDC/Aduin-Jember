import 'package:flutter/material.dart';
import '../../core/theme.dart';
import './create_laporan_page.dart'; // Import form laporan

class LaporankuPage extends StatefulWidget {
  const LaporankuPage({super.key});

  @override
  State<LaporankuPage> createState() => _LaporankuPageState();
}

class _LaporankuPageState extends State<LaporankuPage> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['Semua', 'Menunggu', 'Diproses', 'Selesai'];

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
          style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 18),
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
                  'Laporanku',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pantau status laporan yang Anda kirimkan.',
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

          // List Laporan
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildReportCard(
                  kategori: 'INFRASTRUKTUR',
                  judul: 'Jalan Berlubang di Sumbersari',
                  lokasi: 'Sumbersari, Jember',
                  status: 'Menunggu',
                  hasImage: true,
                  date: '', // Tanggal ada di dalam gambar pada desain
                ),
                _buildReportCard(
                  kategori: 'KEBERSIHAN',
                  judul: 'Tumpukan Sampah Liar',
                  lokasi: '',
                  status: 'Diproses',
                  hasImage: false,
                  date: '10 Okt 2023',
                ),
                _buildReportCard(
                  kategori: 'FASILITAS UMUM',
                  judul: 'Lampu mastrip Mati',
                  lokasi: '',
                  status: 'Selesai',
                  hasImage: false,
                  date: 'Selesai 08 Okt 2023',
                ),
              ],
            ),
          ),
        ],
      ),
      // Floating Action Button (+)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateSambatPage()),
          );
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
    required bool hasImage,
    required String date,
  }) {
    Color statusColor = status == 'Menunggu' ? Colors.grey.shade700 : (status == 'Diproses' ? Colors.orange.shade700 : Colors.green.shade700);
    Color statusBg = status == 'Menunggu' ? Colors.grey.shade200 : (status == 'Diproses' ? Colors.orange.shade50 : Colors.green.shade50);

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
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.image, color: Colors.grey),
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
                    Text(kategori, style: const TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(12)),
                      child: Text(status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(judul, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                if (lokasi.isNotEmpty)
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(lokasi, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                if (date.isNotEmpty)
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(date, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}