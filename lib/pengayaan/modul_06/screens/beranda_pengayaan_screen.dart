import 'package:flutter/material.dart';
import '../../../modul_06/models/sesi_pengguna.dart';
import '../../../modul_06/widgets/kartu_sesi.dart';
import '../controllers/sesi_controller.dart';
import '../widgets/papan_diagnostik_penyimpanan.dart';

class BerandaPengayaanScreen extends StatefulWidget {
  final SesiController controller;
  final SesiPengguna sesi;

  const BerandaPengayaanScreen({
    super.key,
    required this.controller,
    required this.sesi,
  });

  @override
  State<BerandaPengayaanScreen> createState() =>
      _BerandaPengayaanScreenState();
}

class _BerandaPengayaanScreenState extends State<BerandaPengayaanScreen> {
  bool _sedangMemperbarui = false;

  Future<void> _perbarui() async {
    setState(() => _sedangMemperbarui = true);
    await widget.controller.perbaruiSesi();
    if (!mounted) return;
    setState(() => _sedangMemperbarui = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final repo = widget.controller.repository;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Beranda Pengayaan (Fase B)'),
        backgroundColor: theme.colorScheme.primaryContainer,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            KartuSesi(
              sesi: widget.sesi,
              sekarang: widget.controller.jam(),
              onKeluar: widget.controller.keluar,
              sedangKeluar: widget.controller.sedangMemproses,
            ),
            const SizedBox(height: 16),

            // Tombol Refresh Masa Berlaku Token
            SizedBox(
              height: 44,
              child: FilledButton.tonalIcon(
                onPressed: _sedangMemperbarui ? null : _perbarui,
                icon: _sedangMemperbarui
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh_rounded),
                label: const Text('Perbarui Token Sesi (+2 Jam)'),
              ),
            ),
            const SizedBox(height: 20),

            // Papan audit diagnosa keamanan
            PapanDiagnostikPenyimpanan(repository: repo),
          ],
        ),
      ),
    );
  }
}
