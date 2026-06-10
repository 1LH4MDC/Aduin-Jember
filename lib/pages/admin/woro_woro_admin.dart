import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'tambah_woro_woro_page.dart'; // Nanti kita buat file ini

class WoroWoroAdmin extends StatelessWidget {
  const WoroWoroAdmin({super.key});

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
      body: Padding(
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
              child: const TextField(
                decoration: InputDecoration(
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
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildWoroItem(
                    title: 'Perbaikan Jalan...',
                    date: '25 Okt 2023',
                    hasImage: true,
                  ),
                  _buildWoroItem(
                    title: 'Vaksinasi Massal...',
                    date: '22 Okt 2023',
                    hasImage: false,
                  ),
                  _buildWoroItem(
                    title: 'Pemadaman Listrik...',
                    date: '20 Okt 2023',
                    hasImage: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // 3. Tombol Tambah (+)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigasi ke halaman Form
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TambahWoroWoroPage(),
            ),
          );
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Widget Bantuan untuk Baris List Woro-Woro
  Widget _buildWoroItem({
    required String title,
    required String date,
    required bool hasImage,
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
                onPressed: () {},
              ),
              const SizedBox(height: 12),
              IconButton(
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}