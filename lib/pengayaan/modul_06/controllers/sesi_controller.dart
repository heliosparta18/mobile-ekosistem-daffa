import 'package:flutter/foundation.dart';
import '../../../modul_06/models/sesi_pengguna.dart';
import '../../../modul_06/services/auth_api.dart';
import '../repositories/sesi_repository.dart';

enum StatusSesi { memeriksa, keluar, memproses, masuk, gagal, kedaluwarsa }

class SesiController extends ChangeNotifier {
  final AuthApi api;
  SesiRepository repository;
  final DateTime Function() jam;

  StatusSesi _status = StatusSesi.memeriksa;
  SesiPengguna? _sesi;
  String? _pesan;

  SesiController({
    required this.api,
    required this.repository,
    this.jam = DateTime.now,
  }) {
    pulihkan();
  }

  StatusSesi get status => _status;
  SesiPengguna? get sesi => _sesi;
  String? get pesan => _pesan;
  bool get sedangMemproses => _status == StatusSesi.memproses;

  void _ubah(
    StatusSesi baru, {
    SesiPengguna? sesi,
    String? pesan,
    bool bersihkanPesan = false,
  }) {
    _status = baru;
    if (sesi != null || baru == StatusSesi.keluar) _sesi = sesi;
    if (bersihkanPesan) _pesan = null;
    if (pesan != null) _pesan = pesan;
    notifyListeners();
  }

  Future<void> gantiRepository(SesiRepository repoBaru) async {
    repository = repoBaru;
    await pulihkan();
  }

  Future<void> pulihkan() async {
    _ubah(StatusSesi.memeriksa, bersihkanPesan: true);
    final SesiPengguna? tersimpan = await repository.baca();
    if (tersimpan == null) {
      _ubah(StatusSesi.keluar, sesi: null);
      return;
    }

    if (tersimpan.sudahKedaluwarsa(jam())) {
      await repository.hapus(); // Sesi mati dibuang, bukan dibiarkan.
      _sesi = null;
      _ubah(
        StatusSesi.kedaluwarsa,
        pesan: 'Sesi Anda sudah berakhir. Silakan masuk kembali.',
      );
      return;
    }

    _ubah(StatusSesi.masuk, sesi: tersimpan);
  }

  Future<void> masuk(String email, String sandi) async {
    if (_status == StatusSesi.memproses) return;
    _ubah(StatusSesi.memproses, bersihkanPesan: true);

    try {
      final SesiPengguna hasil = await api.masuk(email: email, sandi: sandi);
      await repository.simpan(hasil);
      _ubah(StatusSesi.masuk, sesi: hasil);
    } on AuthException catch (e) {
      _ubah(StatusSesi.gagal, pesan: e.pesan);
    } catch (e) {
      _ubah(StatusSesi.gagal, pesan: 'Terjadi kesalahan tak terduga. Coba lagi.');
    }
  }

  Future<void> keluar() async {
    await repository.hapus();
    _ubah(StatusSesi.keluar, sesi: null, bersihkanPesan: true);
  }

  Future<void> perbaruiSesi({Duration masaBerlaku = const Duration(hours: 2)}) async {
    final SesiPengguna? sekarang = _sesi;
    if (sekarang == null) return;

    if (sekarang.sudahKedaluwarsa(jam())) {
      await repository.hapus();
      _sesi = null;
      _ubah(
        StatusSesi.kedaluwarsa,
        pesan: 'Sesi sudah berakhir dan tidak dapat diperbarui.',
      );
      return;
    }

    final SesiPengguna baru =
        await api.perbaruiSesi(sekarang, masaBerlaku: masaBerlaku);
    await repository.simpan(baru);
    _ubah(StatusSesi.masuk, sesi: baru);
  }
}
