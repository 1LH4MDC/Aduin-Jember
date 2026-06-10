# Aduin Jember

Aplikasi pelaporan masyarakat Jember berbasis Flutter dengan akses data hanya melalui REST API Railway, login/register email/password, kamera, Google Maps, dan halaman admin sederhana.

## Setup

1. Jalankan aplikasi dengan `RAILWAY_BASE_URL` dan `GOOGLE_MAPS_API_KEY` jika ingin peta aktif.
2. Backend auth, profil, dan laporan memakai endpoint API yang sudah Anda dokumentasikan.

```bash
flutter run \
	--dart-define=RAILWAY_BASE_URL=https://aduinjember-production.up.railway.app \
	--dart-define=GOOGLE_MAPS_API_KEY=your_google_maps_key
```

## Alur Aplikasi

- Register dan login memakai `/api/auth/register` dan `/api/auth/login`.
- Token JWT disimpan lokal lalu dipakai di header `Authorization: Bearer <token>`.
- Dashboard menampilkan tombol Buat Laporan dan Laporan Saya.
- Laporan dibuat lewat kamera, watermark endpoint, Google Maps, lalu POST ke `/api/sambat`.
- Halaman admin membaca role dari profil lalu mengubah status via `/api/sambat/{id}/status`.
