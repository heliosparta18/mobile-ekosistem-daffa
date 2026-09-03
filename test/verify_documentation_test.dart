import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Autograding Dokumentasi & Identitas Mahasiswa', () {
    test('1. File README.md telah diisi dengan identitas asli mahasiswa', () {
      final file = File('README.md');
      expect(file.existsSync(), isTrue, reason: 'File README.md wajib ada di root repositori.');

      final content = file.readAsStringSync();
      
      // Verifikasi bahwa placeholder telah diganti dengan data asli
      expect(
        content.contains('362458302000') || content.contains('3624XXXXXXXX'),
        isFalse,
        reason: 'Placeholder NIM belum diganti dengan NIM Asli Anda di file README.md.',
      );
      expect(
        content.contains('Nama Lengkap Anda') || content.contains('Mahasiswa TRPL Poliwangi'),
        isFalse,
        reason: 'Placeholder Nama belum diganti dengan Nama Lengkap Anda sendiri di file README.md.',
      );
    });
  });
}
