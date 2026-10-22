import 'dart:convert';
import '../../../modul_06/models/sesi_pengguna.dart';
import '../storage/penyimpanan_aman.dart';
import 'sesi_repository.dart';

class AmanSesiRepository implements SesiRepository {
  static const String kunciSesi = 'modul_06_sesi_aman';
  final PenyimpananAman penyimpanan;

  const AmanSesiRepository(this.penyimpanan);

  @override
  String get nama => 'Aman';

  @override
  String get keterangan =>
      'Menggunakan secure storage (Keystore/Keychain); ciphertext terlindungi';

  @override
  bool get bertahanSetelahRestart => true;

  @override
  Future<SesiPengguna?> baca() async {
    final String? jsonStr = await penyimpanan.baca(kunciSesi);
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      final Map<String, dynamic> map =
          jsonDecode(jsonStr) as Map<String, dynamic>;
      return SesiPengguna.fromJson(map);
    } catch (_) {
      await penyimpanan.hapus(kunciSesi);
      return null;
    }
  }

  @override
  Future<void> simpan(SesiPengguna sesi) async {
    await penyimpanan.tulis(kunciSesi, jsonEncode(sesi.toJson()));
  }

  @override
  Future<void> hapus() async {
    await penyimpanan.hapus(kunciSesi);
  }

  @override
  Future<bool> adaSesi() async {
    final String? val = await penyimpanan.baca(kunciSesi);
    return val != null && val.isNotEmpty;
  }

  @override
  Future<String?> intipMentah() => penyimpanan.bacaMentah(kunciSesi);
}
