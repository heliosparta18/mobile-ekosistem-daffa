import 'package:flutter/material.dart';
import '../models/sesi_pengguna.dart';
import '../services/auth_api.dart';
import '../services/sesi_memori.dart';
import '../widgets/field_kata_sandi.dart';
import '../widgets/kartu_sesi.dart';

enum StatusAuth { memeriksa, keluar, memproses, masuk, gagal }

class LoginScreen extends StatefulWidget {
  final AuthApi api;
  final SesiMemori sesiMemori;
  final DateTime Function() jam;

  const LoginScreen({
    super.key,
    required this.api,
    required this.sesiMemori,
    this.jam = DateTime.now,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _sandi = TextEditingController();

  StatusAuth _status = StatusAuth.memeriksa;
  String? _pesanGagal;
  SesiPengguna? _sesi;
  bool _sedangKeluar = false;
  bool _dibatalkan = false;

  @override
  void initState() {
    super.initState();
    _pulihkanSesi();
  }

  @override
  void dispose() {
    // Controller menyimpan teks sensitif di RAM, buang saat widget dihancurkan.
    _email.dispose();
    _sandi.dispose();
    super.dispose();
  }

  /// Memulihkan sesi saat pertama kali aplikasi/layar dimuat.
  Future<void> _pulihkanSesi() async {
    final SesiPengguna? tersimpan = widget.sesiMemori.baca();
    if (!mounted) return;

    if (tersimpan == null) {
      setState(() => _status = StatusAuth.keluar);
      return;
    }

    if (tersimpan.sudahKedaluwarsa(widget.jam())) {
      await widget.sesiMemori.hapus();
      if (!mounted) return;
      setState(() {
        _status = StatusAuth.gagal;
        _pesanGagal = 'Sesi sebelumnya sudah berakhir. Silakan masuk lagi.';
      });
      return;
    }

    setState(() {
      _sesi = tersimpan;
      _status = StatusAuth.masuk;
    });
  }

  /// Handler pengiriman login dengan penjaga ganda dan pengaman unmounted state.
  Future<void> _kirim() async {
    // Lapis 1 — Penjaga logika: abaikan jika proses login sedang berjalan.
    if (_status == StatusAuth.memproses) return;

    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _status = StatusAuth.memproses;
      _pesanGagal = null;
      _dibatalkan = false;
    });

    try {
      final SesiPengguna hasil = await widget.api.masuk(
        email: _email.text,
        sandi: _sandi.text,
      );

      // Jika pengguna menekan tombol Batal saat proses berjalan
      if (_dibatalkan) {
        if (!mounted) return;
        setState(() => _status = StatusAuth.keluar);
        return;
      }

      await widget.sesiMemori.simpan(hasil);
      if (!mounted) return;

      setState(() {
        _sesi = hasil;
        _status = StatusAuth.masuk;
        _sandi.clear(); // Hapus password dari memori form segera setelah sukses
      });
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _status = StatusAuth.gagal;
        _pesanGagal = e.pesan;
      });
    } catch (e) {
      // Kesalahan teknis tak terduga tidak dibocorkan langsung ke layar
      if (!mounted) return;
      setState(() {
        _status = StatusAuth.gagal;
        _pesanGagal = 'Terjadi kesalahan tak terduga. Coba lagi.';
      });
      debugPrint('Login gagal tak terduga: $e');
    }
  }

  /// Latihan Mandiri 3: Membatalkan proses login yang sedang berlangsung
  void _batalkan() {
    _dibatalkan = true;
    setState(() {
      _status = StatusAuth.keluar;
      _pesanGagal = null;
    });
  }

  /// Handler logout: mengosongkan sesi dan mengembalikan status ke `keluar` (bukan `gagal`).
  Future<void> _keluar() async {
    setState(() => _sedangKeluar = true);
    await widget.sesiMemori.hapus();
    if (!mounted) return;

    setState(() {
      _sesi = null;
      _status = StatusAuth.keluar; // Bukan StatusAuth.gagal!
      _pesanGagal = null;
      _sedangKeluar = false;
      _email.clear();
      _sandi.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modul 06 — Login & Session Dasar'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SafeArea(child: _bangunIsi()),
    );
  }

  /// Satu-satunya tempat yang memutuskan layar mana yang tampil.
  Widget _bangunIsi() {
    switch (_status) {
      case StatusAuth.memeriksa:
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Memeriksa sesi tersimpan…'),
            ],
          ),
        );
      case StatusAuth.masuk:
        final SesiPengguna? sesi = _sesi;
        if (sesi == null) {
          // Safeguard jika status masuk tetapi objek sesi kosong
          return _bangunForm();
        }
        return _bangunBeranda(sesi);
      case StatusAuth.keluar:
      case StatusAuth.memproses:
      case StatusAuth.gagal:
        return _bangunForm();
    }
  }

  Widget _bangunForm() {
    final bool sibuk = _status == StatusAuth.memproses;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: <Widget>[
        const SizedBox(height: 8),
        const Icon(Icons.school_rounded, size: 54, color: Color(0xFF0284C7)),
        const SizedBox(height: 12),
        const Text(
          'Masuk ke Portal Akademik',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Gunakan akun TRPL untuk mengakses data sesi Anda.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 24),

        // Kotak pesan kegagalan: hanya tampil jika ada error
        if (_pesanGagal != null) ...<Widget>[
          _KotakPesan(pesan: _pesanGagal!),
          const SizedBox(height: 16),
        ],

        Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _email,
                enabled: !sibuk,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                textInputAction: TextInputAction.next,
                autofillHints: const <String>[AutofillHints.email],
                validator: _validasiEmail,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.alternate_email_rounded),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              FieldKataSandi(
                controller: _sandi,
                enabled: !sibuk,
                validator: (String? nilai) {
                  if (nilai == null || nilai.isEmpty) {
                    return 'Kata sandi wajib diisi.';
                  }
                  if (nilai.length < 8) {
                    return 'Kata sandi minimal 8 karakter.';
                  }
                  return null;
                },
                onSubmitted: _kirim,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Tombol Masuk dengan penjaga ganda
        SizedBox(
          height: 48,
          child: FilledButton.icon(
            // Lapis 2 — Penjaga UI: tombol nonaktif saat proses berjalan
            onPressed: sibuk ? null : _kirim,
            icon: sibuk
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.login_rounded),
            label: Text(sibuk ? 'Memproses…' : 'Masuk'),
          ),
        ),

        // Tombol Batal jika sedang memproses (Latihan Mandiri 3)
        if (sibuk) ...[
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _batalkan,
            icon: const Icon(Icons.close_rounded, size: 16),
            label: const Text('Batal'),
          ),
        ],

        const SizedBox(height: 16),
        _KotakInfoDemo(
          onIsiOtomatis: sibuk
              ? null
              : () => setState(() {
                    _email.text = AuthApi.emailDemo;
                    _sandi.text = AuthApi.sandiDemo;
                  }),
        ),
      ],
    );
  }

  static String? _validasiEmail(String? nilai) {
    final String teks = (nilai ?? '').trim();
    if (teks.isEmpty) return 'Email wajib diisi.';
    if (!teks.contains('@') || !teks.contains('.')) {
      return 'Format email belum benar.';
    }
    return null;
  }

  Widget _bangunBeranda(SesiPengguna sesi) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: <Widget>[
        const Text(
          'Beranda',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        KartuSesi(
          sesi: sesi,
          sekarang: widget.jam(),
          onKeluar: _keluar,
          sedangKeluar: _sedangKeluar,
        ),
        const SizedBox(height: 20),
        const _KotakPeringatanMemori(),
      ],
    );
  }
}

