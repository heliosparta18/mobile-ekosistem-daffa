import '../models/announcement.dart';
import 'announcement_repository.dart';

/// Implementasi data lokal offline/simulasi (Fase B & testing)
class SampleAnnouncementRepository implements AnnouncementRepository {
  /// Menggunakan List.of agar list dapat dimodifikasi saat runtime jika diperlukan
  final List<Announcement> _items =
      List<Announcement>.of(Announcement.getSampleAnnouncements());

  @override
  Future<List<Announcement>> getAnnouncements({String? category}) async {
    // Simulasi jeda network singkat
    await Future<void>.delayed(const Duration(milliseconds: 400));

    if (category == null || category == 'Semua') {
      return List<Announcement>.unmodifiable(_items);
    }

    return _items
        .where((item) => item.category.toLowerCase() == category.toLowerCase())
        .toList(growable: false);
  }

  @override
  Future<Announcement> addAnnouncement(Announcement announcement) async {
    _items.add(announcement);
    return announcement;
  }
}
