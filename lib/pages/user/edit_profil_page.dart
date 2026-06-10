import 'package:flutter/material.dart';
import '../../core/theme.dart';

class EditProfilPage extends StatefulWidget {
  const EditProfilPage({super.key});

  @override
  State<EditProfilPage> createState() => _EditProfilPageState();
}

class _EditProfilPageState extends State<EditProfilPage> {
  // Controller untuk form input
  late TextEditingController _namaController;
  late TextEditingController _emailController;
  late TextEditingController _nikController;
  late TextEditingController _alamatController;
  late TextEditingController _oldPasswordController;
  late TextEditingController _newPasswordController;

  // State untuk toggle mata password
  bool _isObscureOld = true;
  bool _isObscureNew = true;
  
  // State animasi loading
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Menginisialisasi controller dengan data dummy agar form tidak kosong saat dibuka
    _namaController = TextEditingController(text: 'ham dc');
    _emailController = TextEditingController(text: 'gg@gmail.com');
    _nikController = TextEditingController(text: '+62 812-XXXX-XXXX');
    _alamatController = TextEditingController(text: 'Kec. Sumbersari, Kab. Jember');
    _oldPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _nikController.dispose();
    _alamatController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  // Widget Helper untuk membuat Card Input yang rapi
  Widget _buildInputCard({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    bool? isObscure,
    VoidCallback? onToggleObscure,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 8, top: 12, bottom: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            TextFormField(
              controller: controller,
              obscureText: isPassword ? (isObscure ?? true) : false,
              keyboardType: keyboardType,
              style: const TextStyle(fontSize: 15, color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                suffixIcon: isPassword
                    ? IconButton(
                        icon: Icon(
                          isObscure! ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                          size: 20,
                        ),
                        onPressed: onToggleObscure,
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          'Edit Akun',
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Konten Form yang bisa di-scroll
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Informasi Pribadi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    _buildInputCard(
                      label: 'Nama Lengkap',
                      hint: 'Masukkan nama Anda',
                      controller: _namaController,
                    ),
                    _buildInputCard(
                      label: 'Email',
                      hint: 'contoh@email.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    _buildInputCard(
                      label: 'NIK / No. Telepon',
                      hint: 'Masukkan NIK atau No. Telepon',
                      controller: _nikController,
                      keyboardType: TextInputType.phone,
                    ),
                    _buildInputCard(
                      label: 'Alamat Tinggal',
                      hint: 'Masukkan alamat domisili',
                      controller: _alamatController,
                    ),

                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFFE0E0E0), thickness: 1),
                    const SizedBox(height: 24),

                    const Text(
                      'Keamanan Akun',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildInputCard(
                      label: 'Kata Sandi Saat Ini',
                      hint: 'Masukkan untuk verifikasi (Opsional)',
                      controller: _oldPasswordController,
                      isPassword: true,
                      isObscure: _isObscureOld,
                      onToggleObscure: () {
                        setState(() => _isObscureOld = !_isObscureOld);
                      },
                    ),
                    _buildInputCard(
                      label: 'Kata Sandi Baru',
                      hint: 'Kosongkan jika tidak ingin diubah',
                      controller: _newPasswordController,
                      isPassword: true,
                      isObscure: _isObscureNew,
                      onToggleObscure: () {
                        setState(() => _isObscureNew = !_isObscureNew);
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Tombol Simpan Fixed di Bawah Layar
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.withValues(alpha: 0.2))),
              ),
              child: SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () async {
                    // Validasi Dasar
                    if (_namaController.text.isEmpty || _emailController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Nama dan Email tidak boleh kosong!')),
                      );
                      return;
                    }

                    setState(() {
                      _isLoading = true;
                    });

                    // TODO: Panggil API PUT /api/profil di sini
                    await Future.delayed(const Duration(seconds: 2)); // Simulasi delay jaringan

                    setState(() {
                      _isLoading = false;
                    });

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profil berhasil diperbarui!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.pop(context); // Kembali ke halaman profil
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text(
                          'Simpan Perubahan',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}