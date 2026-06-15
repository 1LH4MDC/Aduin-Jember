import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../services/auth_service.dart';
import '../../services/sambat_service.dart';

class CreateSambatPage extends StatefulWidget {
  const CreateSambatPage({super.key});

  @override
  State<CreateSambatPage> createState() => _CreateSambatPageState();
}

class _CreateSambatPageState extends State<CreateSambatPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _picker = ImagePicker();
  final _mapController = MapController();

  final List<String> _categories = const [
    'Sosial',
    'Infrastruktur',
    'Layanan Umum',
  ];

  String? _selectedCategory;
  Uint8List? _imageBytes;
  String? _imageName;
  latlong.LatLng? _selectedPosition;
  String? _selectedAddress;
  bool _isPickingImage = false;
  bool _isResolvingLocation = false;
  bool _isSubmitting = false;

  static const latlong.LatLng _defaultPosition = latlong.LatLng(
    -8.1715,
    113.7020,
  );

  @override
  void initState() {
    super.initState();
    _selectedCategory = _categories.first;
    _selectedPosition = _defaultPosition;
    _resolveAddress(_defaultPosition);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    setState(() => _isPickingImage = true);

    try {
      final picked = await _picker.pickImage(
        source: kIsWeb ? ImageSource.gallery : ImageSource.camera,
        imageQuality: 80,
      );

      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _imageName = picked.name.isNotEmpty ? picked.name : 'sambat.jpg';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isPickingImage = false);
      }
    }
  }

  Future<void> _selectCurrentLocation() async {
    setState(() => _isResolvingLocation = true);

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
      await _updateLocation(
        latlong.LatLng(position.latitude, position.longitude),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) {
        setState(() => _isResolvingLocation = false);
      }
    }
  }

  Future<void> _updateLocation(latlong.LatLng position) async {
    setState(() {
      _selectedPosition = position;
    });

    _mapController.move(position, 15);
    await _resolveAddress(position);
  }

  Future<void> _resolveAddress(latlong.LatLng position) async {
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

      setState(() {
        _selectedAddress = parts.isEmpty
            ? '${position.latitude}, ${position.longitude}'
            : parts.join(', ');
      });
    } catch (_) {
      setState(() {
        _selectedAddress = '${position.latitude}, ${position.longitude}';
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto sambat wajib diambil.')),
      );
      return;
    }

    if (_selectedPosition == null || _selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lokasi sambat belum dipilih.')),
      );
      return;
    }

    final auth = context.read<AuthController>();
    if (!auth.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sesi login tidak ditemukan.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final sambatService = SambatService(apiClient: auth.apiClient);
      await sambatService.createSambat(
        title: _titleController.text.trim(),
        category: _selectedCategory ?? _categories.first,
        description: _descriptionController.text.trim(),
        imageBytes: _imageBytes!,
        imageName: _imageName ?? 'sambat.jpg',
        latitude: _selectedPosition!.latitude,
        longitude: _selectedPosition!.longitude,
        address: _selectedAddress!,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sambat berhasil dikirim.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
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
          'Buat Sambat',
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul Sambat',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Judul wajib diisi'
                    : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                items: _categories
                    .map(
                      (category) => DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _selectedCategory = value),
                decoration: const InputDecoration(
                  labelText: 'Kategori Sambat',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi Kejadian',
                  alignLabelWithHint: true,
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 60),
                    child: Icon(Icons.notes_outlined),
                  ),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Deskripsi wajib diisi'
                    : null,
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Foto Bukti',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_imageBytes != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.memory(
                          _imageBytes!,
                          height: 220,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      Container(
                        height: 180,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: const Text('Belum ada foto'),
                      ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _isPickingImage ? null : _pickImage,
                      icon: _isPickingImage
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.photo_library_outlined),
                      label: Text(kIsWeb ? 'Pilih Gambar' : 'Ambil Foto Kamera'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Lokasi Sambat',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        height: 260,
                        child: Stack(
                          children: [
                            FlutterMap(
                              mapController: _mapController,
                              options: MapOptions(
                                initialCenter:
                                    _selectedPosition ?? _defaultPosition,
                                initialZoom: 15,
                                onTap: (tapPosition, point) =>
                                    _updateLocation(
                                  latlong.LatLng(
                                    point.latitude,
                                    point.longitude,
                                  ),
                                ),
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'aduin_jember',
                                ),
                                if (_selectedPosition != null)
                                  MarkerLayer(
                                    markers: [
                                      Marker(
                                        point: _selectedPosition!,
                                        width: 48,
                                        height: 48,
                                        child: const Icon(
                                          Icons.location_pin,
                                          size: 48,
                                          color: AppTheme.primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                            Positioned(
                              right: 8,
                              bottom: 8,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  child: Text(
                                    'OpenStreetMap',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _isResolvingLocation
                          ? null
                          : _selectCurrentLocation,
                      icon: _isResolvingLocation
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.my_location_outlined),
                      label: const Text('Gunakan Lokasi Saya'),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedAddress ?? 'Belum ada lokasi yang dipilih.',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Kirim Sambat'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
