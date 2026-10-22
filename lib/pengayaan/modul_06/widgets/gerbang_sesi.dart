import 'package:flutter/material.dart';
import '../../../modul_06/models/sesi_pengguna.dart';
import '../controllers/sesi_controller.dart';

/// Gerbang sesi yang memusatkan keputusan navigasi berdasarkan keadaan sesi,
/// sehingga layar form login tidak menyimpan kebenaran sesi sendiri.
class GerbangSesi extends StatelessWidget {
  final SesiController controller;
  final Widget Function(BuildContext) form;
  final Widget Function(BuildContext, SesiPengguna) beranda;

  const GerbangSesi({
    super.key,
    required this.controller,
    required this.form,
    required this.beranda,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        switch (controller.status) {
          case StatusSesi.memeriksa:
            return const Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Memeriksa sesi pengayaan…'),
                  ],
                ),
              ),
            );
          case StatusSesi.masuk:
            final sesi = controller.sesi;
            if (sesi == null) return form(context);
            return beranda(context, sesi);
          case StatusSesi.keluar:
          case StatusSesi.memproses:
          case StatusSesi.gagal:
          case StatusSesi.kedaluwarsa:
            return form(context);
        }
      },
    );
  }
}
