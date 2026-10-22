import 'package:flutter/material.dart';
import 'models/course.dart';
import 'widgets/course_card.dart';
import 'widgets/header_banner.dart';

class AcademicDashboardScreen extends StatefulWidget {
  const AcademicDashboardScreen({super.key});

  @override
  State<AcademicDashboardScreen> createState() =>
      _AcademicDashboardScreenState();
}

class _AcademicDashboardScreenState extends State<AcademicDashboardScreen> {
  final List<Course> _courses = Course.getSampleCourses();
  bool _isDarkMode = false;

  // Tantangan 1: state kategori filter yang sedang dipilih
  String _selectedCategory = 'Semua';
  static const List<String> _categories = ['Semua', 'Teori', 'Praktikum'];

  // Batas maksimal SKS per semester (Tantangan 3)
  static const int _maxSksPerSemester = 24;

  void _toggleDarkMode() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  // fold(): Menjumlahkan bobot SKS dari seluruh objek Course di dalam list
  int get _totalSks => _courses.fold(0, (sum, c) => sum + c.sks);

  List<Course> get _filteredCourses {
    if (_selectedCategory == 'Semua') return _courses;
    return _courses.where((c) => c.category == _selectedCategory).toList();
  }

  // Tantangan 1: baris filter kategori dengan Wrap + ChoiceChip
  Widget _buildCategoryFilter() {
    return Wrap(
      spacing: 8.0,
      children: _categories.map((category) {
        return ChoiceChip(
          label: Text(category),
          selected: _selectedCategory == category,
          onSelected: (selected) {
            if (selected) {
              setState(() {
                _selectedCategory = category;
              });
            }
          },
        );
      }).toList(),
    );
  }

  // Tantangan 3: peringatan visual jika total SKS melebihi kuota
  Widget _buildSksWarning() {
    if (_totalSks <= _maxSksPerSemester) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Peringatan: Total SKS melebihi batas maksimal 24 SKS per semester!',
              style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredCourses;

    return Theme(
      data: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0284C7),
          brightness: _isDarkMode ? Brightness.dark : Brightness.light,
        ),
        useMaterial3: true,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Dashboard Akademik TRPL',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF0284C7),
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: Icon(_isDarkMode
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded),
              tooltip: _isDarkMode ? 'Mode Terang' : 'Mode Gelap',
              onPressed: _toggleDarkMode,
            ),
          ],
        ),
        // LayoutBuilder membaca ukuran layar untuk menentukan tata letak responsif
        body: LayoutBuilder(
          builder: (context, constraints) {
            final header = HeaderBanner(
              courseCount: _courses.length,
              totalSks: _totalSks,
            );

            // Breakpoint 600dp: Tablet / Landscape menggunakan 2 kolom
            if (constraints.maxWidth >= 600) {
              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kolom kiri: banner profil + peringatan SKS
                    Expanded(
                      flex: 2,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            header,
                            _buildSksWarning(),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Kolom kanan: filter kategori + grid mata kuliah
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCategoryFilter(),
                          const SizedBox(height: 12),
                          Expanded(
                            child: GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithMaxCrossAxisExtent(
                                // Lebar kartu tidak melebihi 340 dp. Pada ruang
                                // yang cukup GridView menambah kolom; pada
                                // ruang sempit jumlah kolom otomatis berkurang.
                                maxCrossAxisExtent: 340,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                // Tinggi eksplisit agar seluruh isi CourseCard muat.
                                mainAxisExtent: 240,
                              ),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                return CourseCard(course: filtered[index]);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            // Default (smartphone): tata letak 1 kolom vertikal
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                header,
                _buildSksWarning(),
                const SizedBox(height: 16),
                Text(
                  'Mata Kuliah Semester 5 (${filtered.length} Terdaftar)',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildCategoryFilter(),
                const SizedBox(height: 12),
                ...filtered.map((course) => CourseCard(course: course)),
              ],
            );
          },
        ),
      ),
    );
  }
}
