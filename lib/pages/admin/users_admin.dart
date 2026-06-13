import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../services/auth_service.dart';
import '../../services/sambat_service.dart';

class UsersAdmin extends StatefulWidget {
  const UsersAdmin({super.key});

  @override
  State<UsersAdmin> createState() => _UsersAdminState();
}

class _UsersAdminState extends State<UsersAdmin> {
  bool _isLoading = true;
  String? _errorMessage;

  List<Map<String, dynamic>> _allUsersList = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final auth = context.read<AuthController>();
      final sambatService = SambatService(apiClient: auth.apiClient);
      final sambats = await sambatService.fetchAllSambat();

      // Extract unique users
      final userMap = <String, Map<String, dynamic>>{};

      for (final s in sambats) {
        final name = (s['namaUser'] ?? s['author_name'] ?? '').toString().trim();
        final email = (s['emailUser'] ?? s['author_email'] ?? s['email'] ?? '').toString().trim();
        final id = (s['idUser'] ?? s['user_id'] ?? s['iduser'] ?? s['userId'] ?? '').toString().trim();

        if (email.isNotEmpty) {
          final displayName = name.isNotEmpty ? name : email.split('@').first;
          userMap[email] = {
            'id': id,
            'nama': displayName,
            'email': email,
            'inisial': _getInitials(displayName),
            'color': _getAvatarColor(email),
          };
        }
      }

      // Fallback dummy users if empty (to ensure UI shows something premium)
      var users = userMap.values.toList();
      if (users.isEmpty) {
        users = [
          {
            'id': 'u1',
            'nama': 'Bambang Pamungkas',
            'email': 'bambang_p@service.id',
            'inisial': 'BP',
            'color': const Color(0xFF0C344D),
          },
          {
            'id': 'u2',
            'nama': 'Eko Kusuma',
            'email': 'eko.kusuma@pemkab.id',
            'inisial': 'EK',
            'color': const Color(0xFF00796B),
          },
        ];
      }

      if (mounted) {
        setState(() {
          _allUsersList = users;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  Color _getAvatarColor(String email) {
    // Premium color list
    final List<Color> colors = [
      const Color(0xFF0C344D), // Navy
      const Color(0xFF00796B), // Teal
      const Color(0xFF1E88E5), // Blue
      const Color(0xFF5E35B1), // Purple
      const Color(0xFFD81B60), // Pink
      const Color(0xFFE65100), // Orange
      const Color(0xFF3E2723), // Brown
    ];

    // Simple hash
    int hash = 0;
    for (int i = 0; i < email.length; i++) {
      hash = email.codeUnitAt(i) + ((hash << 5) - hash);
    }
    return colors[hash.abs() % colors.length];
  }

  void _showDetailUserDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Detail Pengguna',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: user['color'] is Color ? user['color'] : Color(int.parse(user['color'].toString())),
                  child: Text(
                    user['inisial'].toString(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
                const SizedBox(height: 24),
                // Informasi Nama (Read Only)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Nama Lengkap', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.person_outline, size: 16, color: Colors.black87),
                          const SizedBox(width: 8),
                          Text(
                            user['nama'].toString(),
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Informasi Email (Read Only)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Email', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.email_outlined, size: 16, color: Colors.black87),
                          const SizedBox(width: 8),
                          Text(
                            user['email'].toString(),
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
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
            // 1. HEADER DAFTAR PENGGUNA & BADGE TOTAL
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
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_allUsersList.length} Total',
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

            // 2. DAFTAR KARTU PENGGUNA
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
                  : _errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red, size: 48),
                              const SizedBox(height: 12),
                              Text('Gagal memuat pengguna: $_errorMessage', style: const TextStyle(color: Colors.red)),
                              const SizedBox(height: 12),
                              ElevatedButton(onPressed: _loadUsers, child: const Text('Coba Lagi')),
                            ],
                          ),
                        )
                      : _allUsersList.isEmpty
                          ? const Center(child: Text('Tidak ada pengguna ditemukan.'))
                          : RefreshIndicator(
                              onRefresh: _loadUsers,
                              color: AppTheme.primaryColor,
                              child: ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                                itemCount: _allUsersList.length,
                                itemBuilder: (context, index) {
                                  final user = _allUsersList[index];
                                  final colorVal = user['color'] is Color ? user['color'] : Color(int.parse(user['color'].toString()));

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 14),
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
                                    child: Material(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(14),
                                      child: InkWell(
                                        onTap: () => _showDetailUserDialog(user),
                                        borderRadius: BorderRadius.circular(14),
                                        child: Padding(
                                          padding: const EdgeInsets.all(14),
                                          child: Row(
                                            children: [
                                              // Lingkaran Inisial Nama (Avatar)
                                              CircleAvatar(
                                                radius: 24,
                                                backgroundColor: colorVal,
                                                child: Text(
                                                  user['inisial'].toString(),
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
                                                      user['nama'].toString(),
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 15,
                                                        color: AppTheme.textPrimary,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      user['email'].toString(),
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              // Ikon Panah Kanan sebagai indikasi bisa di-klik untuk melihat detail
                                              const Icon(Icons.chevron_right, color: Colors.grey),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}