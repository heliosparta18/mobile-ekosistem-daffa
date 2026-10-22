import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/announcement_provider.dart';
import '../widgets/announcement_card.dart';
import 'announcement_detail_screen.dart';

class AnnouncementListScreen extends ConsumerWidget {
  const AnnouncementListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncAnnouncements = ref.watch(announcementsProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final categories = ['Semua', 'Akademik', 'Beasiswa', 'Kegiatan', 'Prestasi'];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Portal Pengumuman TRPL'),
        backgroundColor: const Color(0xFF0284C7),
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Segarkan Data',
            onPressed: () => ref.refresh(announcementsProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          // Baris filter kategori
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((cat) {
                  final isSelected = selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      selectedColor: const Color(0xFFE0F2FE),
                      labelStyle: TextStyle(
                        color: isSelected ? const Color(0xFF0284C7) : const Color(0xFF475569),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          ref.read(selectedCategoryProvider.notifier).state = cat;
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Area konten asinkron dengan pola 4-State (Loading, Error, Empty, Success)
          Expanded(
            child: asyncAnnouncements.when(
              // 1. STATE: LOADING
              loading: () => const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF0284C7)),
                    SizedBox(height: 16),
                    Text(
                      'Memuat pengumuman dari server...',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                    ),
                  ],
                ),
              ),

              // 2. STATE: ERROR
              error: (err, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cloud_off_rounded, size: 64, color: Colors.redAccent),
                      const SizedBox(height: 16),
                      const Text(
                        'Gagal Memuat Data',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        err.toString().replaceAll('Exception: ', ''),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => ref.refresh(announcementsProvider),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Coba Lagi'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0284C7),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 3 & 4. STATE: SUCCESS / EMPTY
              data: (items) {
                // Empty State
                if (items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.inbox_outlined, size: 64, color: Color(0xFF94A3B8)),
                        const SizedBox(height: 16),
                        Text(
                          'Tidak ada pengumuman untuk kategori "$selectedCategory"',
                          style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }

                // Success State dengan Pull-to-Refresh
                return RefreshIndicator(
                  color: const Color(0xFF0284C7),
                  onRefresh: () async {
                    return ref.refresh(announcementsProvider.future);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return AnnouncementCard(
                        announcement: item,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (ctx) => AnnouncementDetailScreen(announcement: item),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
