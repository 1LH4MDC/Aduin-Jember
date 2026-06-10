import 'package:flutter/material.dart';
import '../../core/theme.dart';

class WoroWoroDetailPage extends StatelessWidget {
  final String title;
  final String date;

  const WoroWoroDetailPage({
    super.key,
    required this.title,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        // Custom tombol kembali melingkar sesuai mockup figma
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: const BoxDecoration(
              color: AppTheme.primaryColor, // Warna Navy
              shape: BoxShape.circle,
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text(
          'Woro-Woro',
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Banner Image (Menggunakan ClipRRect agar melengkung presisi)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                height: 200,
                color: const Color(0xFFE0E0E0), // Placeholder abu-abu sebelum API gambar aktif
                child: const Center(
                  child: Icon(Icons.image_outlined, color: Colors.grey, size: 50),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 2. Judul Pengumuman
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 14),

            // 3. Row Kategori & Tanggal
            Row(
              children: [
                // Kapsul Kategori
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Infrastruktur',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Info Tanggal
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      date,
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 4. Card Isi Pengumuman (Bungkus Teks dengan Border Halus)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.25)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pemerintah Kabupaten Jember melalui Dinas Pekerjaan Umum dan Penataan Ruang (PUPR) dengan bangga mengumumkan bahwa proyek perbaikan infrastruktur jalan di kawasan strategis Sumbersari telah resmi selesai.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textPrimary,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Proyek yang dimulai sejak tiga bulan lalu ini mencakup pengaspalan ulang (overlay) sepanjang 2,5 kilometer guna meningkatkan kenyamanan dan keamanan berkendara bagi masyarakat. Pengerjaan ini merupakan bagian dari komitmen "Jember Melesat" untuk memastikan konektivitas antar-kecamatan tetap prima.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}