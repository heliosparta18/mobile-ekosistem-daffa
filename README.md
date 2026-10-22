# Laporan Praktikum Pemrograman Perangkat Bergerak
Program Studi Sarjana Terapan Teknologi Rekayasa Perangkat Lunak (TRPL)
Politeknik Negeri Banyuwangi - Semester Ganjil 2026

Repositori ini berisi pengerjaan tugas mingguan praktikum mobile, mencakup modul 1 sampai modul 6.

---

## 1. Identitas Mahasiswa

- Nama Lengkap: Muhammad Daffa Ariby Hidayat
- NIM: 362558302081
- Kelas / Angkatan: TRPL 2E / 2025
- Dosen Pengampu: Sepyan Purnama Kristanto, M.Kom.

---

## 2. Kemajuan Modul Praktikum

Berikut daftar modul yang telah diselesaikan:

| Modul | Topik Materi | Status | Perintah Uji (Test) |
|---|---|---|---|
| Modul 01 | Mobile Ecosystem, Toolchain dan Profile App | Selesai | flutter test test/modul_01_test.dart |
| Modul 02 | Declarative UI, BoxConstraints dan Dashboard Responsif | Selesai | flutter test test/modul_02_test.dart |
| Modul 03 | Navigasi GoRouter, Riverpod dan KRS App | Selesai | flutter test test/modul_03_test.dart |
| Modul 04 | Networking, REST API Dio dan Repository Pattern | Selesai | flutter test test/modul_04_test.dart |
| Modul 06 | Autentikasi, Manajemen Sesi dan Keamanan Penyimpanan | Selesai | flutter test test/modul_06_test.dart |

---

## 3. Panduan untuk Dosen Pengampu (Uji Coba Modul 06)

Modul 06 telah dilengkapi dengan implementasi lengkap untuk Mode A (Fase A Fundamental) dan Mode B (Fase B Pengayaan / Advanced).

Bapak Dosen dapat mengganti mode yang ingin dijalankan dengan mudah melalui file lib/main.dart:

### A. Cara Menjalankan Mode A (Fase A - Fundamental / Wajib)

Mode A menggunakan alur autentikasi fundamental dengan Form, validator, mesin keadaan 5 state, dan sesi yang disimpan di dalam memori proses RAM (SesiMemori).

1. Buka file lib/main.dart.
2. Pada fungsi main(), pastikan kode memanggil Modul06App():
```dart
void main() {
  runApp(const Modul06App());
}
```
3. Jalankan aplikasi:
```bash
flutter run
```
4. Skenario yang dapat diuji:
   - Tombol Isi Otomatis Demo: mengisikan kredensial demo (student@trpl.test / belajar123), lalu klik Masuk.
   - Skenario Akun Salah: masukkan kata sandi sembarang untuk melihat pesan penolakan "Email atau kata sandi salah".
   - Skenario Akun Terkunci: gunakan email terkunci@trpl.test untuk melihat penanganan status akun terkunci.
   - Skenario Server Gangguan: gunakan email gangguan@trpl.test untuk simulasi galat server.
   - Anti Pengiriman Ganda: tombol Masuk otomatis dinonaktifkan dan menampilkan indikator proses saat request berjalan.
   - Pembuktian Sesi Memori: saat berada di beranda, tutup aplikasi sepenuhnya melalui Recent Apps (App Switcher), lalu buka kembali. Sesi akan hilang dan kembali ke form login karena umur sesi mengikuti proses aplikasi.
   - Logout: klik tombol Keluar dari Sesi untuk membersihkan sesi dan kembali ke form login awal tanpa pesan kesalahan.

### B. Cara Menjalankan Mode B (Fase B - Advanced / Pengayaan)

Mode B mengimplementasikan flutter_secure_storage, shared_preferences, pemulihan sesi otomatis, perpanjangan masa berlaku token, dan papan audit diagnostik.

1. Buka file lib/main.dart.
2. Pada fungsi main(), ganti pemanggilan menjadi Modul06PengayaanApp():
```dart
void main() {
  runApp(const Modul06PengayaanApp());
}
```
3. Jalankan aplikasi:
```bash
flutter run
```
4. Fitur pengayaan yang dapat diuji:
   - Navigasi Bawah (Bottom Navigation): memungkinkan dosen berpindah langsung antara 3 jenis repositori penyimpanan: Memori RAM, SharedPreferences, dan Secure Storage.
   - Papan Diagnostik dan Audit: klik tombol "Intip Isi Penyimpanan (Audit)":
     - Pada SharedPreferences: data JSON dan token terbaca secara mentah, membuktikan bahwa SharedPreferences tidak aman untuk rahasia.
     - Pada Secure Storage: data dilindungi enkripsi platform Keystore/Keychain sehingga pembacaan mentah menghasilkan null.
   - Pemulihan Sesi: saat menggunakan Secure Storage, aplikasi yang ditutup paksa dan dibuka kembali akan langsung memulihkan sesi pengguna tanpa perlu login ulang.
   - Perpanjangan Sesi: di layar beranda tersedia tombol "Perbarui Token Sesi (+2 Jam)" untuk memperpanjang tiket sesi yang masih aktif.

---

## 4. Cara Menjalankan Pengujian (Testing)

Pengujian kode dapat dijalankan melalui perintah berikut:

```bash
# Menjalankan pengujian khusus Modul 06 (20 test suite)
flutter test test/modul_06_test.dart

# Menjalankan seluruh pengujian proyek (36 test suite)
flutter test

# Memeriksa analisis statis dan linter Dart
flutter analyze
```

---

## 5. Catatan Penggunaan AI

Berikut keterbukaan penggunaan alat bantu AI selama pengerjaan praktikum:

| Bagian Kode | Alat AI | Keperluan | Hasil dan Validasi Mandiri |
| Modul 04 | AI Assistant | Diskusi struktur Dio client dan pemodelan data | Memeriksa null safety dan memastikan seluruh unit test lolos |
| Modul 06 | AI Assistant | Diskusi alur state autentikasi dan pembuatan skenario test case | Memverifikasi pembersihan controller pada dispose, validasi form, dan memastikan 20 test Modul 06 lulus 100% |

---
Politeknik Negeri Banyuwangi
