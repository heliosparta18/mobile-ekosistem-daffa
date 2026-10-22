# Laporan Praktikum Modul 02: Declarative UI & Responsive Layout

- **Nama**: Muhammad Daffa Ariby Hidayat
- **NIM**: 362558302081
- **Kelas / Prodi**: TRPL 2E / Sarjana Terapan TRPL
- **Mata Kuliah**: Pemrograman Perangkat Bergerak (Semester 5)
- **Dosen Pengampu**: Sepyan Purnama Kristanto, M.Kom.

---

## 1. Ringkasan Implementasi

Dashboard Akademik dibangun bertahap: model data `Course`, komponen `CourseCard` (Column + Row untuk konten linear, dibungkus `Stack` + `Positioned` untuk badge SKS melayang), dan `HeaderBanner` (Wrap untuk pil statistik agar tidak overflow). `AcademicDashboardScreen` diubah menjadi `StatefulWidget` yang membungkus body dengan `LayoutBuilder`: pada `constraints.maxWidth < 600` tampilan memakai `ListView` satu kolom, sedangkan pada `>= 600` memakai `Row` dua kolom (banner di kiri, `GridView.builder` dengan `SliverGridDelegateWithMaxCrossAxisExtent` di kanan). Tema terpusat memakai Material 3 `ColorScheme.fromSeed` dengan `themeMode` yang dapat dialihkan Light/Dark lewat tombol di `AppBar`.

Tiga tantangan mandiri juga diimplementasikan:
- **Filter kategori**: `Wrap` + `ChoiceChip` (`Semua`/`Teori`/`Praktikum`) yang memfilter daftar mata kuliah lewat `setState()`.
- **Detail BottomSheet**: `CourseCard` dibungkus `InkWell` sehingga `onTap` memanggil `showModalBottomSheet` berisi rincian dosen, SKS, ruangan, dan progres.
- **Indikator SKS**: total SKS dihitung dengan `fold()`, ditampilkan sebagai badge di `HeaderBanner`, dan memicu kotak peringatan merah bila melebihi 24 SKS.

## 2. Bukti Tangkapan Layar (Running App)

> Screenshot berikut perlu diisi setelah menjalankan `flutter run` / `flutter run -d chrome` secara lokal, karena lingkungan pengerjaan ini tidak memiliki Flutter SDK/emulator untuk merender aplikasi secara visual.

| Mode Portrait (Light) | Mode Dark Theme | Mode Landscape / Tablet (2 Kolom) |
|---|---|---|
| ![Portrait](./screenshots/running_portrait.png) | ![Dark](./screenshots/running_dark.png) | ![Wide](./screenshots/running_wide.png) |

## 3. Kendala Layout yang Dihadapi & Solusinya

- **Kendala**: Kode awal `course_card.dart` memiliki blok "Ruang Kelas" yang terduplikasi dan baris info dosen pengampu yang hilang, sehingga teks nama dosen tidak pernah dirender (menyebabkan uji `modul_02_test.dart` gagal karena `find.text('Dosen Penguji')` tidak ditemukan).
  **Solusi**: Menulis ulang `Column` konten kartu dengan urutan yang jelas — baris ikon dosen (`Icons.person_outline`) dan baris ikon ruangan (`Icons.meeting_room_outlined`), masing-masing membungkus `Text` dengan `Expanded` + `maxLines: 1` + `TextOverflow.ellipsis` agar nama dosen atau ruangan yang panjang tidak memicu *RenderFlex overflow*.
- **Kendala**: Kode awal memakai `Spacer()` sebelum progress bar di dalam `Column` yang berada di `Card` dalam `ListView`. Karena tinggi `Column` ini mengikuti tinggi konten (bukan mengikuti parent yang tinggi tetap), `Spacer()` berisiko memicu error *"RenderFlex children have non-zero flex but incoming height constraints are unbounded"*.
  **Solusi**: Mengganti `Spacer()` dengan `const SizedBox(height: 16)` — jarak tetap yang tidak bergantung pada sisa ruang yang tidak pasti.
- **Kendala**: Nama mata kuliah yang panjang berpotensi mendorong tinggi kartu menjadi tidak konsisten antar kartu dalam satu baris grid.
  **Solusi**: Membatasi `Text` judul dengan `maxLines: 2` dan `overflow: TextOverflow.ellipsis`, serta menetapkan `mainAxisExtent: 240` pada `SliverGridDelegateWithMaxCrossAxisExtent` agar seluruh kartu pada grid tablet memiliki tinggi yang seragam.

## 4. Jawaban Pertanyaan Refleksi

1. **Efisiensi Single-pass BoxConstraints**: Aturan *"Constraints go down, Sizes go up, Parent sets position"* membuat setiap widget hanya perlu tahu batasan (constraints) dari parent-nya dan tidak pernah perlu "menengok" saudara atau nenek moyangnya lebih jauh. Parent mengirim batas ukuran ke bawah satu kali, setiap child menghitung ukurannya sendiri berdasarkan batas itu lalu melaporkan hasilnya ke atas satu kali, dan parent menempatkan posisi child berdasarkan ukuran yang dilaporkan. Karena aliran informasi hanya turun sekali lalu naik sekali (tidak ada iterasi bolak-balik berulang antar level), kompleksitas komputasi layout untuk N widget menjadi linear atau `O(N)`, bukan kuadratik seperti model layout yang butuh banyak putaran negosiasi ukuran antar widget.

2. **Kriteria Modularisasi Widget**: Sebuah widget sebaiknya dipecah menjadi file terpisah (seperti `CourseCard`) ketika ia dipakai berulang di lebih dari satu tempat (mis. dalam `ListView` dan `GridView`), memiliki logika atau state sendiri yang cukup kompleks, atau ukurannya (jumlah baris kode) membuat file induk sulit dibaca. Sebaliknya, widget kecil yang hanya dipakai sekali di dalam satu file dan sangat terikat pada konteks tampilan file tersebut (seperti `_StatPill` di `header_banner.dart`) cukup dijadikan private widget (diawali underscore) di file yang sama, karena memisahkannya ke file baru justru menambah *boilerplate* import tanpa manfaat reusabilitas yang nyata.

3. **Manfaat M3 ThemeData Terpusat**: Dengan `ThemeData` terpusat (`ColorScheme.fromSeed`), seluruh warna, elevation, dan bentuk komponen (Card, Button, Chip, dsb.) diturunkan secara konsisten dari satu seed color di satu tempat. Jika suatu saat identitas warna brand aplikasi berubah, pengembang cukup mengganti satu nilai `seedColor` dan seluruh aplikasi otomatis menyesuaikan — termasuk otomatis menghasilkan palet mode gelap yang kontras dan sesuai pedoman aksesibilitas Material 3. Ini jauh lebih mudah dipelihara dibanding memberi warna manual (`Color(0xFF...)`) pada setiap widget satu per satu, yang rawan inkonsistensi dan sulit diubah secara massal saat aplikasi berskala besar.
