import 'package:flutter/material.dart';
import '../repositories/sesi_repository.dart';

class PapanDiagnostikPenyimpanan extends StatefulWidget {
  final SesiRepository repository;

  const PapanDiagnostikPenyimpanan({super.key, required this.repository});

  @override
  State<PapanDiagnostikPenyimpanan> createState() =>
      _PapanDiagnostikPenyimpananState();
}

class _PapanDiagnostikPenyimpananState
    extends State<PapanDiagnostikPenyimpanan> {
  String? _hasilIntip;
  bool _sedangMengintip = false;
  bool _sudahMengintip = false;

  Future<void> _intip() async {
    setState(() => _sedangMengintip = true);
    final String? hasil = await widget.repository.intipMentah();
    if (!mounted) return;
    setState(() {
      _hasilIntip = hasil;
      _sudahMengintip = true;
      _sedangMengintip = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isAman = widget.repository.nama == 'Aman';

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.security_rounded, size: 20, color: Color(0xFF0284C7)),
                const SizedBox(width: 8),
                Text(
                  'Diagnostik: Repositori ${widget.repository.nama}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              widget.repository.keterangan,
              style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 38,
              child: OutlinedButton.icon(
                onPressed: _sedangMengintip ? null : _intip,
                icon: const Icon(Icons.visibility_rounded, size: 16),
                label: Text(
                  _sedangMengintip ? 'Mengintip…' : 'Intip Isi Penyimpanan (Audit)',
                ),
              ),
            ),
            if (_sudahMengintip) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isAman
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAman
                          ? '✅ Hasil: Terenkripsi Platform (null via API mentah)'
                          : '⚠️ Hasil: Bocor! Data JSON mentah terbaca:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: isAman
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onErrorContainer,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _hasilIntip ?? '(Token dilindungi dan tidak dapat diekstrak)',
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                        color: isAman
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
