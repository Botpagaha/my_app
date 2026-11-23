import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  final StorageService storageService;
  final VoidCallback onLogout;

  const SettingsScreen({
    super.key,
    required this.storageService,
    required this.onLogout,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late DateTime _selectedAnniversary;
  late TextEditingController _nickMiftahController;
  late TextEditingController _nickCintaController;

  final _currentPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedAnniversary = widget.storageService.anniversaryDate;
    _nickMiftahController = TextEditingController(text: widget.storageService.nickMiftah);
    _nickCintaController = TextEditingController(text: widget.storageService.nickCinta);
  }

  @override
  void dispose() {
    _nickMiftahController.dispose();
    _nickCintaController.dispose();
    _currentPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  void _saveAnniversary() async {
    await widget.storageService.updateAnniversaryDate(_selectedAnniversary);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.favorite_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Tanggal jadian diperbarui! Hitung hari diperbarui otomatis ❤️'),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _saveNicknames() async {
    await widget.storageService.updateNicknames(
      _nickMiftahController.text.trim(),
      _nickCintaController.text.trim(),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Nama panggilan kesayangan berhasil disimpan! ✨'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _changePassword() {
    if (_newPassController.text.isEmpty || _newPassController.text != _confirmPassController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kata sandi baru tidak cocok atau masih kosong!'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    _currentPassController.clear();
    _newPassController.clear();
    _confirmPassController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Kata sandi berhasil diperbarui! 🔒'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _exportJson() {
    final jsonString = widget.storageService.exportDataAsJson();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.download_for_offline_rounded, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Ekspor Data (.json)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Data seluruh kenangan, tanggal penting, dan bucket list siap dicadangkan:',
                style: TextStyle(fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 12),
              Container(
                height: 160,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    jsonString,
                    style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup', style: TextStyle(color: AppColors.outline)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: jsonString));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('JSON cadangan disalin ke clipboard! 📋'),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            icon: const Icon(Icons.copy_rounded, size: 16),
            label: const Text('Salin JSON'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Pengaturan Ruang Berdua',
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Anniversary Date
            _buildSectionHeader('Momen Spesial & Tanggal Jadian', Icons.favorite_rounded),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _cardBoxDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tanggal Jadian Utama',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.outline),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedAnniversary,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() => _selectedAnniversary = picked);
                      }
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.outlineVariant),
                        borderRadius: BorderRadius.circular(14),
                        color: Colors.white,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month_rounded, color: AppColors.primary),
                          const SizedBox(width: 12),
                          Text(
                            DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(_selectedAnniversary),
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                          const Spacer(),
                          const Text('Ubah', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _saveAnniversary,
                      icon: const Icon(Icons.favorite_rounded, size: 16),
                      label: const Text('Simpan Perubahan Tanggal'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section 2: Nicknames
            _buildSectionHeader('Nama Panggilan Kesayangan', Icons.auto_awesome_rounded),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _cardBoxDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Panggilan untuk Miftah', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.outline)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _nickMiftahController,
                    decoration: const InputDecoration(hintText: 'Contoh: Mas Sayang'),
                  ),
                  const SizedBox(height: 14),
                  const Text('Panggilan untuk Cinta', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.outline)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _nickCintaController,
                    decoration: const InputDecoration(hintText: 'Contoh: Bidadari'),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _saveNicknames,
                      icon: const Icon(Icons.edit_note_rounded, size: 18),
                      label: const Text('Perbarui Nama Panggilan'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section 3: Account Security
            _buildSectionHeader('Keamanan Akun Privat', Icons.lock_outline_rounded),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _cardBoxDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 14,
                        backgroundColor: AppColors.primary,
                        child: Icon(Icons.person, color: Colors.white, size: 16),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Masuk sebagai: ${widget.storageService.currentUserEmail}',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _currentPassController,
                    obscureText: true,
                    decoration: const InputDecoration(hintText: 'Kata sandi saat ini'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _newPassController,
                    obscureText: true,
                    decoration: const InputDecoration(hintText: 'Kata sandi baru'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _confirmPassController,
                    obscureText: true,
                    decoration: const InputDecoration(hintText: 'Konfirmasi kata sandi baru'),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _changePassword,
                      icon: const Icon(Icons.key_rounded, size: 18),
                      label: const Text('Perbarui Kata Sandi'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section 4: Storage & Backup
            _buildSectionHeader('Penyimpanan & Cadangan', Icons.cloud_done_rounded),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _cardBoxDecoration(),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.successContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.security_rounded, color: AppColors.success, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Enkripsi Privat RLS Aktif',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            Text(
                              'Hanya 2 akun terotorisasi yang dapat membaca database.',
                              style: TextStyle(fontSize: 11, color: AppColors.outline),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  InkWell(
                    onTap: _exportJson,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.surfaceContainerHigh),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.download_for_offline_rounded, color: AppColors.primary),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Ekspor Data & Catatan (.json)',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded, color: AppColors.outline),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Logout Button
            Center(
              child: TextButton.icon(
                onPressed: () {
                  widget.storageService.logout();
                  widget.onLogout();
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('Keluar dari Ruang Privat', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardBoxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.surfaceContainerHigh),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}
