import '../../../modul_06/models/sesi_pengguna.dart';
import '../../../modul_06/services/sesi_memori.dart';
import 'sesi_repository.dart';

class MemoriSesiRepository implements SesiRepository {
  final SesiMemori _memori;

  MemoriSesiRepository([SesiMemori? memori])
      : _memori = memori ?? SesiMemori();

  @override
  String get nama => 'Memori';

  @override
  String get keterangan => 'Hanya di RAM proses, hilang saat aplikasi ditutup';

  @override
  bool get bertahanSetelahRestart => false;

  @override
  Future<SesiPengguna?> baca() async => _memori.baca();

  @override
  Future<void> simpan(SesiPengguna sesi) => _memori.simpan(sesi);

  @override
  Future<void> hapus() => _memori.hapus();

  @override
  Future<bool> adaSesi() async => _memori.adaSesi;

  @override
  Future<String?> intipMentah() async => null;
}
