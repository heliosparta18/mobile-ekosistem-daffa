import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poliwangi_mobile_starter/modul_06/models/sesi_pengguna.dart';
import 'package:poliwangi_mobile_starter/modul_06/services/auth_api.dart';
import 'package:poliwangi_mobile_starter/modul_06/services/sesi_memori.dart';
import 'package:poliwangi_mobile_starter/modul_06/screens/login_screen.dart';
import 'package:poliwangi_mobile_starter/modul_06/widgets/field_kata_sandi.dart';
import 'package:poliwangi_mobile_starter/modul_06/widgets/kartu_sesi.dart';
import 'package:poliwangi_mobile_starter/pengayaan/modul_06/controllers/sesi_controller.dart';
import 'package:poliwangi_mobile_starter/pengayaan/modul_06/repositories/aman_sesi_repository.dart';
import 'package:poliwangi_mobile_starter/pengayaan/modul_06/repositories/memori_sesi_repository.dart';
import 'package:poliwangi_mobile_starter/pengayaan/modul_06/repositories/prefs_sesi_repository.dart';
import 'package:poliwangi_mobile_starter/pengayaan/modul_06/storage/penyimpanan_aman.dart';
import 'package:poliwangi_mobile_starter/pengayaan/modul_06/widgets/gerbang_sesi.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockPenyimpananAman implements PenyimpananAman {
  final Map<String, String> _data = {};

  @override
  Future<void> tulis(String kunci, String nilai) async => _data[kunci] = nilai;

  @override
  Future<String?> baca(String kunci) async => _data[kunci];

  @override
  Future<void> hapus(String kunci) async => _data.remove(kunci);

  @override
  Future<String?> bacaMentah(String kunci) async => null;
}