/// Widget kotak pesan kesalahan login
class _KotakPesan extends StatelessWidget {
  final String pesan;
  const _KotakPesan({required this.pesan});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.error),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: theme.colorScheme.onErrorContainer,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              pesan,
              style: TextStyle(
                color: theme.colorScheme.onErrorContainer,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget kartu informasi kredensial demo simulasi
class _KotakInfoDemo extends StatelessWidget {
  final VoidCallback? onIsiOtomatis;
  const _KotakInfoDemo({this.onIsiOtomatis});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              const Text(
                'Akun Demo Praktikum',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Email: student@trpl.test\nSandi: belajar123',
            style: TextStyle(fontSize: 12, fontFamily: 'monospace'),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onIsiOtomatis,
              icon: const Icon(Icons.flash_on_rounded, size: 16),
              label: const Text('Isi Otomatis Demo', style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Kotak edukasi pengingat umur sesi di memori proses
class _KotakPeringatanMemori extends StatelessWidget {
  const _KotakPeringatanMemori();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.colorScheme.tertiary),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: theme.colorScheme.onTertiaryContainer,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Sesi ini hanya ada di memori proses RAM (SesiMemori). '
              'Tutup aplikasi dari daftar aplikasi terakhir (app switcher), lalu buka lagi '
              '— sesi akan hilang. Itu adalah hasil yang diharapkan untuk Fase A.',
              style: TextStyle(
                color: theme.colorScheme.onTertiaryContainer,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
