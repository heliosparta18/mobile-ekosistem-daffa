import 'package:flutter/material.dart';
import '../../../modul_06/services/auth_api.dart';
import '../../../modul_06/widgets/field_kata_sandi.dart';
import '../controllers/sesi_controller.dart';
import '../widgets/papan_diagnostik_penyimpanan.dart';

class LoginPengayaanScreen extends StatefulWidget {
  final SesiController controller;

  const LoginPengayaanScreen({super.key, required this.controller});

  @override
  State<LoginPengayaanScreen> createState() => _LoginPengayaanScreenState();
}

class _LoginPengayaanScreenState extends State<LoginPengayaanScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _sandi = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _sandi.dispose();
    super.dispose();
  }

  void _kirim() {
    if (widget.controller.sedangMemproses) return;
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    widget.controller.masuk(_email.text, _sandi.text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool sibuk = widget.controller.sedangMemproses;
    final String? pesan = widget.controller.pesan;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fase B — Gerbang Sesi & Secure Storage'),
        backgroundColor: theme.colorScheme.primaryContainer,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 8),
            const Icon(Icons.shield_outlined, size: 52, color: Color(0xFF0284C7)),
            const SizedBox(height: 12),
            const Text(
              'Masuk Portal Pengayaan (Fase B)',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Layar ini tidak mengelola status sendiri (keadaan diatur SesiController).',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 20),

            if (pesan != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  pesan,
                  style: TextStyle(
                    color: theme.colorScheme.onErrorContainer,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _email,
                    enabled: !sibuk,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      final t = (v ?? '').trim();
                      if (t.isEmpty) return 'Email wajib diisi.';
                      if (!t.contains('@') || !t.contains('.')) {
                        return 'Format email belum benar.';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.alternate_email_rounded),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FieldKataSandi(
                    controller: _sandi,
                    enabled: !sibuk,
                    validator: (v) =>
                        (v == null || v.length < 8) ? 'Minimal 8 karakter' : null,
                    onSubmitted: _kirim,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              height: 48,
              child: FilledButton.icon(
                onPressed: sibuk ? null : _kirim,
                icon: sibuk
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.login_rounded),
                label: Text(sibuk ? 'Memproses…' : 'Masuk (Fase B)'),
              ),
            ),
            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: sibuk
                  ? null
                  : () {
                      _email.text = AuthApi.emailDemo;
                      _sandi.text = AuthApi.sandiDemo;
                    },
              icon: const Icon(Icons.flash_on_rounded, size: 16),
              label: const Text('Isi Demo Kredensial'),
            ),
            const SizedBox(height: 20),

            PapanDiagnostikPenyimpanan(
              repository: widget.controller.repository,
            ),
          ],
        ),
      ),
    );
  }
}
