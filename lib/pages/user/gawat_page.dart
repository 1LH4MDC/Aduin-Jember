import 'package:flutter/material.dart';

class GawatPage extends StatelessWidget {
  const GawatPage({super.key});

  @override
  Widget build(BuildContext context) {
    // SingleChildScrollView + BoxConstraints mencegah terjadinya Overflow Error
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Tema Dark Mode pekat
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Container(
            constraints: BoxConstraints(
              // Menyesuaikan tinggi minimal dengan ukuran layar
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. HEADER
                Column(
                  children: [
                    const SizedBox(height: 10),
                    const Text(
                      'PANGGILAN DARURAT',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ketuk tombol di bawah untuk mengirim sinyal SOS',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // 2. TOMBOL SOS (Dengan Efek Glowing)
                _buildSOSButton(),

                const SizedBox(height: 40),

                // 3. KARTU LOKASI (Glassmorphism / Dark Card)
                _buildLocationCard(),

                const SizedBox(height: 32),

                // 4. TOMBOL PANGGILAN CEPAT
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PANGGILAN CEPAT DARURAT',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildQuickCallBtn(
                          icon: Icons.local_police,
                          label: 'Polisi',
                          number: '110',
                          color: Colors.blue.shade400,
                        ),
                        _buildQuickCallBtn(
                          icon: Icons.medical_services,
                          label: 'Ambulans',
                          number: '119',
                          color: Colors.green.shade400,
                        ),
                        _buildQuickCallBtn(
                          icon: Icons.local_fire_department,
                          label: 'Damkar',
                          number: '113',
                          color: Colors.orange.shade400,
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // 5. TOMBOL BATAL & DISCLAIMER
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white, size: 20),
                        label: const Text(
                          'BATALKAN MODE GAWAT',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade800, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Gunakan hanya dalam keadaan darurat yang mengancam jiwa.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPER: TOMBOL SOS GLOWING ---
  Widget _buildSOSButton() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Ripple Paling Luar
        Container(
          width: 260,
          height: 260,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.red.withValues(alpha: 0.05),
          ),
        ),
        // Ripple Tengah
        Container(
          width: 210,
          height: 210,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.red.withValues(alpha: 0.15),
          ),
        ),
        // Tombol Merah Solid
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // TODO: Logika Trigger SOS
            },
            customBorder: const CircleBorder(),
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFD32F2F), // Merah Kuat
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withValues(alpha: 0.4),
                    blurRadius: 25,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'SOS',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 2.0,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'TEKAN',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- WIDGET HELPER: KARTU LOKASI ---
  Widget _buildLocationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), // Warna abu-abu gelap
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.my_location, color: Colors.redAccent, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lokasi Anda Saat Ini',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '-8.1724, 113.6995 (Jember)', // Diambil dinamis nanti
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 13,
                    fontFamily: 'monospace', // Efek teks koordinat
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER: TOMBOL PANGGILAN CEPAT ---
  Widget _buildQuickCallBtn({
    required IconData icon,
    required String label,
    required String number,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        child: Material(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () {
              // TODO: Aksi Panggilan Telepon
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade800),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    number,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}