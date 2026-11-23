import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_colors.dart';
import '../../../models/bucket_item.dart';
import '../../../services/storage_service.dart';

class AddBucketItemDialog extends StatefulWidget {
  final StorageService storageService;

  const AddBucketItemDialog({super.key, required this.storageService});

  @override
  State<AddBucketItemDialog> createState() => _AddBucketItemDialogState();
}

class _AddBucketItemDialogState extends State<AddBucketItemDialog> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedCategory = 'tempat';
  DateTime? _targetDate;

  final List<Map<String, String>> _categories = [
    {'id': 'tempat', 'label': 'Tempat 📍'},
    {'id': 'makanan', 'label': 'Makanan ☕'},
    {'id': 'film', 'label': 'Film 🎬'},
    {'id': 'lainnya', 'label': 'Lainnya ✨'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_titleController.text.trim().isEmpty) return;

    final newItem = BucketItem(
      id: 'item_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      category: _selectedCategory,
      notes: _notesController.text.trim(),
      targetDate: _targetDate,
      createdBy: widget.storageService.currentUserName,
    );

    widget.storageService.addBucketItem(newItem);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Rencana baru berhasil disimpan! ✨'),
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
              'Rencana Baru Berdua',
              style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Catat ide kencan atau impian indah berikutnya',
              style: textTheme.bodySmall?.copyWith(color: AppColors.outline),
            ),
            const SizedBox(height: 20),

            // Title
            Text('Judul Impian *', style: textTheme.labelMedium),
            const SizedBox(height: 6),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Contoh: Road trip ke Jogja naik kereta...',
              ),
            ),
            const SizedBox(height: 16),

            // Category Chips
            Text('Kategori', style: textTheme.labelMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _categories.map((c) {
                final isSelected = _selectedCategory == c['id'];
                return ChoiceChip(
                  label: Text(c['label']!),
                  selected: isSelected,
                  selectedColor: AppColors.primaryContainer,
                  backgroundColor: AppColors.surfaceContainer,
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.primary : AppColors.onSurface,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                  ),
                  onSelected: (val) {
                    if (val) setState(() => _selectedCategory = c['id']!);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Target Date
            Text('Target Tanggal (Opsional)', style: textTheme.labelMedium),
            const SizedBox(height: 6),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _targetDate ?? DateTime.now().add(const Duration(days: 7)),
                  firstDate: DateTime(2025),
                  lastDate: DateTime(2035),
                );
                if (picked != null) {
                  setState(() => _targetDate = picked);
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
                    const Icon(Icons.event_rounded, color: AppColors.primary, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      _targetDate != null
                          ? DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(_targetDate!)
                          : 'Pilih perkiraan waktu kencan...',
                      style: TextStyle(
                        color: _targetDate != null ? AppColors.onSurface : AppColors.outline,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Notes
            Text('Catatan Tambahan', style: textTheme.labelMedium),
            const SizedBox(height: 6),
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Perlengkapan yang dibawa, wishlist tempat makan...',
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
                    Icon(Icons.favorite_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text('Simpan Rencana Berdua', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
