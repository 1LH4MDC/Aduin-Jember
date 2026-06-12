import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../services/auth_service.dart';
import '../../services/woro_service.dart';

class TambahWoroWoroPage extends StatefulWidget {
  /// Jika [woro] diisi, halaman berjalan dalam mode edit (PATCH).
  /// Jika null, halaman berjalan dalam mode buat baru (POST).
  final Map<String, dynamic>? woro;

  const TambahWoroWoroPage({super.key, this.woro});

  @override
  State<TambahWoroWoroPage> createState() => _TambahWoroWoroPageState();
}

class _TambahWoroWoroPageState extends State<TambahWoroWoroPage> {
  late WoroService _woroService;
  final _judulController = TextEditingController();
  final _kontenController = TextEditingController();

  String? _selectedKategori;
  bool _isLoading = false;
  final List<String> _kategoriList = [
    'Infrastruktur',
    'Kebersihan',
    'Keamanan',
    'Kesehatan',
    'Lainnya',
  ];

  // Image Upload State
  final _picker = ImagePicker();
  Uint8List? _imageBytes;
  String? _imageName;
  bool _isPickingImage = false;
  String? _existingFotoUrl;

  bool get _isEditMode => widget.woro != null;
  String get _idWoro => widget.woro?['idWoro']?.toString() ?? '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = context.read<AuthController>();
    _woroService = WoroService(apiClient: auth.apiClient);
  }

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _judulController.text = widget.woro?['judul']?.toString() ?? '';
      _kontenController.text = widget.woro?['konten']?.toString() ?? '';
      final existingKategori = widget.woro?['kategori']?.toString();
      _selectedKategori = (_kategoriList.contains(existingKategori))
          ? existingKategori
          : null;
      _existingFotoUrl = (widget.woro?['fotoUrl'] ?? widget.woro?['photo_url'] ?? '').toString();
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _kontenController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    setState(() => _isPickingImage = true);

    try {
      final picked = await _picker.pickImage(
        source: kIsWeb ? ImageSource.gallery : ImageSource.gallery, // Gallery is preferred for Woro banners
        imageQuality: 85,
      );

      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _imageName = picked.name.isNotEmpty ? picked.name : 'woro.jpg';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih gambar: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPickingImage = false);
      }
    }
  }

  Future<void> _submit() async {
    final judul = _judulController.text.trim();
    final konten = _kontenController.text.trim();

    if (judul.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul pengumuman tidak boleh kosong!')),
      );
      return;
    }
    if (konten.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi Woro-Woro tidak boleh kosong!')),
      );
      return;
    }
    if (_selectedKategori == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih kategori terlebih dahulu!')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? finalFotoUrl = _existingFotoUrl;

      // Upload image to Supabase first if a new one is selected
      if (_imageBytes != null) {
        finalFotoUrl = await _woroService.uploadWoroImage(
          imageBytes: _imageBytes!,
          imageName: _imageName ?? 'woro.jpg',
        );
      }

      if (_isEditMode) {
        await _woroService.updateWoro(
          _idWoro,
          judul: judul,
          konten: konten,
          kategori: _selectedKategori!,
          fotoUrl: finalFotoUrl,
        );
      } else {
        await _woroService.createWoro(
          judul: judul,
          konten: konten,
          kategori: _selectedKategori!,
          fotoUrl: finalFotoUrl,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode
                  ? 'Pengumuman berhasil diperbarui!'
                  : 'Pengumuman berhasil ditambahkan!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Kembalikan true agar list direfresh
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasImageToShow = _imageBytes != null || (_existingFotoUrl != null && _existingFotoUrl!.isNotEmpty);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditMode ? 'Edit Woro-Woro' : 'Tambah Woro-Woro',
          style: const TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Konten Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Upload Banner
                    _buildLabel('Banner Pengumuman (Tap untuk Mengubah)'),
                    GestureDetector(
                      onTap: _isPickingImage || _isLoading ? null : _pickImage,
                      child: Container(
                        width: double.infinity,
                        height: 160,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.withValues(alpha: 0.4),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: _isPickingImage
                              ? const Center(
                                  child: CircularProgressIndicator(color: AppTheme.primaryColor),
                                )
                              : hasImageToShow
                                  ? (_imageBytes != null
                                      ? Image.memory(
                                          _imageBytes!,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                        )
                                      : Image.network(
                                          _existingFotoUrl!,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          errorBuilder: (c, e, s) => const Center(
                                            child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
                                          ),
                                        ))
                                  : Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.add_photo_alternate_outlined,
                                          color: AppTheme.primaryColor,
                                          size: 36,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Unggah Banner Informasi (Rekomendasi 16:9)',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 2. Input Judul
                    _buildLabel('Judul Pengumuman'),
                    _buildTextField(
                      hint: 'Masukkan judul pengumuman...',
                      controller: _judulController,
                    ),
                    const SizedBox(height: 20),

                    // 3. Dropdown Kategori
                    _buildLabel('Kategori'),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.4),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedKategori,
                          hint: const Text(
                            'Pilih Kategori',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                          isExpanded: true,
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.grey,
                          ),
                          items: _kategoriList.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: const TextStyle(fontSize: 14),
                              ),
                            );
                          }).toList(),
                          onChanged: _isLoading
                              ? null
                              : (newValue) {
                                  setState(() {
                                    _selectedKategori = newValue;
                                  });
                                },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 4. Isi Woro-Woro
                    _buildLabel('Isi Woro-Woro'),
                    _buildTextField(
                      hint: 'Tuliskan detail pengumuman di sini...',
                      controller: _kontenController,
                      maxLines: 5,
                    ),
                  ],
                ),
              ),
            ),

            // Bagian Bawah: Tombol Batal & Simpan
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppTheme.primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: AppTheme.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              _isEditMode ? 'Perbarui Woro-Woro' : 'Simpan Woro-Woro',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget untuk Label Title
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          color: Colors.black87,
        ),
      ),
    );
  }

  // Helper Widget untuk Text Field
  Widget _buildTextField({
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      enabled: !_isLoading,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.4)),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.primaryColor),
        ),
      ),
    );
  }
}
