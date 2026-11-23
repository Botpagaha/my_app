import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../models/bucket_item.dart';
import '../../services/storage_service.dart';

class BucketDetailScreen extends StatefulWidget {
  final BucketItem item;
  final StorageService storageService;

  const BucketDetailScreen({
    super.key,
    required this.item,
    required this.storageService,
  });

  @override
  State<BucketDetailScreen> createState() => _BucketDetailScreenState();
}

class _BucketDetailScreenState extends State<BucketDetailScreen> {
  late bool _isFavorite;
  late TextEditingController _memoryNoteController;
  bool _isEditingNote = false;

  final List<String> _samplePhotos = [
    '🌅 Sunset Keemasan',
    '🧺 Roti Bakar Keju',
    '📸 Senyum Bahagia',
  ];

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.item.isFavorite;
    _memoryNoteController = TextEditingController(
      text: widget.item.memoryNote.isNotEmpty
          ? widget.item.memoryNote
          : 'Belum ada catatan kenangan. Tulis cerita manis setelah impian ini terlaksana berdua ❤️',
    );
  }

  @override
  void dispose() {
    _memoryNoteController.dispose();
    super.dispose();
  }

  void _toggleFavorite() {
    setState(() => _isFavorite = !_isFavorite);
    widget.item.isFavorite = _isFavorite;
    widget.storageService.updateBucketItem(widget.item);
  }

  void _saveMemoryNote() {
    setState(() => _isEditingNote = false);
    widget.item.memoryNote = _memoryNoteController.text;
    widget.storageService.updateBucketItem(widget.item);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Catatan kenangan berhasil diperbarui! 📝'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _simulateAddPhoto() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.add_photo_alternate_rounded, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Tambah Foto Kenangan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Foto dari galeri akan secara otomatis dikompresi di HP sebelum disimpan sesuai standar PRD (menghemat kuota Supabase free tier).',
              style: TextStyle(height: 1.4, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Kompresi otomatis aktif:\n2.4 MB ➔ 240 KB (Optimized)',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: AppColors.outline)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _samplePhotos.add('📷 Foto Baru #${_samplePhotos.length + 1}');
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Foto kenangan berhasil ditambahkan! 📸'),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            child: const Text('Simulasi Unggah'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final item = widget.item;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Detail Kenangan',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: _isFavorite ? AppColors.primary : AppColors.outline,
            ),
            onPressed: _toggleFavorite,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
            onPressed: () {
              widget.storageService.deleteBucketItem(item.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Impian telah dihapus dari daftar.'),
                  backgroundColor: AppColors.onSurface,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Tag
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: item.isCompleted ? AppColors.successContainer : AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        item.isCompleted ? Icons.check_circle_rounded : Icons.hourglass_top_rounded,
                        color: item.isCompleted ? AppColors.success : AppColors.primary,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item.isCompleted ? 'Terlaksana Bersama ✨' : 'Rencana Mendatang ⏳',
                        style: TextStyle(
                          color: item.isCompleted ? AppColors.success : AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item.categoryLabel,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Item Title
            Text(
              item.title,
              style: textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 10),

            // Target or Execution Date
            Row(
              children: [
                const Icon(Icons.event_note_rounded, size: 16, color: AppColors.outline),
                const SizedBox(width: 6),
                Text(
                  item.isCompleted && item.completedAt != null
                      ? 'Terlaksana pada: ${DateFormat('d MMMM yyyy', 'id_ID').format(item.completedAt!)}'
                      : item.targetDate != null
                          ? 'Target waktu: ${DateFormat('d MMMM yyyy', 'id_ID').format(item.targetDate!)}'
                          : 'Belum ditentukan target tanggal',
                  style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Notes Card
            if (item.notes.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.surfaceContainerHigh),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rencana & Perlengkapan',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.outline),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.notes,
                      style: const TextStyle(fontSize: 14, height: 1.5, color: AppColors.onSurface),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Photo Gallery Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Galeri Kenangan',
                  style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: _simulateAddPhoto,
                  icon: const Icon(Icons.add_a_photo_outlined, size: 16, color: AppColors.primary),
                  label: const Text('Tambah Foto', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Photo cards
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _samplePhotos.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, idx) {
                  return Container(
                    width: 110,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryContainer,
                          AppColors.secondaryContainer.withValues(alpha: 0.5),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.surfaceContainerHigh),
                    ),
                    child: Center(
                      child: Text(
                        _samplePhotos[idx],
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurface),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 26),

            // Catatan Kenangan Kita
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Catatan Kenangan Kita',
                  style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(
                    _isEditingNote ? Icons.check_circle_rounded : Icons.edit_note_rounded,
                    color: AppColors.primary,
                    size: 26,
                  ),
                  onPressed: () {
                    if (_isEditingNote) {
                      _saveMemoryNote();
                    } else {
                      setState(() => _isEditingNote = true);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 6),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: _isEditingNote ? AppColors.primary : AppColors.surfaceContainerHigh,
                  width: _isEditingNote ? 1.5 : 1.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isEditingNote)
                    TextField(
                      controller: _memoryNoteController,
                      maxLines: 4,
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Tulis kesan, tawa, atau kenangan saat menjalani impian ini...',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    )
                  else
                    Text(
                      _memoryNoteController.text,
                      style: const TextStyle(fontSize: 14, height: 1.6, color: AppColors.onSurface),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.favorite_rounded, size: 14, color: AppColors.secondary),
                      const SizedBox(width: 4),
                      Text(
                        'Dibuat oleh ${item.createdBy}',
                        style: const TextStyle(fontSize: 11, color: AppColors.outline),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  widget.storageService.toggleBucketItemStatus(item.id);
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        item.isCompleted
                            ? 'Impian ditandai terlaksana! Momen tersimpan ke Linimasa ✨'
                            : 'Status dikembalikan ke rencana mendatang ⏳',
                      ),
                      backgroundColor: AppColors.primary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: item.isCompleted ? AppColors.surfaceContainer : AppColors.primary,
                  foregroundColor: item.isCompleted ? AppColors.primary : Colors.white,
                ),
                icon: Icon(
                  item.isCompleted ? Icons.undo_rounded : Icons.check_circle_rounded,
                  size: 20,
                ),
                label: Text(
                  item.isCompleted ? 'Batal Terlaksana' : 'Tandai Terlaksana ✨',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton.filledTonal(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Kenangan dibagikan ke pasangan! 💌'),
                    backgroundColor: AppColors.secondary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              },
              icon: const Icon(Icons.send_rounded, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
