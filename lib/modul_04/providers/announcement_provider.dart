import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/announcement.dart';
import '../repositories/announcement_repository.dart';
import '../repositories/announcement_repository_impl.dart';

// Provider untuk instance Repository
final announcementRepositoryProvider = Provider<AnnouncementRepository>((ref) {
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
