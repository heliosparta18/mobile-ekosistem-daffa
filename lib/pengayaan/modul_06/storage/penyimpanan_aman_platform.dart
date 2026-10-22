import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'penyimpanan_aman.dart';

class PenyimpananAmanPlatform implements PenyimpananAman {
  final FlutterSecureStorage _storage;

  const PenyimpananAmanPlatform({
    FlutterSecureStorage storage = const FlutterSecureStorage(),
  }) : _storage = storage;

  @override
  Future<void> tulis(String kunci, String nilai) =>
      _storage.write(key: kunci, value: nilai);

  @override
  Future<String?> baca(String kunci) => _storage.read(key: kunci);

  @override
  Future<void> hapus(String kunci) => _storage.delete(key: kunci);

  @override
  Future<String?> bacaMentah(String kunci) async {
    // Plugin platform mengenkripsi data dan tidak menyediakan pembacaan mentah
    // melalui API ini.
    return null;
  }
}
