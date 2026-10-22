import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../modul_06/models/sesi_pengguna.dart';
import 'sesi_repository.dart';

class PrefsSesiRepository implements SesiRepository {
  static const String kunciSesi = 'modul_06_sesi_pengguna';
  final Future<SharedPreferences> _prefs;

  PrefsSesiRepository([Future<SharedPreferences>? prefs])
      : _prefs = prefs ?? SharedPreferences.getInstance();

  @override
  String get nama => 'Prefs';

  @override
  String get keterangan =>
      'Bertahan di disk, tetapi token tidak terenkripsi (bocor jika diekstrak)';

  @override
  bool get bertahanSetelahRestart => true;

  @override
  Future<SesiPengguna?> baca() async {
    final SharedPreferences prefs = await _prefs;
    final String? jsonStr = prefs.getString(kunciSesi);
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      final Map<String, dynamic> map =
          jsonDecode(jsonStr) as Map<String, dynamic>;
      return SesiPengguna.fromJson(map);
    } catch (_) {
      await prefs.remove(kunciSesi);
      return null;
    }
  }

  @override
  Future<void> simpan(SesiPengguna sesi) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setString(kunciSesi, jsonEncode(sesi.toJson()));
  }

  @override
  Future<void> hapus() async {
    final SharedPreferences prefs = await _prefs;
    await prefs.remove(kunciSesi);
  }

  @override
  Future<bool> adaSesi() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.containsKey(kunciSesi);
  }

  @override
  Future<String?> intipMentah() async {
    final SharedPreferences prefs = await _prefs;
    // Demonstrasi kerentanan: SharedPreferences mengembalikan data mentah termasuk token
    return prefs.getString(kunciSesi);
  }
}
