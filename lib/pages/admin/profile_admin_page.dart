import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../services/auth_service.dart';
import '../auth/login_page.dart';
import 'edit_profil_page.dart'; // Sesuaikan jika ada halaman edit khusus admin atau gunakan yang sama

class ProfileAdminPage extends StatefulWidget {
  const ProfileAdminPage({super.key});

  @override
  State<ProfileAdminPage> createState() => _ProfileAdminPageState();
}

class _ProfileAdminPageState extends State<ProfileAdminPage> {
  final _picker = ImagePicker();
  bool _isUploadingPhoto = false;

  Future<void> _pickAndUploadPhoto(AuthController auth) async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;

    setState(() => _isUploadingPhoto = true);
    try {
      final bytes = await picked.readAsBytes();
      await auth.uploadProfilePhoto(
        imageBytes: bytes,
        imageName: picked.name.isNotEmpty ? picked.name : 'profil_admin.jpg',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto profil admin berhasil diperbarui!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal upload foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  Future<void> _reloadAndNavigateToEdit(
      BuildContext context, AuthController auth) async {
    // Navigasi ke halaman edit profil
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfilPage()),
    );
    if (result == true && context.mounted) {
      await auth.loadProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthController>(context);
    final userProfile = auth.profile ?? {};
    final fotoProfilUrl = userProfile['fotoProfil']?.toString() ?? '';
    final hasPhoto = fotoProfilUrl.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profil Utama Admin',
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
            // 1. Foto Profil Admin & Judul
            Center(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Lingkaran luar border
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.primaryColor.withValues(alpha: 0.3),
                            width: 3,
                          ),
                        ),
                      ),
                      // Avatar Utama
                      GestureDetector(
                        onTap: _isUploadingPhoto
                            ? null
                            : () => _pickAndUploadPhoto(auth),
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 44,
                              backgroundColor: const Color(0xFFF0F0F0),
                              backgroundImage:
                                  hasPhoto ? NetworkImage(fotoProfilUrl) : null,
                              child: !hasPhoto
                                  ? const Icon(
                                      Icons.admin_panel_settings_outlined,
                                      size: 40,
                                      color: Colors.grey,
                                    )
                                  : null,
                            ),
                            if (_isUploadingPhoto)
                              Positioned.fill(
                                child: ClipOval(
                                  child: Container(
                                    color: Colors.black45,
                                    child: const Center(
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Tombol Kamera
                      if (!_isUploadingPhoto)
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: GestureDetector(
                            onTap: () => _pickAndUploadPhoto(auth),
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.white,
                                size: 15,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: _isUploadingPhoto
                        ? null
                        : () => _pickAndUploadPhoto(auth),
                    child: Text(
                      _isUploadingPhoto ? 'Mengunggah...' : 'Ubah Foto Profil Admin',
                      style: TextStyle(
                        fontSize: 12,
                        color: _isUploadingPhoto
                            ? Colors.grey
                            : AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                        decorationColor: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    auth.displayName.isNotEmpty ? auth.displayName : 'Administrator',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Akses Tingkat Admin',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 2. Data Kartu Informasi Pribadi Admin
            _buildInfoCard('Nama Lengkap Admin', auth.displayName),
            _buildInfoCard('Email Resmi', auth.email),
            _buildInfoCard(
              'Identitas / NIK / ID Admin',
              userProfile['nik']?.toString() ??
                  userProfile['idAdmin']?.toString() ??
                  '-',
            ),
            const SizedBox(height: 8),

            // 3. Tombol Edit Akun
            _buildActionCard(
              title: 'Edit Akun Admin',
              subtitle: 'Ubah Nama, Kredensial & Keamanan',
              onTap: () => _reloadAndNavigateToEdit(context, auth),
            ),
            const SizedBox(height: 32),

            // 4. Tombol Keluar Sesi
            TextButton.icon(
              onPressed: auth.isBusy
                  ? null
                  : () async {
                      await auth.signOut();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginPage()),
                          (route) => false,
                        );
                      }
                    },
              icon: const Icon(Icons.logout, color: Color(0xFFC62828)),
              label: const Text(
                'Keluar dari Akun',
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
            value.isEmpty ? '-' : value,
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