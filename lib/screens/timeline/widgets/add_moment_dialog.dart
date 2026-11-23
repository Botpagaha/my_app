import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_colors.dart';
import '../../../models/moment.dart';
import '../../../services/storage_service.dart';

class AddMomentDialog extends StatefulWidget {
  final StorageService storageService;

  const AddMomentDialog({super.key, required this.storageService});

  @override
  State<AddMomentDialog> createState() => _AddMomentDialogState();
}

class _AddMomentDialogState extends State<AddMomentDialog> {
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _storyController = TextEditingController();
  DateTime _momentDate = DateTime.now();

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _storyController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_titleController.text.trim().isEmpty) return;

    final newMoment = Moment(
      id: 'moment_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      date: _momentDate,
      location: _locationController.text.trim(),
      story: _storyController.text.trim(),
      createdBy: widget.storageService.currentUserName,
    );

    widget.storageService.addMoment(newMoment);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Momen kenangan berhasil diabadikan! ✨'),
          ],
        ),
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
              'Abadikan Momen Baru',
              style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Tulis cerita manis atau peristiwa berharga berdua',
              style: textTheme.bodySmall?.copyWith(color: AppColors.outline),
            ),
            const SizedBox(height: 20),

            // Title
            Text('Judul Momen *', style: textTheme.labelMedium),
            const SizedBox(height: 6),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Contoh: Kencan Pertama di Toko Buku...',
              ),
            ),
            const SizedBox(height: 16),

            // Date
            Text('Tanggal Kejadian', style: textTheme.labelMedium),
            const SizedBox(height: 6),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _momentDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() => _momentDate = picked);
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
                    const Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(_momentDate),
                      style: const TextStyle(fontSize: 14, color: AppColors.onSurface),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Location
            Text('Lokasi Kenangan (Opsional)', style: textTheme.labelMedium),
            const SizedBox(height: 6),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                hintText: 'Contoh: Taman Suropati, Menteng...',
                prefixIcon: Icon(Icons.place_outlined, color: AppColors.outline),
              ),
            ),
            const SizedBox(height: 16),

            // Story
            Text('Cerita / Catatan Manis', style: textTheme.labelMedium),
            const SizedBox(height: 6),
            TextField(
              controller: _storyController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Tulis hal kecil yang membuatmu tersenyum hari itu...',
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
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text('Simpan Momen ke Linimasa', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
