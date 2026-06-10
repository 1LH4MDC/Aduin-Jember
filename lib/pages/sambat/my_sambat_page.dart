import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../services/auth_service.dart';
import '../../services/sambat_service.dart';

class MySambatPage extends StatefulWidget {
  const MySambatPage({super.key});

  @override
  State<MySambatPage> createState() => _MySambatPageState();
}

class _MySambatPageState extends State<MySambatPage> {
  Future<List<Map<String, dynamic>>>? _futureSambat;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _futureSambat ??= _loadSambat();
  }

  Future<List<Map<String, dynamic>>> _loadSambat() async {
    final auth = context.read<AuthController>();
    final sambatService = SambatService(apiClient: auth.apiClient);
    return sambatService.fetchMySambat(auth.userId);
  }

  Future<void> _refresh() async {
    setState(() {
      _futureSambat = _loadSambat();
    });
    await _futureSambat;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.primaryColor),
        title: const Text(
          'Sambat Saya',
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
                  Center(child: Text('Belum ada sambat yang dibuat.')),
                ],
              );
            }

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              itemCount: sambat.length,
              separatorBuilder: (context, index) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                return _SambatCard(sambat: sambat[index]);
              },
            );
          },
        ),
      ),
    );
  }
}

class _SambatCard extends StatelessWidget {
  final Map<String, dynamic> sambat;

  const _SambatCard({required this.sambat});

  Color _statusColor(String status) {
    switch (status) {
      case 'diproses':
        return Colors.blue;
      case 'selesai':
        return Colors.green;
      case 'ditolak':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'diproses':
        return 'Diproses';
      case 'selesai':
        return 'Selesai';
      case 'ditolak':
        return 'Ditolak';
      default:
        return 'Menunggu';
    }
  }

  @override
  Widget build(BuildContext context) {
    final photoUrl =
        sambat['fotoUrl']?.toString() ?? sambat['photo_url']?.toString() ?? '';
    final status = sambat['status']?.toString() ?? 'pending';

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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        sambat['judul']?.toString() ??
                            sambat['title']?.toString() ??
                            '-',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Chip(
                      label: Text(_statusLabel(status)),
                      backgroundColor: _statusColor(
                        status,
                      ).withValues(alpha: 0.12),
                      labelStyle: TextStyle(
                        color: _statusColor(status),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  sambat['kategori']?.toString() ??
                      sambat['category']?.toString() ??
                      '-',
                ),
                const SizedBox(height: 8),
                Text(
                  sambat['alamatLengkap']?.toString() ??
                      sambat['address']?.toString() ??
                      '-',
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
