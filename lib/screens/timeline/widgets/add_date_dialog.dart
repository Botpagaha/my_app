import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_colors.dart';
import '../../../models/important_date.dart';
import '../../../services/storage_service.dart';

class AddDateDialog extends StatefulWidget {
  final StorageService storageService;

  const AddDateDialog({super.key, required this.storageService});

  @override
  State<AddDateDialog> createState() => _AddDateDialogState();
}

class _AddDateDialogState extends State<AddDateDialog> {
  final _titleController = TextEditingController();
  DateTime _date = DateTime.now();
  bool _repeatsYearly = true;
  String _selectedEmoji = '💖';

  final List<String> _emojis = ['💖', '🎂', '🎁', '✈️', '💍', '🌸', '☕', '🎬'];

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_titleController.text.trim().isEmpty) return;

    final newDate = ImportantDate(
      id: 'date_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      date: _date,
      repeatsYearly: _repeatsYearly,
      iconEmoji: _selectedEmoji,
      createdBy: widget.storageService.currentUserName,
    );

    widget.storageService.addImportantDate(newDate);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Tanggal penting berhasil ditambahkan! 📅'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Tambah Tanggal Penting',
              style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Pengingat hari istimewa dengan hitung mundur otomatis',
              style: textTheme.bodySmall?.copyWith(color: AppColors.outline),
            ),
            const SizedBox(height: 20),

            // Emoji selector
            Text('Ikon Momen', style: textTheme.labelMedium),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _emojis.map((emoji) {
                  final isSelected = _selectedEmoji == emoji;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedEmoji = emoji),
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryContainer : AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Text(emoji, style: const TextStyle(fontSize: 22)),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text('Nama Peristiwa / Tanggal *', style: textTheme.labelMedium),
            const SizedBox(height: 6),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Contoh: Hari Ulang Tahun Cinta 🎂...',
              ),
            ),
            const SizedBox(height: 16),

            // Date
            Text('Tanggal', style: textTheme.labelMedium),
            const SizedBox(height: 6),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2035),
                );
                if (picked != null) {
                  setState(() => _date = picked);
                }
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.outlineVariant),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.event_note_rounded, color: AppColors.primary, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(_date),
                      style: const TextStyle(fontSize: 14, color: AppColors.onSurface),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Repeat yearly switch
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.surfaceContainerHigh),
              ),
              child: Row(
                children: [
                  const Icon(Icons.repeat_rounded, color: AppColors.primary, size: 20),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ulangi Tiap Tahun', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        Text('Cocok untuk anniversary & hari ulang tahun', style: TextStyle(fontSize: 11, color: AppColors.outline)),
                      ],
                    ),
                  ),
                  Switch(
                    value: _repeatsYearly,
                    activeTrackColor: AppColors.primaryContainer,
                    activeThumbColor: AppColors.primary,
                    onChanged: (val) => setState(() => _repeatsYearly = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Simpan Tanggal Penting', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
