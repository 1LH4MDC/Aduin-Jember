import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../services/auth_service.dart';
import '../auth/login_page.dart';
import 'edit_profil_page.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  Future<void> _reloadAndNavigateToEdit(BuildContext context, AuthController auth) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfilPage()),
    );
    // Jika edit berhasil (halaman edit mengembalikan true), reload profil
    if (result == true && context.mounted) {
      await auth.loadProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthController>(context);
    final userProfile = auth.profile ?? {};

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.account_balance, color: AppTheme.primaryColor),
          onPressed: () {},
        ),
        title: const Text(
          'Aduin Jember',
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          children: [
            // 1. Foto Profil & Judul
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 42,
                      backgroundColor: const Color(0xFFF0F0F0),
                      backgroundImage: userProfile['fotoProfil'] != null && userProfile['fotoProfil'].toString().isNotEmpty
                          ? NetworkImage(userProfile['fotoProfil'].toString())
                          : null,
                      child: userProfile['fotoProfil'] == null || userProfile['fotoProfil'].toString().isEmpty
                          ? const Icon(Icons.person_outline, size: 40, color: Colors.grey)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    auth.displayName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 2. Data Kartu Informasi Pribadi
            _buildInfoCard('Nama Lengkap', auth.displayName),
            _buildInfoCard('Email', auth.email),
            _buildInfoCard('NIK', userProfile['nik']?.toString() ?? userProfile['phone']?.toString() ?? '-'),
            _buildInfoCard('Alamat Tinggal', userProfile['alamat']?.toString() ?? userProfile['alamatLengkap']?.toString() ?? userProfile['address']?.toString() ?? '-'),
            
            const SizedBox(height: 8),

            // 3. Tombol Edit Akun
            _buildActionCard(
              title: 'Edit Akun',
              subtitle: 'Ubah Nama, NIK & Password',
              onTap: () => _reloadAndNavigateToEdit(context, auth),
            ),

            const SizedBox(height: 32),

            // 4. Tombol Keluar (Logout)
            TextButton.icon(
              onPressed: auth.isBusy
                  ? null
                  : () async {
                      await auth.signOut();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                          (route) => false,
                        );
                      }
                    },
              icon: const Icon(Icons.logout, color: Color(0xFFC62828)),
              label: const Text(
                'Keluar',
                style: TextStyle(
                  color: Color(0xFFC62828),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER: KARTU INFO DATA DIRI ---
  Widget _buildInfoCard(String label, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER: KARTU AKSI (EDIT) ---
  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}