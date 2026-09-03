# Starter Template & Laporan Praktikum Pemrograman Mobile
### Program Studi Sarjana Terapan Teknologi Rekayasa Perangkat Lunak (TRPL)
**Politeknik Negeri Banyuwangi — Semester Ganjil 2026**

Panduan interaktif lengkap: [Portal Codelabs TRPL Poliwangi](https://codelabs-poliwangi.github.io/MobileDev-Codelabs/)

---

## 1. Identitas Mahasiswa

> [!IMPORTANT]
> **Wajib Mengganti Data di Bawah Ini!**  
> Autograding CI/CD akan memeriksa apakah nilai *placeholder* di bawah ini telah diganti dengan Nama dan NIM Anda yang sebenarnya. Jika belum diganti, pengujian `verify_documentation_test.dart` akan gagal.

| Informasi | Data Mahasiswa |
|---|---|
| **Nama Lengkap** | Muhammad Daffa Ariby Hidayat  |
| **NIM** | 362558302081 |
| **Kelas / Angkatan** | TRPL 2E / 2025 |
| **Dosen Pengampu** | Sepyan Purnama Kristanto, M.Kom. |

---

## 2. Peta Kemajuan Modul Praktikum

Aplikasi ini menggunakan **Sistem Kontrol Akses Modul Terpusat (Smart Gating)** di file `lib/main.dart` agar mahasiswa belajar selaras dengan ritme materi dosen di kelas:

| Modul | Topik & Arsitektur | Status Akses | Perintah Self-Test Lokal | Bobot CI |
|:---:|---|:---:|---|:---:|
| **#01** | Mobile Ecosystem, Toolchain & Profile App | `✓ Terbuka` | `flutter test test/modul_01_test.dart` | 20 Pts |
| **#02** | Declarative UI, BoxConstraints & Responsive Dashboard | `⚡ Aktif` | `flutter test test/modul_02_test.dart` | 20 Pts |
| **#03** | Navigation (GoRouter), Riverpod & 4-State KRS App | `🔒 Terkunci (W03)` | `flutter test test/modul_03_test.dart` | 20 Pts |
| **#04** | Networking, REST API Dio & Repository Pattern | `🔒 Terkunci (W04)` | `flutter test test/modul_04_test.dart` | 15 Pts |
| **Dok** | Verifikasi Identitas Asli Mahasiswa di README | `Wajib` | `flutter test test/verify_documentation_test.dart` | 10 Pts |
| **Lint** | Dart Code Formatting & Static Analysis | `Wajib` | `flutter analyze --no-fatal-infos` | 15 Pts |
| **Total** | **Skor Maksimal Evaluasi Autograding** | — | `flutter test` | **100 Pts** |

> [!NOTE]
> **Membuka Modul Terkunci saat di Laboratorium:**  
> Jika Anda sedang berada di sesi perkuliahan laboratorium dan dosen mengumumkan pembukaan modul, klik kartu modul yang terkunci di aplikasi lalu masukkan **Token Akses Kelas** yang dibagikan oleh dosen (misal: `TRPL-M03`, `TRPL-M04`, atau master passcode `POLIWANGI2026`).

---

## 3. Panduan Menjalankan & Menguji Kode

### A. Persiapan Lingkungan (Setup)
```bash
# 1. Unduh seluruh dependensi paket Flutter
flutter pub get

# 2. Jalankan aplikasi pada emulator atau perangkat fisik Android/iOS/Web
flutter run
```

### B. Pengujian Mandiri Sebelum Push (Self-Testing)
Sebelum melakukan `git push` ke repositori tugas GitHub Anda, pastikan seluruh pengujian lulus di mesin lokal:

```bash
# 1. Periksa aturan kode linter Dart
flutter analyze

# 2. Jalankan unit & widget test modul yang sedang Anda kerjakan
flutter test test/modul_01_test.dart
flutter test test/modul_02_test.dart

# 3. Jalankan seluruh test suite sekaligus
flutter test
```

---

## 4. Konvensi Pesan Commit (Conventional Commits)

Mahasiswa **wajib** menggunakan format pesan commit terstruktur:
- `feat(w01): complete profile screen and identity info card`
- `feat(w02): implement layoutbuilder responsive grid for tablet`
- `fix(w02): resolve renderflex overflow in course card`
- `feat(w03): setup gorouter declarative routes and krs notifier`
- `feat(w04): integrate dio remote datasource and repository pattern`
- `docs(readme): update student identity and ai reflection table`

---

## 5. Catatan Penggunaan AI (Responsible AI Disclosure)

Sesuai prinsip **Responsible AI** di lingkungan akademik Politeknik Negeri Banyuwangi, mahasiswa diperbolehkan menggunakan AI coding assistant (GitHub Copilot, Gemini Code Assist, ChatGPT) sebagai akselerator belajar, dengan kewajiban mencatat penggunaannya secara transparan pada tabel berikut:

| Modul / File Kode | Alat AI yang Digunakan | Tujuan Penggunaan | Validasi Teknis yang Dilakukan Mahasiswa |
|---|---|---|---|
| *Contoh: lib/modul_02/widgets/course_card.dart* | *GitHub Copilot* | *Saran styling Elevation & BoxDecoration* | *Memeriksa contrast ratio WCAG AA dan padding antarmuka* |
| *Contoh: lib/modul_04/models/announcement.dart* | *Gemini Code Assist* | *Pengecekan null-safety pada fromJson* | *Menambahkan fallback default string kosong untuk mencegah error runtime* |

---

*Hak Cipta © 2026 Jurusan Bisnis dan Informatika (JBI), Politeknik Negeri Banyuwangi.*
