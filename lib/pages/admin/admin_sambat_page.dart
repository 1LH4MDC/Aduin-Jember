import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../services/auth_service.dart';
import '../../services/sambat_service.dart';

class AdminSambatPage extends StatefulWidget {
  const AdminSambatPage({super.key});

  @override
  State<AdminSambatPage> createState() => _AdminSambatPageState();
}

class _AdminSambatPageState extends State<AdminSambatPage> {
  Future<List<Map<String, dynamic>>>? _futureSambat;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = context.read<AuthController>();
    if (!auth.isAdmin) {
      return;
    }
    _futureSambat ??= _loadSambat();
  }

  Future<List<Map<String, dynamic>>> _loadSambat() async {
    final auth = context.read<AuthController>();
    final sambatService = SambatService(apiClient: auth.apiClient);
    return sambatService.fetchAllSambat();
  }

  Future<void> _refresh() async {
    setState(() {
      _futureSambat = _loadSambat();
    });
    await _futureSambat;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    if (!auth.isAdmin) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppTheme.backgroundColor,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppTheme.primaryColor),
          title: const Text(
            'Panel Admin',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: const Center(
          child: Text('Anda tidak memiliki akses ke halaman admin.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.primaryColor),
        title: const Text(
          'Admin Sambat',
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _futureSambat,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final sambat = snapshot.data ?? [];
            if (sambat.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('Belum ada sambat masuk.')),
                ],
              );
            }

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              itemCount: sambat.length,
              separatorBuilder: (context, index) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                return _AdminSambatCard(
                  sambat: sambat[index],
                  onSaved: _refresh,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _AdminSambatCard extends StatefulWidget {
  final Map<String, dynamic> sambat;
  final Future<void> Function() onSaved;

  const _AdminSambatCard({required this.sambat, required this.onSaved});

  @override
  State<_AdminSambatCard> createState() => _AdminSambatCardState();
}

class _AdminSambatCardState extends State<_AdminSambatCard> {
  final List<String> _statuses = const [
    'Menunggu',
    'Proses',
    'Selesai',
    'Ditolak',
  ];
  bool _isSaving = false;
  late String _selectedStatus;

  @override
  void initState() {
    super.initState();
    _selectedStatus = _normalizeStatus(
      widget.sambat['status']?.toString() ?? 'Menunggu',
    );
  }

  String _normalizeStatus(String status) {
    switch (status.toLowerCase()) {
      case 'diproses':
      case 'proses':
        return 'Proses';
      case 'selesai':
        return 'Selesai';
      case 'ditolak':
        return 'Ditolak';
      default:
        return 'Menunggu';
    }
  }

  String _statusToApiValue(String status) {
    switch (status) {
      case 'Proses':
        return 'diproses';
      case 'Selesai':
        return 'selesai';
      case 'Ditolak':
        return 'ditolak';
      default:
        return 'pending';
    }
  }

  String _statusLabel(String status) => status;

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthController>();
    final sambatService = SambatService(apiClient: auth.apiClient);
    final photoUrl =
        widget.sambat['fotoUrl']?.toString() ??
        widget.sambat['photo_url']?.toString() ??
        '';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (photoUrl.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: Image.network(photoUrl, height: 180, fit: BoxFit.cover),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.sambat['judul']?.toString() ??
                      widget.sambat['title']?.toString() ??
                      '-',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.sambat['namaUser']?.toString() ??
                      widget.sambat['author_name']?.toString() ??
                      '-',
                ),
                Text(
                  widget.sambat['emailUser']?.toString() ??
                      widget.sambat['author_email']?.toString() ??
                      '-',
                ),
                const SizedBox(height: 8),
                Text(
                  widget.sambat['alamatLengkap']?.toString() ??
                      widget.sambat['address']?.toString() ??
                      '-',
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _selectedStatus,
                  items: _statuses
                      .map(
                        (status) => DropdownMenuItem<String>(
                          value: status,
                          child: Text(_statusLabel(status)),
                        ),
                      )
                      .toList(),
                  onChanged: _isSaving
                      ? null
                      : (value) {
                          if (value != null) {
                            setState(() => _selectedStatus = value);
                          }
                        },
                  decoration: const InputDecoration(labelText: 'Ubah Status'),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSaving
                        ? null
                        : () async {
                            setState(() => _isSaving = true);
                            try {
                              await sambatService.updateStatus(
                                sambatId:
                                    widget.sambat['idSambat']?.toString() ??
                                    widget.sambat['id']?.toString() ??
                                    '',
                                status: _statusToApiValue(_selectedStatus),
                              );
                              await widget.onSaved();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Status sambat diperbarui.'),
                                  ),
                                );
                              }
                            } catch (error) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(error.toString())),
                                );
                              }
                            } finally {
                              if (mounted) {
                                setState(() => _isSaving = false);
                              }
                            }
                          },
                    child: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Simpan Status'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
