import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../sambat/create_sambat_page.dart';
import '../sambat/my_sambat_page.dart';

class DashboardUser extends StatelessWidget {
  const DashboardUser({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background putih bersih sesuai desain
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // 1. Search Bar
            _buildSearchBar(),
            const SizedBox(height: 24),

            // 2. Woro-Woro Jember (Horizontal List)
            const Text(
              'Woro-Woro Jember',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildWoroWoroList(),
            const SizedBox(height: 24),

            // 3. Fitur Utama
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

            // 4. Gawat (SOS)
            _buildGawatButton(),
            const SizedBox(height: 30), // Spasi bawah
          ],
        ),
      ),
    );
  }

  // --- KOMPONEN HEADER ---
  PreferredSizeWidget _buildAppBar() {
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
        onPressed: () {},
      ),
      title: const Column(
        children: [
          Text(
            'Aduin Jember',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Text(
            'Halo, Warga Jember!',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  // --- KOMPONEN SEARCH BAR ---
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Cari informasi atau sambat...',
          hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  // --- KOMPONEN WORO-WORO (HORIZONTAL SCROLL) ---
  Widget _buildWoroWoroList() {
    final List<Map<String, String>> dummyWoro = [
      {'date': '15 Okt 2023', 'title': 'Perbaikan Jalan Selesai'},
      {'date': '12 Okt 2023', 'title': 'Festival Jember Nusantara'},
    ];

    return SizedBox(
      height: 180, // Tinggi card
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: dummyWoro.length,
        itemBuilder: (context, index) {
          final item = dummyWoro[index];
          return Container(
            width: 240, // Lebar card
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bagian Gambar Placeholder (Abu-abu seperti referensi)
                Container(
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE0E0E0), // Warna placeholder gambar
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.image_outlined,
                      color: Colors.grey,
                      size: 40,
                    ),
                  ),
                ),
                // Bagian Teks
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['date']!,
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['title']!,
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
          );
        },
      ),
    );
  }

  // --- KOMPONEN FITUR UTAMA (SAMBAT & TRACKING) ---
  Widget _buildFiturUtama(BuildContext context) {
    return Row(
      children: [
        // Card Sambat
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
            subtitle: 'Lapor Jalan Rusak, Sampah, dll',
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
        // Card Tracking
        Expanded(
          child: _buildFiturCard(
            backgroundColor: const Color(0xFFE4E6FB), // Warna ungu/biru pudar
            textColor: AppTheme.primaryColor,
            iconRow: const Icon(
              Icons.manage_search_rounded,
              color: AppTheme.primaryColor,
              size: 32,
            ),
            title: 'TRACKING',
            subtitle: 'Pantau kemajuan sambat Anda',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (_) => const MySambatPage()),
              );
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

  // --- KOMPONEN GAWAT DARURAT ---
  Widget _buildGawatButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFB71C1C), // Merah gelap
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Logo lingkaran SOS putih
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
          // Teks keterangan
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
    );
  }
}
