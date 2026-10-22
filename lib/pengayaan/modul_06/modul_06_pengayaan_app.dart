import 'package:flutter/material.dart';
import '../../../modul_06/models/sesi_pengguna.dart';
import '../../../modul_06/services/auth_api.dart';
import 'controllers/sesi_controller.dart';
import 'repositories/aman_sesi_repository.dart';
import 'repositories/memori_sesi_repository.dart';
import 'repositories/prefs_sesi_repository.dart';
import 'repositories/sesi_repository.dart';
import 'screens/beranda_pengayaan_screen.dart';
import 'screens/login_pengayaan_screen.dart';
import 'storage/penyimpanan_aman.dart';
import 'storage/penyimpanan_aman_platform.dart';
import 'widgets/gerbang_sesi.dart';

class Modul06PengayaanApp extends StatefulWidget {
  final AuthApi? api;
  final PenyimpananAman? penyimpananAman;
  final SesiRepository? repositoryAwal;

  const Modul06PengayaanApp({
    super.key,
    this.api,
    this.penyimpananAman,
    this.repositoryAwal,
  });

  @override
  State<Modul06PengayaanApp> createState() => _Modul06PengayaanAppState();
}

class _Modul06PengayaanAppState extends State<Modul06PengayaanApp> {
  late final AuthApi _api = widget.api ?? const AuthApi();
  late final PenyimpananAman _penyimpanan =
      widget.penyimpananAman ?? const PenyimpananAmanPlatform();

  late final SesiRepository _repoMemori = MemoriSesiRepository();
  late final SesiRepository _repoPrefs = PrefsSesiRepository();
  late final SesiRepository _repoAman = AmanSesiRepository(_penyimpanan);

  late SesiRepository _repoAktif = widget.repositoryAwal ?? _repoAman;
  late final SesiController _controller = SesiController(
    api: _api,
    repository: _repoAktif,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _gantiPenyimpanan(SesiRepository repo) {
    setState(() => _repoAktif = repo);
    _controller.gantiRepository(repo);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Modul 06 — Pengayaan Fase B',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D9488)),
        useMaterial3: true,
      ),
      home: Scaffold(
        bottomNavigationBar: NavigationBar(
          selectedIndex: _repoAktif.nama == 'Memori'
              ? 0
              : _repoAktif.nama == 'Prefs'
                  ? 1
                  : 2,
          onDestinationSelected: (index) {
            if (index == 0) _gantiPenyimpanan(_repoMemori);
            if (index == 1) _gantiPenyimpanan(_repoPrefs);
            if (index == 2) _gantiPenyimpanan(_repoAman);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.memory_rounded),
              label: 'Memori RAM',
            ),
            NavigationDestination(
              icon: Icon(Icons.folder_open_rounded),
              label: 'SharedPreferences',
            ),
            NavigationDestination(
              icon: Icon(Icons.lock_rounded),
              label: 'Secure Storage',
            ),
          ],
        ),
        body: GerbangSesi(
          controller: _controller,
          form: (context) => LoginPengayaanScreen(controller: _controller),
          beranda: (context, SesiPengguna sesi) =>
              BerandaPengayaanScreen(controller: _controller, sesi: sesi),
        ),
      ),
    );
  }
}
