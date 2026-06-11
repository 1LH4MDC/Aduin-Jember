import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class CreateSambatPage extends StatefulWidget {
  const CreateSambatPage({super.key});

  @override
  State<CreateSambatPage> createState() => _CreateSambatPageState();
}

class _CreateSambatPageState extends State<CreateSambatPage> {
  String? _selectedKategori;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: const BoxDecoration(color: AppTheme.primaryColor, shape: BoxShape.circle),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text(
          'Sambat',
          style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Buat Laporan Baru', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Sampaikan keluhan Anda untuk Jember yang lebih baik.', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            const SizedBox(height: 24),

            _buildLabel('Judul Laporan'),
            _buildTextField(hint: 'Contoh: Jalan berlubang parah di Kaliwates'),

            _buildLabel('Kategori Laporan'),
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedKategori,
                  hint: const Text('Pilih Kategori', style: TextStyle(color: Colors.grey, fontSize: 14)),
                  isExpanded: true,
                  items: ['Infrastruktur', 'Kebersihan', 'Fasilitas Umum'].map((String value) {
                    return DropdownMenuItem<String>(value: value, child: Text(value, style: const TextStyle(fontSize: 14)));
                  }).toList(),
                  onChanged: (newValue) => setState(() => _selectedKategori = newValue),
                ),
              ),
            ),

            _buildLabel('Deskripsi Kejadian'),
            _buildTextField(hint: 'Jelaskan detail kejadian, kondisi, dan dampaknya...', maxLines: 4),

            _buildLabel('Foto Bukti (Wajib)'),
            Container(
              width: double.infinity,
              height: 80,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.camera_alt, color: AppTheme.primaryColor),
                  const SizedBox(height: 4),
                  Text('Ambil Foto Bukti', style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            // Preview Foto (Placeholder)
            Container(
              width: double.infinity,
              height: 140,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(8)),
              child: Stack(
                children: [
                  const Center(child: Icon(Icons.image, size: 50, color: Colors.grey)),
                  Positioned(
                    top: 8, right: 8,
                    child: CircleAvatar(radius: 12, backgroundColor: Colors.black54, child: const Icon(Icons.close, size: 16, color: Colors.white)),
                  ),
                  Positioned(
                    bottom: 8, left: 8,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('24 Okt 2023, 14:30 WIB', style: TextStyle(color: Colors.white, fontSize: 10)),
                        Text('-8.1724, 113.6995 (Akurasi: 5m)', style: TextStyle(color: Colors.white, fontSize: 10)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLabel('Lokasi Kejadian'),
                const Text('Deteksi Lokasi', style: TextStyle(color: AppTheme.primaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
            
            // Peta Placeholder
            Container(
              height: 100,
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(color: Colors.teal.shade100, borderRadius: BorderRadius.circular(8)),
              child: const Center(child: Icon(Icons.location_on, color: Colors.red, size: 40)),
            ),
            _buildTextField(hint: 'Jl. Gajah Mada No. 1, Kaliwates, Jember', icon: Icons.location_on_outlined),

            // Banner Offline
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(color: Colors.orange.shade200, borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: const [
                  Icon(Icons.wifi_off, color: Colors.black87, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text('Jika offline, laporan disimpan dulu di perangkat dan dikirim otomatis saat ada sinyal.', style: TextStyle(fontSize: 11, color: Colors.black87)),
                  ),
                ],
              ),
            ),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('Kirim Laporan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    SizedBox(width: 8),
                    Icon(Icons.send, color: Colors.white, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87)),
    );
  }

  Widget _buildTextField({required String hint, int maxLines = 1, IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
          prefixIcon: icon != null ? Icon(icon, color: Colors.grey, size: 20) : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.primaryColor)),
        ),
      ),
    );
  }
}