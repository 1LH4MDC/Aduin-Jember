import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../services/auth_service.dart';
import '../../services/sambat_service.dart';

class AdminReportsPage extends StatefulWidget {
  const AdminReportsPage({super.key});

  @override
  State<AdminReportsPage> createState() => _AdminReportsPageState();
}

class _AdminReportsPageState extends State<AdminReportsPage> {
  Future<List<Map<String, dynamic>>>? _futureReports;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = context.read<AuthController>();
    if (!auth.isAdmin) {
      return;
    }
    _futureReports ??= _loadReports();
  }

  Future<List<Map<String, dynamic>>> _loadReports() async {
    final auth = context.read<AuthController>();
    final reportService = SambatService(apiClient: auth.apiClient);
    return reportService.fetchAllSambat();
  }

  Future<void> _refresh() async {
    setState(() {
      _futureReports = _loadReports();
    });
    await _futureReports;
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
          'Panel Admin',
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _futureReports,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final reports = snapshot.data ?? [];
            if (reports.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('Belum ada laporan masuk.')),
                ],
              );
            }

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              itemCount: reports.length,
              separatorBuilder: (context, index) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                return _AdminReportCard(
                  report: reports[index],
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

class _AdminReportCard extends StatefulWidget {
  final Map<String, dynamic> report;
  final Future<void> Function() onSaved;

  const _AdminReportCard({required this.report, required this.onSaved});

  @override
  State<_AdminReportCard> createState() => _AdminReportCardState();
}

class _AdminReportCardState extends State<_AdminReportCard> {
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
      widget.report['status']?.toString() ?? 'Menunggu',
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
        widget.report['fotoUrl']?.toString() ??
        widget.report['photo_url']?.toString() ??
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
                  widget.report['judul']?.toString() ??
                      widget.report['title']?.toString() ??
                      '-',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.report['namaUser']?.toString() ??
                      widget.report['author_name']?.toString() ??
                      '-',
                ),
                Text(
                  widget.report['emailUser']?.toString() ??
                      widget.report['author_email']?.toString() ??
                      '-',
                ),
                const SizedBox(height: 8),
                Text(
                  widget.report['alamatLengkap']?.toString() ??
                      widget.report['address']?.toString() ??
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
                                    widget.report['idSambat']?.toString() ??
                                    widget.report['id']?.toString() ??
                                    '',
                                status: _statusToApiValue(_selectedStatus),
                              );
                              await widget.onSaved();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Status laporan diperbarui.'),
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
