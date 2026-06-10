import 'package:flutter/material.dart';
import '../../core/theme.dart';

// Import ketiga halaman konten
import 'dashboard_user.dart';
import 'profil_page.dart';
import 'sambatku_page.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  // Variabel untuk melacak index menu yang sedang aktif
  int _selectedIndex = 0;

  // Daftar halaman yang akan ditampilkan sesuai urutan index
  final List<Widget> _pages = [
    const DashboardUser(), // Index 0
    const SambatkuPage(), // Index 1
    const ProfilPage(), // Index 2
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack menjaga state halaman agar tidak reset saat berpindah tab
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        // Menggunakan NavigationBar (Material 3) agar otomatis mendapatkan efek pill-shape indicator
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            indicatorColor:
                AppTheme.primaryColor, // Warna kapsul penanda aktif (#0C344D)
            iconTheme: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const IconThemeData(
                  color: Colors.white,
                ); // Warna ikon saat aktif
              }
              return const IconThemeData(
                color: Colors.grey,
              ); // Warna ikon saat tidak aktif
            }),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                );
              }
              return const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: Colors.grey,
              );
            }),
          ),
          child: NavigationBar(
            backgroundColor: Colors.white,
            elevation: 0,
            height: 70, // Tinggi navigasi bar yang proporsional
            selectedIndex: _selectedIndex,
            labelBehavior: NavigationDestinationLabelBehavior
                .alwaysShow, // Teks selalu muncul sesuai contoh UI
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_filled),
                label: 'Beranda',
              ),
              NavigationDestination(
                icon: Icon(Icons.assignment_outlined),
                selectedIcon: Icon(Icons.assignment),
                label: 'Sambatku',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
