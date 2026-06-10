// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import '../../core/theme.dart';
// import '../../services/auth_service.dart';
// import '../../services/sambat_service.dart';

// class MyReportsPage extends StatefulWidget {
//   const MyReportsPage({super.key});

//   @override
//   State<MyReportsPage> createState() => _MyReportsPageState();
// }

// class _MyReportsPageState extends State<MyReportsPage> {
//   Future<List<Map<String, dynamic>>>? _futureReports;

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _futureReports ??= _loadReports();
//   }

//   Future<List<Map<String, dynamic>>> _loadReports() async {
//     final auth = context.read<AuthController>();
//     final reportService = ReportService(apiClient: auth.apiClient);
//     return reportService.fetchMyReports(auth.userId);
//   }

//   Future<void> _refresh() async {
//     setState(() {
//       _futureReports = _loadReports();
//     });
//     await _futureReports;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppTheme.backgroundColor,
//       appBar: AppBar(
//         backgroundColor: AppTheme.backgroundColor,
//         elevation: 0,
//         iconTheme: const IconThemeData(color: AppTheme.primaryColor),
//         title: const Text(
//           'Laporan Saya',
//           style: TextStyle(
//             color: AppTheme.primaryColor,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//       body: RefreshIndicator(
//         onRefresh: _refresh,
//         child: FutureBuilder<List<Map<String, dynamic>>>(
//           future: _futureReports,
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(child: CircularProgressIndicator());
//             }

//             final reports = snapshot.data ?? [];
//             if (reports.isEmpty) {
//               return ListView(
//                 physics: const AlwaysScrollableScrollPhysics(),
//                 children: const [
//                   SizedBox(height: 120),
//                   Center(child: Text('Belum ada laporan yang dibuat.')),
//                 ],
//               );
//             }

//             return ListView.separated(
//               physics: const AlwaysScrollableScrollPhysics(),
//               padding: const EdgeInsets.all(20),
//               itemCount: reports.length,
//               separatorBuilder: (context, index) => const SizedBox(height: 14),
//               itemBuilder: (context, index) {
//                 return _ReportCard(report: reports[index]);
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

// class _ReportCard extends StatelessWidget {
//   final Map<String, dynamic> report;

//   const _ReportCard({required this.report});

//   Color _statusColor(String status) {
//     switch (status) {
//       case 'diproses':
//         return Colors.blue;
//       case 'selesai':
//         return Colors.green;
//       case 'ditolak':
//         return Colors.red;
//       default:
//         return Colors.orange;
//     }
//   }

//   String _statusLabel(String status) {
//     switch (status) {
//       case 'diproses':
//         return 'Diproses';
//       case 'selesai':
//         return 'Selesai';
//       case 'ditolak':
//         return 'Ditolak';
//       default:
//         return 'Menunggu';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final photoUrl =
//         report['fotoUrl']?.toString() ?? report['photo_url']?.toString() ?? '';
//     final status = report['status']?.toString() ?? 'pending';

//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           if (photoUrl.isNotEmpty)
//             ClipRRect(
//               borderRadius: const BorderRadius.vertical(
//                 top: Radius.circular(20),
//               ),
//               child: Image.network(photoUrl, height: 180, fit: BoxFit.cover),
//             ),
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Text(
//                         report['judul']?.toString() ??
//                             report['title']?.toString() ??
//                             '-',
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                     Chip(
//                       label: Text(_statusLabel(status)),
//                       backgroundColor: _statusColor(
//                         status,
//                       ).withValues(alpha: 0.12),
//                       labelStyle: TextStyle(
//                         color: _statusColor(status),
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   report['kategori']?.toString() ??
//                       report['category']?.toString() ??
//                       '-',
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   report['alamatLengkap']?.toString() ??
//                       report['address']?.toString() ??
//                       '-',
//                   style: const TextStyle(color: Colors.black54),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
