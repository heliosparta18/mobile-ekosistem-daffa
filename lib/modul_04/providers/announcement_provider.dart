import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/announcement.dart';
import '../repositories/announcement_repository.dart';
import '../repositories/announcement_repository_impl.dart';
import '../repositories/sample_announcement_repository.dart';

// Provider konfigurasi sumber data: true jika dijalankan dengan --dart-define=USE_SAMPLE_DATA=true
final useSampleDataProvider = Provider<bool>((ref) {
  const bool useSample = bool.fromEnvironment('USE_SAMPLE_DATA', defaultValue: false);
  return useSample;
});

// Provider untuk instance Repository (Dapat disuntikkan Sample atau Dio Impl)
final announcementRepositoryProvider = Provider<AnnouncementRepository>((ref) {
  if (ref.watch(useSampleDataProvider)) {
    return SampleAnnouncementRepository();
  }
  return AnnouncementRepositoryImpl();
});

// StateProvider untuk filter kategori aktif
final selectedCategoryProvider = StateProvider<String>((ref) {
  return 'Semua';
});

// FutureProvider untuk memuat daftar pengumuman dari API secara asinkron
// Otomatis menyediakan 4-state (AsyncValue): loading, data, error
final announcementsProvider = FutureProvider<List<Announcement>>((ref) async {
  final repository = ref.watch(announcementRepositoryProvider);
  final category = ref.watch(selectedCategoryProvider);

  return repository.getAnnouncements(category: category);
});
