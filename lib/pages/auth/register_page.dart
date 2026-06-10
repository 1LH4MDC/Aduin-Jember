import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../services/api_client.dart';
import '../../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isObscurePass = true;
  bool _isObscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _nikController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty ||
        _nikController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama, email, NIK, dan kata sandi wajib diisi.'),
        ),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Kata sandi tidak cocok.')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await context.read<AuthController>().signUp(
        fullName: _nameController.text,
        email: _emailController.text,
        nik: _nikController.text,
        password: _passwordController.text,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pendaftaran berhasil. Silakan masuk.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } on ApiException catch (error) {
      if (mounted) {
        debugPrint('Register failed (${error.statusCode}): ${error.body}');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_registerErrorMessage(error))));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _registerErrorMessage(ApiException error) {
    if (error.statusCode == 409) {
      return 'Email sudah terdaftar.';
    }

    if (error.isServerError) {
      return 'Pendaftaran belum berhasil karena server mengembalikan error ${error.statusCode}. Cek log Railway untuk detailnya.';
    }

    return error.message;
  }

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
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 0,
                ),
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
      backgroundColor: AppTheme.backgroundColor,
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
              _buildInputCard(
                label: 'Nama Lengkap',
                hint: 'Masukkan nama lengkap',
                controller: _nameController,
                keyboardType: TextInputType.name,
              ),
              _buildInputCard(
                label: 'Email',
                hint: 'contoh@email.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              _buildInputCard(
                label: 'NIK',
                hint: 'Masukkan 16 digit NIK',
                controller: _nikController,
                keyboardType: TextInputType.number,
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
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text('Daftar'),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Sudah punya akun? ',
                    style: TextStyle(color: Colors.grey),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
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
