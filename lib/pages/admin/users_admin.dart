import 'package:flutter/material.dart';
import '../../core/theme.dart';

class UsersAdmin extends StatelessWidget {
  const UsersAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    // Data dummy pengguna untuk merepresentasikan mockup image_8dc2a3.png
    final List<Map<String, String>> dummyUsers = [
      {
        'nama': 'Bambang Pamungkas',
        'email': 'bambang_p@service.id',
        'inisial': 'BP',
        'color': '0xFF0C344D', // Navy tema utama Anda
      },
      {
        'nama': 'Eko Kusuma',
        'email': 'eko.kusuma@pemkab.id',
        'inisial': 'EK',
        'color': '0xFF00796B', // Hijau tua Pemkab
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Background abu-abu muda bersih
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Users Management',
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
            // 1. KOMPONEN PENCARIAN (SEARCH BAR)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Cari pengguna...',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 2. HEADER DAFTAR PENGGUNA & BADGE TOTAL
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Daftar Pengguna',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor, // Menggunakan Navy Gelap
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${dummyUsers.length} Total',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 3. DAFTAR KARTU PENGGUNA (USER CARD LIST)
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: dummyUsers.length,
                itemBuilder: (context, index) {
                  final user = dummyUsers[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
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
                        // Lingkaran Inisial Nama (Avatar)
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Color(int.parse(user['color']!)),
                          child: Text(
                            user['inisial']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Detail Nama dan Email
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user['nama']!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user['email']!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Tombol Aksi Hapus (Trash)
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: Color(0xFFC62828), // Warna merah hapus presisi
                            size: 22,
                          ),
                          onPressed: () {
                            // TODO: Tambahkan dialog konfirmasi hapus data ke backend
                            debugPrint('Hapus user: ${user['nama']}');
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}