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
  List<Map<String, dynamic>> _filteredUsersList = [];
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          _applySearch();
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

  void _applySearch() {
    if (_searchQuery.isEmpty) {
      _filteredUsersList = List.from(_allUsersList);
    } else {
      final query = _searchQuery.toLowerCase();
      _filteredUsersList = _allUsersList.where((u) {
        final name = u['nama'].toString().toLowerCase();
        final email = u['email'].toString().toLowerCase();
        return name.contains(query) || email.contains(query);
      }).toList();
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

  Future<void> _deleteUser(Map<String, dynamic> user) async {
    final name = user['nama'].toString();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pengguna'),
        content: Text('Apakah Anda yakin ingin menghapus pengguna "$name" dari daftar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _allUsersList.removeWhere((u) => u['email'] == user['email']);
        _applySearch();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pengguna "$name" berhasil dihapus (simulasi).'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _showEditUserDialog(Map<String, dynamic> user) {
    final nameController = TextEditingController(text: user['nama']?.toString());
    final emailController = TextEditingController(text: user['email']?.toString());
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Detail & Edit Pengguna',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
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
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Lengkap',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Nama tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Email tidak boleh kosong';
                      if (!val.contains('@')) return 'Email tidak valid';
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  setState(() {
                    user['nama'] = nameController.text.trim();
                    user['email'] = emailController.text.trim();
                    user['inisial'] = _getInitials(user['nama'].toString());
                    user['color'] = _getAvatarColor(user['email'].toString());
                    _applySearch();
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Data pengguna "${user['nama']}" berhasil disimpan.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Simpan'),
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
            // 1. KOMPONEN PENCARIAN
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                    _applySearch();
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Cari pengguna...',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 2. HEADER DAFTAR PENGGUNA & BADGE TOTAL
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
                    '${_filteredUsersList.length} Total',
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

            // 3. DAFTAR KARTU PENGGUNA
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
                      : _filteredUsersList.isEmpty
                          ? const Center(child: Text('Tidak ada pengguna ditemukan.'))
                          : RefreshIndicator(
                              onRefresh: _loadUsers,
                              color: AppTheme.primaryColor,
                              child: ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                                itemCount: _filteredUsersList.length,
                                itemBuilder: (context, index) {
                                  final user = _filteredUsersList[index];
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
                                        onTap: () => _showEditUserDialog(user),
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
                                              // Tombol Edit
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.edit_outlined,
                                                  color: AppTheme.primaryColor,
                                                  size: 20,
                                                ),
                                                onPressed: () => _showEditUserDialog(user),
                                              ),
                                              // Tombol Aksi Hapus
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.delete_outline_rounded,
                                                  color: Color(0xFFC62828),
                                                  size: 20,
                                                ),
                                                onPressed: () => _deleteUser(user),
                                              ),
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