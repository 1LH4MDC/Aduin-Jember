import 'package:flutter/material.dart';
import '../../core/theme.dart';

class TambahWoroWoroPage extends StatefulWidget {
  const TambahWoroWoroPage({super.key});

  @override
  State<TambahWoroWoroPage> createState() => _TambahWoroWoroPageState();
}

class _TambahWoroWoroPageState extends State<TambahWoroWoroPage> {
  String? _selectedKategori;
  final List<String> _kategoriList = ['Infrastruktur', 'Kebersihan', 'Keamanan', 'Kesehatan', 'Lainnya'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
          onPressed: () => Navigator.pop(context),
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
      // SafeArea agar bottom button tidak tertutup area gesture/home bar iPhone
      body: SafeArea(
        child: Column(
          children: [
            // Konten Form (Bisa di-scroll)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Upload Banner
                    _buildLabel('Banner Pengumuman'),
                    Container(
                      width: double.infinity,
                      height: 140,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(12),
                        // Note: Untuk garis putus-putus seperti desain, nanti bisa gunakan package 'dotted_border'
                        border: Border.all(color: Colors.grey.withValues(alpha: 0.4), style: BorderStyle.solid),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.upload_file, color: AppTheme.primaryColor, size: 32),
                          const SizedBox(height: 8),
                          Text(
                            'Unggah Banner Informasi (Rekomendasi 16:9)',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 2. Input Judul
                    _buildLabel('Judul Pengumuman'),
                    _buildTextField(hint: 'Masukkan judul pengumuman...'),
                    const SizedBox(height: 20),

                    // 3. Dropdown Kategori
                    _buildLabel('Kategori'),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.withValues(alpha: 0.4)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedKategori,
                          hint: const Text('Pilih Kategori', style: TextStyle(color: Colors.grey, fontSize: 14)),
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                          items: _kategoriList.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value, style: const TextStyle(fontSize: 14)),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _selectedKategori = newValue;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 4. Tanggal Publikasi
                    _buildLabel('Tanggal Publikasi'),
                    _buildTextField(
                      hint: 'Pilih tanggal...',
                      suffixIcon: const Icon(Icons.calendar_today, color: AppTheme.primaryColor, size: 20),
                      readOnly: true, // Karena ini kalender, keyboard tidak boleh muncul
                    ),
                    const SizedBox(height: 20),

                    // 5. Isi Woro-Woro
                    _buildLabel('Isi Woro-Woro'),
                    _buildTextField(
                      hint: 'Tuliskan detail pengumuman di sini...',
                      maxLines: 5,
                    ),
                  ],
                ),
              ),
            ),

            // Bagian Bawah: Tombol Batal & Simpan (Fixed di bawah)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.withValues(alpha: 0.2))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppTheme.primaryColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Kirim data POST ke API
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: AppTheme.primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text(
                        'Simpan Woro-Woro',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
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

  // Helper Widget untuk Label Title di atas form
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87),
      ),
    );
  }

  // Helper Widget untuk Text Field Standar
  Widget _buildTextField({required String hint, Widget? suffixIcon, int maxLines = 1, bool readOnly = false}) {
    return TextField(
      maxLines: maxLines,
      readOnly: readOnly,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.primaryColor),
        ),
      ),
    );
  }
}