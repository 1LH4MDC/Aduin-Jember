import 'package:aduin_jember/services/auth_service.dart';
import 'package:flutter/material.dart';
import '../../core/theme.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Controller untuk menangkap input data (Nomor Telepon diganti NIK)
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nikController = TextEditingController(); // Perubahan di sini
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // State untuk toggle mata password
  bool _isObscurePass = true;
  bool _isObscureConfirm = true;
  
  // State untuk animasi loading saat memanggil API
  bool _isLoading = false;

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _nikController.dispose(); // Perubahan di sini
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Widget Helper untuk membuat desain "Card Input" yang rapi
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
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                // Menghilangkan border bawaan karena sudah dibungkus Container
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
      backgroundColor: AppTheme.backgroundColor, // Background abu-abu terang
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Daftar Akun Baru',
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Header Texts
              const Text(
                'Daftar Akun Baru',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Lengkapi data diri Anda untuk mulai melapor.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 32),

              // 2. Input Cards
              _buildInputCard(
                label: 'Nama Lengkap',
                hint: 'Masukkan nama lengkap',
                controller: _namaController,
                keyboardType: TextInputType.name,
              ),
              _buildInputCard(
                label: 'Email',
                hint: 'contoh@email.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              // Perubahan: Form Input NIK
              _buildInputCard(
                label: 'NIK',
                hint: 'Masukkan 16 digit NIK',
                controller: _nikController,
                keyboardType: TextInputType.number, // Memunculkan keyboard angka
              ),
              _buildInputCard(
                label: 'Kata Sandi',
                hint: 'Min. 8 karakter',
                controller: _passwordController,
                isPassword: true,
                isObscure: _isObscurePass,
                onToggleObscure: () {
                  setState(() => _isObscurePass = !_isObscurePass);
                },
              ),
              _buildInputCard(
                label: 'Konfirmasi Kata Sandi',
                hint: 'Ulangi kata sandi',
                controller: _confirmPasswordController,
                isPassword: true,
                isObscure: _isObscureConfirm,
                onToggleObscure: () {
                  setState(() => _isObscureConfirm = !_isObscureConfirm);
                },
              ),
              const SizedBox(height: 32),

              // 3. Register Button dengan state Loading & API call
              SizedBox(
                height: 54, 
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () async {
                    // Validasi input kosong
                    if (_namaController.text.isEmpty || 
                        _emailController.text.isEmpty || 
                        _nikController.text.isEmpty || // Tambahan validasi NIK
                        _passwordController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Harap isi data yang wajib (Nama, Email, NIK, Sandi)!')),
                      );
                      return;
                    }
                    
                    // Validasi kecocokan password
                    if (_passwordController.text != _confirmPasswordController.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Kata sandi tidak cocok!')),
                      );
                      return;
                    }

                    setState(() {
                      _isLoading = true;
                    });

                    // Panggil API Register melalui AuthService (phone diganti nik)
                    bool isSuccess = await AuthService.registerUser(
                      nama: _namaController.text,
                      email: _emailController.text,
                      nik: _nikController.text, // Perubahan parameter di sini
                      password: _passwordController.text,
                    );

                    setState(() {
                      _isLoading = false;
                    });

                    if (context.mounted) {
                      if (isSuccess) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Pendaftaran berhasil! Silakan Login.'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pop(context); 
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Pendaftaran gagal. Periksa kembali data Anda atau jaringan Anda.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: _isLoading 
                      ? const SizedBox(
                          width: 24, 
                          height: 24, 
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)
                        )
                      : const Text('Daftar'),
                ),
              ),
              const SizedBox(height: 24),

              // 4. Footer Text
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Sudah punya akun? ',
                    style: TextStyle(color: Colors.grey),
                  ),
                  GestureDetector(
                    onTap: () { 
                      Navigator.pop(context); 
                    },
                    child: const Text(
                      'Masuk di sini',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}