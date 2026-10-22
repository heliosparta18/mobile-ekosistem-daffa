import 'package:flutter/material.dart';
import '../models/course.dart';

class CourseCard extends StatelessWidget {
  final Course course;

  const CourseCard({super.key, required this.course});

  // Tantangan 2: Modal BottomSheet rincian silabus interaktif
  void _showCourseDetail(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                course.code,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 4),
              Text(course.name, style: theme.textTheme.titleLarge),
              const SizedBox(height: 12),

              // Informasi dosen pengampu dengan avatar
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(
                      Icons.person,
                      size: 18,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Dosen: ${course.lecturer}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Rincian akademik: SKS, ruangan, progress
              Text('Bobot: ${course.sks} SKS'),
              const SizedBox(height: 4),
              Text('Jadwal / Ruangan: ${course.room}'),
              const SizedBox(height: 4),
              Text('Progress Pembelajaran: ${(course.progress * 100).toInt()}%'),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Tutup Rincian'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      // InkWell agar kartu merespons ketukan (Tantangan 2) sekaligus
      // memberi efek ripple Material di atas Stack konten + badge.
      child: InkWell(
        onTap: () => _showCourseDetail(context),
        // Pakai Stack agar badge SKS bisa menimpa pojok kanan atas kartu
        child: Stack(
          children: [
            // Konten utama kartu
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.code,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Batasi judul maksimal 2 baris agar tinggi kartu tetap konsisten
                  Text(
                    course.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Info dosen pengampu
                  Row(
                    children: [
                      Icon(Icons.person_outline, size: 16, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          course.lecturer,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Ruang kelas/lab
                  Row(
                    children: [
                      Icon(Icons.meeting_room_outlined, size: 16, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          course.room,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),

                  // Jarak vertikal tetap sebelum progress bar.
                  // Jangan gunakan Spacer: tinggi Column ini mengikuti konten Card,
                  // sehingga tidak memiliki sisa tinggi yang pasti untuk dibagi.
                  const SizedBox(height: 16),

                  // Progress bar silabus
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Progres Sesi', style: theme.textTheme.labelSmall),
                          Text(
                            '${(course.progress * 100).toInt()}%',
                            style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: course.progress,
                        borderRadius: BorderRadius.circular(4),
                        minHeight: 6,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Badge SKS di pojok kanan atas
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${course.sks} SKS',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
