import 'package:flutter/material.dart';

// Banner header profil mahasiswa di bagian atas dashboard
class HeaderBanner extends StatelessWidget {
  final String studentName;
  final String nim;
  final int courseCount;
  final int totalSks;

  const HeaderBanner({
    super.key,
    this.studentName = 'Muhammad Daffa Ariby Hidayat',
    this.nim = '362558302081',
    this.courseCount = 0,
    this.totalSks = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0284C7).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Semester 5 (2026/2027)',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.notifications_active_outlined, color: Colors.white, size: 20),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Selamat Datang, $studentName ($nim)',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 4),
          const Text(
            'Dashboard Akademik & Proyek',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Wrap mencegah overflow pada layar sempit atau font besar.
          // Tantangan 3: badge total SKS ditampilkan di sini di sebelah nama.
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatPill(icon: Icons.task_alt, label: '$courseCount Matakuliah'),
              _StatPill(icon: Icons.co_present_rounded, label: '$totalSks SKS Diambil'),
              const _StatPill(icon: Icons.grade, label: 'IPK 3.85'),
            ],
          ),
        ],
      ),
    );
  }
}

// Widget kecil untuk menampilkan pill status (ikon + label)
class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
