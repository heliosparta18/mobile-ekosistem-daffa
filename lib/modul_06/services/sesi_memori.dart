import '../models/sesi_pengguna.dart';

/// Penyimpanan sesi di dalam memori proses RAM.
/// Sesi bertahan selama aplikasi hidup dan lenyap begitu sistem operasi
/// mematikan prosesnya.
class SesiMemori {
  SesiPengguna? _sesi;
  int jumlahPenulisan = 0; // Dipakai untuk verifikasi pengujian.

  SesiPengguna? baca() => _sesi;
  bool get adaSesi => _sesi != null;

  Future<void> simpan(SesiPengguna sesi) async {
    _sesi = sesi;
    jumlahPenulisan++;
  }

  Future<void> hapus() async {
    _sesi = null;
  }
}
