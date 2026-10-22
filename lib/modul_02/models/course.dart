// Model data untuk mata kuliah
class Course {
  final String code;
  final String name;
  final String lecturer;
  final int sks;
  final double progress; // progres silabus (0.0 - 1.0)
  final String room;
  final String category; // 'Teori' atau 'Praktikum', dipakai untuk filter Tantangan 1

  const Course({
    required this.code,
    required this.name,
    required this.lecturer,
    required this.sks,
    required this.progress,
    this.room = 'Lab Komputer 3',
    this.category = 'Teori',
  });

  // Data mata kuliah Semester 5 - TRPL Poliwangi 2E
  static List<Course> getSampleCourses() {
    return const [
      Course(
        code: 'TRPL501',
        name: 'Pemrograman Perangkat Bergerak',
        lecturer: 'Sepyan Purnama Kristanto, M.Kom.',
        sks: 4,
        progress: 0.25,
        room: 'Lab Komputer 3',
        category: 'Praktikum',
      ),
      Course(
        code: 'TRPL502',
        name: 'Arsitektur Perangkat Lunak',
        lecturer: 'Tim Dosen TRPL',
        sks: 3,
        progress: 0.40,
        room: 'Ruang Teori 201',
        category: 'Teori',
      ),
      Course(
        code: 'TRPL503',
        name: 'Manajemen Proyek Agile & DevOps',
        lecturer: 'Tim Dosen TRPL',
        sks: 3,
        progress: 0.60,
        room: 'Ruang Teori 104',
        category: 'Teori',
      ),
      Course(
        code: 'TRPL504',
        name: 'Penjaminan Mutu Perangkat Lunak (QA)',
        lecturer: 'Tim Dosen TRPL',
        sks: 2,
        progress: 0.15,
        room: 'Lab Jaringan',
        category: 'Praktikum',
      ),
      Course(
        code: 'TRPL505',
        name: 'Interaksi Manusia dan Komputer',
        lecturer: 'Tim Dosen TRPL',
        sks: 3,
        progress: 0.30,
        room: 'Ruang Teori 302',
        category: 'Teori',
      ),
    ];
  }
}