void main() {
  group('Modul 06 Autograding: Login & Session Dasar (Fase A)', () {
    // ---------------------------------------------------------
    // 1. PENGUJIAN MODEL SesiPengguna
    // ---------------------------------------------------------
    test('1. Model SesiPengguna: fromJson, toJson, dan copyWith berjalan tepat', () {
      final json = <String, dynamic>{
        'token': 'jwt.token.abc',
        'email': 'student@trpl.test',
        'nama': 'Mahasiswa TRPL',
        'peran': 'mahasiswa',
        'masukPada': '2026-09-21T08:00:00.000',
        'kedaluwarsaPada': '2026-09-21T10:00:00.000',
      };

      final sesi = SesiPengguna.fromJson(json);
      expect(sesi.token, equals('jwt.token.abc'));
      expect(sesi.email, equals('student@trpl.test'));
      expect(sesi.nama, equals('Mahasiswa TRPL'));
      expect(sesi.peran, equals('mahasiswa'));
      expect(sesi.masukPada, equals('2026-09-21T08:00:00.000'));
      expect(sesi.kedaluwarsaPada, equals('2026-09-21T10:00:00.000'));

      final serialized = sesi.toJson();
      expect(serialized['token'], equals('jwt.token.abc'));
      expect(serialized['email'], equals('student@trpl.test'));

      final updated = sesi.copyWith(nama: 'Budi Santoso', peran: 'dosen');
      expect(updated.nama, equals('Budi Santoso'));
      expect(updated.peran, equals('dosen'));
      expect(updated.token, equals('jwt.token.abc'));
    });

    test('2. Model SesiPengguna: fallback default aman pada JSON tidak lengkap', () {
      final sesi = SesiPengguna.fromJson({});
      expect(sesi.token, isEmpty);
      expect(sesi.email, equals('tanpa-email'));
      expect(sesi.nama, equals('Pengguna'));
      expect(sesi.peran, equals('mahasiswa'));
      expect(sesi.masukPada, equals('1970-01-01T00:00:00.000'));
      expect(sesi.kedaluwarsaPada, equals('1970-01-01T00:00:00.000'));
    });

    test('3. Model SesiPengguna: sisaWaktu dan sudahKedaluwarsa secara deterministik', () {
      final acuanMulai = DateTime(2026, 9, 21, 8, 0);
      final sesi = SesiPengguna.contoh(
        sekarang: acuanMulai,
        masaBerlaku: const Duration(hours: 2),
      );

      // 1 jam setelah login -> sisa 1 jam, belum kedaluwarsa
      final jamSatu = acuanMulai.add(const Duration(hours: 1));
      expect(sesi.sudahKedaluwarsa(jamSatu), isFalse);
      expect(sesi.sisaWaktu(jamSatu), equals(const Duration(hours: 1)));

      // 2 jam setelah login -> batas waktu tercapai
      final jamDua = acuanMulai.add(const Duration(hours: 2));
      expect(sesi.sudahKedaluwarsa(jamDua), isTrue);
      expect(sesi.sisaWaktu(jamDua), equals(Duration.zero));

      // 3 jam setelah login -> sudah lewat batas
      final jamTiga = acuanMulai.add(const Duration(hours: 3));
      expect(sesi.sudahKedaluwarsa(jamTiga), isTrue);
      expect(sesi.sisaWaktu(jamTiga), equals(Duration.zero));

      // String tanggal rusak wajib dianggap kedaluwarsa demi keamanan (fail-safe)
      final sesiRusak = sesi.copyWith(kedaluwarsaPada: 'format-rusak');
      expect(sesiRusak.sudahKedaluwarsa(jamSatu), isTrue);
    });

    test('4. Helper format KartuSesi: label peran, format waktu, dan format sisa', () {
      expect(SesiPengguna.labelPeran('dosen'), equals('Dosen'));
      expect(SesiPengguna.labelPeran('mahasiswa'), equals('Mahasiswa'));
      expect(SesiPengguna.labelPeran('other'), equals('Pengguna'));

      expect(KartuSesi.formatWaktu('2026-09-21T08:05:00.000'), equals('21 Sep 2026, 08:05'));
      expect(KartuSesi.formatWaktu('invalid'), equals('tidak diketahui'));

      expect(KartuSesi.formatSisa(Duration.zero), equals('sudah berakhir'));
      expect(KartuSesi.formatSisa(const Duration(seconds: 45)), equals('45 detik'));
      expect(KartuSesi.formatSisa(const Duration(minutes: 25)), equals('25 menit'));
      expect(KartuSesi.formatSisa(const Duration(hours: 2)), equals('2 jam'));
      expect(KartuSesi.formatSisa(const Duration(hours: 1, minutes: 15)), equals('1 jam 15 menit'));
    });

    test('5. Keamanan Token: KartuSesi menyamarkan token secara default', () {
      const token = 'dummy.123456789.trpl';
      final tersamar = KartuSesi.samarkanToken(token);

      // Hanya 6 karakter awal yang boleh terlihat
      expect(tersamar.startsWith('dummy.'), isTrue);
      expect(tersamar.contains('123456789'), isFalse);
      expect(tersamar.contains('\u2022'), isTrue);

      expect(KartuSesi.samarkanToken(''), equals('(kosong)'));
      expect(KartuSesi.samarkanToken('abc'), equals('•••'));
    });

    // ---------------------------------------------------------
    // 2. PENGUJIAN PENYIMPANAN SesiMemori
    // ---------------------------------------------------------
    test('6. SesiMemori: simpan, baca, dan hapus sesi dalam memori proses', () async {
      final memori = SesiMemori();
      expect(memori.baca(), isNull);
      expect(memori.adaSesi, isFalse);
      expect(memori.jumlahPenulisan, equals(0));

      final sesi = SesiPengguna.contoh();
      await memori.simpan(sesi);
      expect(memori.baca(), equals(sesi));
      expect(memori.adaSesi, isTrue);
      expect(memori.jumlahPenulisan, equals(1));

      await memori.hapus();
      expect(memori.baca(), isNull);
      expect(memori.adaSesi, isFalse);
      expect(memori.jumlahPenulisan, equals(1)); // Jumlah penulisan tetap tercatat
    });

    // ---------------------------------------------------------
    // 3. PENGUJIAN API TIRUAN AuthApi
    // ---------------------------------------------------------
    test('7. AuthApi: memvalidasi input kosong, terkunci, server gangguan, dan kredensial salah', () async {
      const api = AuthApi(tunda: Duration.zero);

      // Email atau sandi kosong
      expect(
        () => api.masuk(email: '', sandi: '12345678'),
        throwsA(isA<AuthException>().having((e) => e.kode, 'kode', 400)),
      );

      // Akun terkunci
      expect(
        () => api.masuk(email: AuthApi.emailTerkunci, sandi: '12345678'),
        throwsA(isA<AuthException>().having((e) => e.kode, 'kode', 423)),
      );

      // Gangguan server
      expect(
        () => api.masuk(email: AuthApi.emailServerGangguan, sandi: '12345678'),
        throwsA(isA<AuthException>().having((e) => e.kode, 'kode', 503)),
      );

      // Latihan Mandiri 1: Akun belum aktif
      expect(
        () => api.masuk(email: AuthApi.emailBelumAktif, sandi: '12345678'),
        throwsA(isA<AuthException>().having((e) => e.kode, 'kode', 403)),
      );

      // Password salah
      expect(
        () => api.masuk(email: AuthApi.emailDemo, sandi: 'salahPassword'),
        throwsA(isA<AuthException>()
            .having((e) => e.kode, 'kode', 401)
            .having((e) => e.pesan, 'pesan', 'Email atau kata sandi salah.')),
      );
    });

    test('8. AuthApi: kredensial benar menghasilkan sesi dan perbaruiSesi bekerja', () async {
      const api = AuthApi(tunda: Duration.zero);

      final sesi = await api.masuk(
        email: AuthApi.emailDemo,
        sandi: AuthApi.sandiDemo,
      );

      expect(sesi.email, equals(AuthApi.emailDemo));
      expect(sesi.nama, equals('Mahasiswa TRPL'));
      expect(sesi.token.startsWith('dummy.'), isTrue);

      final sesiBaru = await api.perbaruiSesi(sesi, masaBerlaku: const Duration(hours: 3));
      expect(sesiBaru.token, equals(sesi.token));
      expect(sesiBaru.email, equals(sesi.email));
    });

    // ---------------------------------------------------------
    // 4. PENGUJIAN WIDGET FieldKataSandi
    // ---------------------------------------------------------
    testWidgets('9. FieldKataSandi: toggle visibilitas sandi berfungsi', (tester) async {
      final controller = TextEditingController(text: 'rahasia123');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FieldKataSandi(controller: controller),
          ),
        ),
      );

      final textFieldFinder = find.byType(TextField);
      expect(textFieldFinder, findsOneWidget);

      TextField widgetAwal = tester.widget(textFieldFinder);
      expect(widgetAwal.obscureText, isTrue);

      // Klik tombol intip sandi
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      TextField widgetSetelahTap = tester.widget(textFieldFinder);
      expect(widgetSetelahTap.obscureText, isFalse);
    });

    // ---------------------------------------------------------
    // 5. PENGUJIAN WIDGET LoginScreen & ALUR FORM
    // ---------------------------------------------------------
    testWidgets('10. Validasi form menolak email kosong dan format salah', (tester) async {
      const api = AuthApi(tunda: Duration.zero);
      final memori = SesiMemori();

      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(api: api, sesiMemori: memori),
        ),
      );
      await tester.pumpAndSettle();

      // Klik Masuk tanpa mengisi form
      await tester.tap(find.text('Masuk'));
      await tester.pumpAndSettle();

      expect(find.text('Email wajib diisi.'), findsOneWidget);
      expect(find.text('Kata sandi wajib diisi.'), findsOneWidget);

      // Isi email format salah
      await tester.enterText(find.byType(TextFormField).first, 'emailsalah');
      await tester.tap(find.text('Masuk'));
      await tester.pumpAndSettle();

      expect(find.text('Format email belum benar.'), findsOneWidget);

      // Isi kata sandi kurang dari 8 karakter
      await tester.enterText(find.byType(TextFormField).last, 'pendek');
      await tester.tap(find.text('Masuk'));
      await tester.pumpAndSettle();

      expect(find.text('Kata sandi minimal 8 karakter.'), findsOneWidget);
    });

    testWidgets('11. Login gagal menampilkan pesan kesalahan yang sesuai (AuthException)', (tester) async {
      const api = AuthApi(tunda: Duration.zero);
      final memori = SesiMemori();

      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(api: api, sesiMemori: memori),
        ),
      );
      await tester.pumpAndSettle();

      // Masukkan kredensial salah
      await tester.enterText(find.byType(TextFormField).first, 'user@trpl.test');
      await tester.enterText(find.byType(TextFormField).last, 'password123');

      await tester.tap(find.text('Masuk'));
      await tester.pumpAndSettle();

      expect(find.text('Email atau kata sandi salah.'), findsOneWidget);
      expect(memori.adaSesi, isFalse);
    });

    testWidgets('12. Login berhasil berpindah ke beranda dan menampilkan info sesi tersamar', (tester) async {
      const api = AuthApi(tunda: Duration.zero);
      final memori = SesiMemori();

      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(api: api, sesiMemori: memori),
        ),
      );
      await tester.pumpAndSettle();

      // Tekan tombol Isi Otomatis Demo
      await tester.tap(find.text('Isi Otomatis Demo'));
      await tester.pumpAndSettle();

      // Tekan Masuk
      await tester.tap(find.text('Masuk'));
      await tester.pumpAndSettle();

      // Memastikan berpindah ke Beranda
      expect(find.text('Beranda'), findsOneWidget);
      expect(find.text('Mahasiswa TRPL'), findsOneWidget);
      expect(find.text('student@trpl.test'), findsOneWidget);
      expect(find.text('Mahasiswa'), findsOneWidget);
      expect(find.textContaining('Sesi ini hanya ada di memori proses', skipOffstage: false), findsWidgets);

      // Sesi tersimpan di SesiMemori
      expect(memori.adaSesi, isTrue);
      expect(memori.baca()?.email, equals('student@trpl.test'));
    });

    testWidgets('13. Ketahanan ganda: Masuk dinonaktifkan saat memproses dan cegah kirim ganda', (tester) async {
      const jeda = Duration(milliseconds: 300);
      const api = AuthApi(tunda: jeda);
      final memori = SesiMemori();

      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(api: api, sesiMemori: memori),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Isi Otomatis Demo'));
      await tester.pumpAndSettle();

      // Ketuk pertama kali
      await tester.tap(find.text('Masuk'));
      await tester.pump(const Duration(milliseconds: 50));

      // Verifikasi tombol berubah ke "Memproses…" dan nonaktif
      expect(find.text('Memproses…'), findsOneWidget);
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);

      // Coba tap tombol lagi saat memproses
      await tester.tap(find.byType(FilledButton), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 50));

      // Selesaikan jeda API
      await tester.pumpAndSettle();

      // Hanya ada 1 kali penulisan sesi
      expect(memori.jumlahPenulisan, equals(1));
      expect(find.text('Beranda'), findsOneWidget);
    });

    testWidgets('14. Logout mengembalikan status ke keluar (bukan gagal) dan mengosongkan sesi', (tester) async {
      const api = AuthApi(tunda: Duration.zero);
      final memori = SesiMemori();

      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(api: api, sesiMemori: memori),
        ),
      );
      await tester.pumpAndSettle();

      // Login
      await tester.tap(find.text('Isi Otomatis Demo'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Masuk'));
      await tester.pumpAndSettle();

      expect(find.text('Beranda'), findsOneWidget);

      // Tekan tombol keluar
      await tester.tap(find.text('Keluar dari Sesi'));
      await tester.pumpAndSettle();

      // Kembali ke form login
      expect(find.text('Masuk ke Portal Akademik'), findsOneWidget);
      expect(memori.adaSesi, isFalse);

      // Verifikasi TIDAK muncul pesan gagal saat logout sukses
      expect(find.text('Email atau kata sandi salah.'), findsNothing);
    });

    testWidgets('15. Pemulihan sesi: sesi kedaluwarsa dibuang otomatis dan meminta login ulang', (tester) async {
      const api = AuthApi(tunda: Duration.zero);
      final memori = SesiMemori();

      // Buat sesi yang sudah kedaluwarsa
      final waktuDulu = DateTime(2026, 1, 1, 8, 0);
      final sesiKadaluarsa = SesiPengguna.contoh(
        sekarang: waktuDulu,
        masaBerlaku: const Duration(hours: 1),
      );
      await memori.simpan(sesiKadaluarsa);

      // Buka aplikasi pada waktu sekarang yang jauh melampaui masa berlaku
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(
            api: api,
            sesiMemori: memori,
            jam: () => DateTime(2026, 9, 21, 10, 0),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Sesi mati harus dihapus
      expect(memori.adaSesi, isFalse);

      // Form login menampilkan pesan sesi berakhir
      expect(find.text('Sesi sebelumnya sudah berakhir. Silakan masuk lagi.'), findsOneWidget);
    });

    testWidgets('16. Latihan Mandiri 3: Tombol Batal membatalkan proses login yang sedang berjalan', (tester) async {
      const jeda = Duration(milliseconds: 300);
      const api = AuthApi(tunda: jeda);
      final memori = SesiMemori();

      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(api: api, sesiMemori: memori),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Isi Otomatis Demo'));
      await tester.pumpAndSettle();

      // Mulai login
      await tester.tap(find.text('Masuk'));
      await tester.pump(const Duration(milliseconds: 50));

      // Tombol Batal muncul saat memproses
      expect(find.text('Batal'), findsOneWidget);
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();

      // Kembali ke form dan tidak menyimpan sesi
      expect(find.text('Masuk'), findsOneWidget);
      expect(memori.adaSesi, isFalse);
    });
  });

  group('Modul 06 Pengayaan: Fase B (Secure Storage, Gerbang Sesi & Refleksi Keamanan)', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('17. Kontrak Repositori: Memori, Prefs, dan Aman memenuhi interface SesiRepository', () async {
      final sesi = SesiPengguna.contoh();
      final storage = MockPenyimpananAman();

      final repos = [
        MemoriSesiRepository(),
        PrefsSesiRepository(SharedPreferences.getInstance()),
        AmanSesiRepository(storage),
      ];

      for (final repo in repos) {
        expect(await repo.adaSesi(), isFalse);
        expect(await repo.baca(), isNull);

        await repo.simpan(sesi);
        expect(await repo.adaSesi(), isTrue);
        final bacaan = await repo.baca();
        expect(bacaan?.token, equals(sesi.token));

        await repo.hapus();
        expect(await repo.adaSesi(), isFalse);
      }
    });

    test('18. Audit Keamanan: intipMentah membuktikan kebocoran pada Prefs dan perlindungan pada Aman', () async {
      final sesi = SesiPengguna.contoh(token: 'dummy.secret.token.123');
      final storage = MockPenyimpananAman();

      final repoPrefs = PrefsSesiRepository(SharedPreferences.getInstance());
      final repoAman = AmanSesiRepository(storage);

      await repoPrefs.simpan(sesi);
      await repoAman.simpan(sesi);

      // SharedPreferences: data JSON mentah terbaca apa adanya
      final intipPrefs = await repoPrefs.intipMentah();
      expect(intipPrefs, isNotNull);
      expect(intipPrefs!.contains('dummy.secret.token.123'), isTrue);

      // Secure Storage: API mentah mengembalikan null (terlindungi enkripsi platform)
      final intipAman = await repoAman.intipMentah();
      expect(intipAman, isNull);
    });

    test('19. SesiController: pulihkan, perbaruiSesi, dan pembuangan sesi kedaluwarsa', () async {
      const api = AuthApi(tunda: Duration.zero);
      final storage = MockPenyimpananAman();
      final repo = AmanSesiRepository(storage);

      // Waktu dasar mengikuti jam sistem saat ini
      final waktuAwal = DateTime.now();
      var waktuSekarang = waktuAwal;

      final controller = SesiController(
        api: api,
        repository: repo,
        jam: () => waktuSekarang,
      );

      // Login sukses
      await controller.masuk(AuthApi.emailDemo, AuthApi.sandiDemo);
      expect(controller.status, equals(StatusSesi.masuk));
      expect(controller.sesi?.email, equals(AuthApi.emailDemo));

      // Perbarui sesi saat masih aktif (+2 jam)
      waktuSekarang = waktuAwal.add(const Duration(hours: 1));
      await controller.perbaruiSesi(masaBerlaku: const Duration(hours: 2));
      expect(controller.status, equals(StatusSesi.masuk));

      // Waktu melampaui kedaluwarsa (+5 jam kemudian)
      waktuSekarang = waktuAwal.add(const Duration(hours: 5));
      await controller.perbaruiSesi();
      // Pembaruan sesi yang sudah mati harus ditolak dan dibuang
      expect(controller.status, equals(StatusSesi.kedaluwarsa));
      expect(controller.sesi, isNull);
      expect(await repo.adaSesi(), isFalse);

      controller.dispose();
    });

    testWidgets('20. GerbangSesi: berpindah tampilan otomatis tanpa logika navigasi di layar login', (tester) async {
      const api = AuthApi(tunda: Duration.zero);
      final memoriRepo = MemoriSesiRepository();

      final controller = SesiController(
        api: api,
        repository: memoriRepo,
      );
      await tester.runAsync(() => controller.pulihkan());

      await tester.pumpWidget(
        MaterialApp(
          home: GerbangSesi(
            controller: controller,
            form: (_) => const Text('Tampilan Form Login'),
            beranda: (_, sesi) => Text('Tampilan Beranda: ${sesi.nama}'),
          ),
        ),
      );
      await tester.pump();

      // Keadaan awal (belum login) -> menampilkan Form
      expect(find.text('Tampilan Form Login'), findsOneWidget);
      expect(find.textContaining('Tampilan Beranda'), findsNothing);

      // Login via controller (dijalankan di runAsync karena ada Future.delayed)
      await tester.runAsync(() => controller.masuk(AuthApi.emailDemo, AuthApi.sandiDemo));
      await tester.pump();

      // Gerbang otomatis beralih ke Beranda
      expect(find.text('Tampilan Form Login'), findsNothing);
      expect(find.text('Tampilan Beranda: Mahasiswa TRPL'), findsOneWidget);

      // Logout via controller
      await tester.runAsync(() => controller.keluar());
      await tester.pump();

      // Kembali ke Form
      expect(find.text('Tampilan Form Login'), findsOneWidget);

      controller.dispose();
    });
  });
}
