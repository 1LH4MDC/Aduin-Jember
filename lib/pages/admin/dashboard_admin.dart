import 'package:flutter/material.dart';
import '../../core/theme.dart';

class DashboardAdmin extends StatelessWidget {
  const DashboardAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Latar belakang abu-abu sangat muda bersih
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Aduin Jember',
          style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Salam Admin
            const Text(
              'Halo, Admin!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 4),
            const Text(
              'Selamat bertugas hari ini.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // 2. Grid Statistik Ringkas (2x2)
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.2, // Mengatur proporsi kotak agar tidak terlalu tinggi
              children: [
                _buildStatCard(
                  icon: Icons.description,
                  iconColor: AppTheme.primaryColor,
                  label: 'Total Laporan\nMasuk',
                  count: '7',
                  badgeColor: const Color(0xFFE4E6FB),
                ),
                _buildStatCard(
                  icon: Icons.emergency,
                  iconColor: const Color(0xFFB71C1C),
                  label: 'Laporan Darurat /\nGawat',
                  count: '1',
                  badgeColor: const Color(0xFFFFEBEE),
                  isEmergency: true,
                ),
                _buildStatCard(
                  icon: Icons.campaign,
                  iconColor: Colors.green.shade700,
                  label: 'Woro-Woro\nAktif',
                  count: '3',
                  badgeColor: Colors.green.shade50,
                ),
                _buildStatCard(
                  icon: Icons.people,
                  iconColor: Colors.grey.shade700,
                  label: 'Total\nPengguna',
                  count: '5',
                  badgeColor: Colors.grey.shade100,
                ),
              ],
            ),
            const SizedBox(height: 28),

            // 3. Header Laporan Terbaru
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Laporan Terbaru',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'LIHAT SEMUA',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primaryColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // 4. List Laporan
            _buildRecentReportItem(
              title: 'Jalan Berlubang di...',
              date: '24 Okt 2023, 10:30 WIB',
              statusText: 'Menunggu',
              statusColor: Colors.orange,
            ),
            _buildRecentReportItem(
              title: 'Lampu PJU Mati di Kaliwates',
              date: '23 Okt 2023, 19:15 WIB',
              statusText: 'Diproses',
              statusColor: Colors.blue,
            ),
            _buildRecentReportItem(
              title: 'Pohon Tumbang Jl. Hayam...',
              date: '22 Okt 2023, 08:45 WIB',
              statusText: 'Selesai',
              statusColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER: KARTU STATISTIK (DENGAN AKSEN LINGKARAN POJOK) ---
  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String count,
    required Color badgeColor,
    bool isEmergency = false,
  }) {
    return Container(
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
            // Aksen Lingkaran Background Angka di Pojok Kanan Atas
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
            // Angka Statistik di Pojok Kanan Atas
            Positioned(
              top: 12,
              right: 16,
              child: Text(
                count,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isEmergency ? const Color(0xFFB71C1C) : AppTheme.textPrimary,
                ),
              ),
            ),
            // Konten Utama Ikon & Teks Label
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
                      color: isEmergency ? const Color(0xFFB71C1C) : Colors.black87,
                      height: 1.3,
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

  // --- WIDGET HELPER: BARIS LIST LAPORAN TERBARU ---
  Widget _buildRecentReportItem({
    required String title,
    required String date,
    required String statusText,
    required Color statusColor,
  }) {
    return Container(
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
          // Bagian Kiri: Judul & Tanggal Laporan
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey),
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
          // Bagian Kanan: Kapsul Status (Pill Status)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              statusText,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor),
            ),
          ),
        ],
      ),
    );
  }
}