import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../services/auth_service.dart';
import '../../services/gawat_service.dart';

class GawatPage extends StatefulWidget {
  const GawatPage({super.key});

  @override
  State<GawatPage> createState() => _GawatPageState();
}

class _GawatPageState extends State<GawatPage> {
  double? _latitude;
  double? _longitude;
  String? _address;
  bool _isResolvingLocation = false;
  bool _isSendingSOS = false;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    setState(() {
      _isResolvingLocation = true;
      _locationError = null;
    });

    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        throw Exception('Izin lokasi belum diberikan.');
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      _latitude = position.latitude;
      _longitude = position.longitude;

      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        final first = placemarks.isNotEmpty ? placemarks.first : null;
        final parts = <String?>[
          first?.street,
          first?.subLocality,
          first?.locality,
          first?.administrativeArea,
        ].whereType<String>().where((item) => item.trim().isNotEmpty).toList();

        _address = parts.isEmpty ? 'Jember' : parts.join(', ');
      } catch (_) {
        _address = 'Jember';
      }
    } catch (e) {
      _locationError = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (mounted) {
        setState(() {
          _isResolvingLocation = false;
        });
      }
    }
  }

  Future<void> _makeCall(String number) async {
    final Uri url = Uri(scheme: 'tel', path: number);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        throw 'Tidak dapat memanggil nomor $number';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuka aplikasi telepon: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _triggerSOS() async {
    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Lokasi belum berhasil dimuat. Silakan tunggu atau ketuk kartu lokasi untuk memuat ulang.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final auth = context.read<AuthController>();
    String selectedType = 'Kecelakaan';
    final List<String> emergencyTypes = ['Kecelakaan', 'Kriminal', 'Bencana'];

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Konfirmasi Sinyal SOS',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pilih jenis darurat dan konfirmasi untuk mengirimkan sinyal SOS ke admin.',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Jenis Darurat:',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade800),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedType,
                        dropdownColor: const Color(0xFF2E2E2E),
                        style: const TextStyle(color: Colors.white),
                        iconEnabledColor: Colors.white,
                        isExpanded: true,
                        items: emergencyTypes.map((String type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          if (value != null) {
                            setDialogState(() {
                              selectedType = value;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('BATAL', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD32F2F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text(
                    'KIRIM SOS',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed != true) return;

    setState(() {
      _isSendingSOS = true;
    });

    try {
      final gawatService = GawatService(apiClient: auth.apiClient);

      await gawatService.sendSOS(
        jenisDarurat: selectedType,
        latitude: _latitude!,
        longitude: _longitude!,
      );

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text('Berhasil', style: TextStyle(color: Colors.white)),
              ],
            ),
            content: const Text(
              'Sinyal SOS berhasil dikirim ke admin. Tetap tenang dan tunggu bantuan.',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengirim SOS: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSendingSOS = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Tema Dark Mode pekat
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Container(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. HEADER
                Column(
                  children: [
                    const SizedBox(height: 10),
                    const Text(
                      'PANGGILAN DARURAT',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ketuk tombol di bawah untuk mengirim sinyal SOS',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // 2. TOMBOL SOS (Dengan Efek Glowing)
                _buildSOSButton(),

                const SizedBox(height: 40),

                // 3. KARTU LOKASI (Glassmorphism / Dark Card)
                _buildLocationCard(),

                const SizedBox(height: 32),

                // 4. TOMBOL PANGGILAN CEPAT
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PANGGILAN CEPAT DARURAT',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildQuickCallBtn(
                          icon: Icons.local_police,
                          label: 'Polisi',
                          number: '110',
                          color: Colors.blue.shade400,
                        ),
                        _buildQuickCallBtn(
                          icon: Icons.medical_services,
                          label: 'Ambulans',
                          number: '119',
                          color: Colors.green.shade400,
                        ),
                        _buildQuickCallBtn(
                          icon: Icons.local_fire_department,
                          label: 'Damkar',
                          number: '113',
                          color: Colors.orange.shade400,
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // 5. TOMBOL BATAL & DISCLAIMER
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white, size: 20),
                        label: const Text(
                          'BATALKAN MODE GAWAT',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade800, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Gunakan hanya dalam keadaan darurat yang mengancam jiwa.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPER: TOMBOL SOS GLOWING ---
  Widget _buildSOSButton() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Ripple Paling Luar
        Container(
          width: 260,
          height: 260,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.red.withValues(alpha: 0.05),
          ),
        ),
        // Ripple Tengah
        Container(
          width: 210,
          height: 210,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.red.withValues(alpha: 0.15),
          ),
        ),
        // Tombol Merah Solid
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _isSendingSOS ? null : _triggerSOS,
            customBorder: const CircleBorder(),
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFD32F2F), // Merah Kuat
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withValues(alpha: 0.4),
                    blurRadius: 25,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: _isSendingSOS
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'SOS',
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 2.0,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'TEKAN',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }

  // --- WIDGET HELPER: KARTU LOKASI ---
  Widget _buildLocationCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), // Warna abu-abu gelap
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: _isResolvingLocation ? null : _fetchCurrentLocation,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: _isResolvingLocation
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.redAccent,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Icon(Icons.my_location, color: Colors.redAccent, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Lokasi Anda Saat Ini',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (_locationError != null)
                        Text(
                          _locationError!,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 13,
                          ),
                        )
                      else if (_latitude == null || _longitude == null)
                        Text(
                          'Mendapatkan lokasi...',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 13,
                          ),
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}',
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 13,
                                fontFamily: 'monospace', // Efek teks koordinat
                              ),
                            ),
                            if (_address != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                _address!,
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 12,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPER: TOMBOL PANGGILAN CEPAT ---
  Widget _buildQuickCallBtn({
    required IconData icon,
    required String label,
    required String number,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        child: Material(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () => _makeCall(number),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade800),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    number,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}