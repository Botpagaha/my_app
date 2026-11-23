import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../services/storage_service.dart';
import '../../models/bucket_item.dart';
import 'widgets/add_bucket_item_dialog.dart';
import 'bucket_detail_screen.dart';

class BucketListScreen extends StatefulWidget {
  final StorageService storageService;

  const BucketListScreen({super.key, required this.storageService});

  @override
  State<BucketListScreen> createState() => _BucketListScreenState();
}

class _BucketListScreenState extends State<BucketListScreen> {
  String _currentStatus = 'uncompleted'; // 'uncompleted' | 'completed'
  String _currentCategory = 'all';
  String _searchTerm = '';
  final _searchController = TextEditingController();

  final List<Map<String, String>> _categories = [
    {'id': 'all', 'label': 'Semua'},
    {'id': 'tempat', 'label': 'Tempat 📍'},
    {'id': 'makanan', 'label': 'Makanan ☕'},
    {'id': 'film', 'label': 'Film 🎬'},
    {'id': 'lainnya', 'label': 'Lainnya ✨'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final allItems = widget.storageService.bucketItems;
    final uncompletedCount = allItems.where((i) => !i.isCompleted).length;
    final completedCount = allItems.where((i) => i.isCompleted).length;

    final filteredItems = allItems.where((item) {
      final matchesStatus = _currentStatus == 'completed' ? item.isCompleted : !item.isCompleted;
      final matchesCategory = _currentCategory == 'all' || item.category.toLowerCase() == _currentCategory;
      final matchesSearch = _searchTerm.isEmpty ||
          item.title.toLowerCase().contains(_searchTerm.toLowerCase()) ||
          item.notes.toLowerCase().contains(_searchTerm.toLowerCase());
      return matchesStatus && matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Bucket List Berdua',
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary, size: 26),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => AddBucketItemDialog(storageService: widget.storageService),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchTerm = val),
              decoration: InputDecoration(
                hintText: 'Cari impian atau kencan...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.outline),
                suffixIcon: _searchTerm.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.outline),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchTerm = '');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),

          // Status Tabs (Belum Tercapai vs Sudah Terlaksana)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatusTab(
                      label: 'Belum Tercapai ($uncompletedCount)',
                      icon: Icons.favorite_border_rounded,
                      isActive: _currentStatus == 'uncompleted',
                      onTap: () => setState(() => _currentStatus = 'uncompleted'),
                    ),
                  ),
                  Expanded(
                    child: _buildStatusTab(
                      label: 'Sudah Terlaksana ($completedCount)',
                      icon: Icons.celebration_rounded,
                      isActive: _currentStatus == 'completed',
                      onTap: () => setState(() => _currentStatus = 'completed'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Category Chips Horizontal
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _currentCategory == cat['id'];
                return ChoiceChip(
                  label: Text(cat['label']!),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.onSurface,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : AppColors.outlineVariant,
                  ),
                  onSelected: (val) {
                    if (val) setState(() => _currentCategory = cat['id']!);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 10),

          // Bucket Items List
          Expanded(
            child: filteredItems.isEmpty
                ? _buildEmptyState(context)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 80),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return _buildItemCard(context, item);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => AddBucketItemDialog(storageService: widget.storageService),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Rencana Baru', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildStatusTab({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? AppColors.primary : AppColors.outline,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                color: isActive ? AppColors.primary : AppColors.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, BucketItem item) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
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
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BucketDetailScreen(
                item: item,
                storageService: widget.storageService,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Heart Toggle Checkbox
              GestureDetector(
                onTap: () => widget.storageService.toggleBucketItemStatus(item.id),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: item.isCompleted ? AppColors.primary : AppColors.surfaceContainer,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: item.isCompleted ? AppColors.primary : AppColors.outlineVariant,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      item.isCompleted ? Icons.check_rounded : Icons.favorite_border_rounded,
                      size: 18,
                      color: item.isCompleted ? Colors.white : AppColors.outline,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Title, Category & Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                        color: item.isCompleted ? AppColors.outline : AppColors.onSurface,
                      ),
                    ),
                    if (item.notes.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.notes,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.categoryLabel,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                        if (item.isCompleted && item.completedAt != null) ...[
                          const SizedBox(width: 8),
                          Row(
                            children: [
                              const Icon(Icons.check_circle_outline, size: 13, color: AppColors.success),
                              const SizedBox(width: 3),
                              Text(
                                DateFormat('d MMM yyyy', 'id_ID').format(item.completedAt!),
                                style: const TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ] else if (item.targetDate != null) ...[
                          const SizedBox(width: 8),
                          Row(
                            children: [
                              const Icon(Icons.event_outlined, size: 13, color: AppColors.outline),
                              const SizedBox(width: 3),
                              Text(
                                DateFormat('d MMM yyyy', 'id_ID').format(item.targetDate!),
                                style: const TextStyle(fontSize: 11, color: AppColors.outline),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded, color: AppColors.outlineVariant),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.favorite_rounded, color: AppColors.primary, size: 40),
            ),
            const SizedBox(height: 16),
            Text(
              _currentStatus == 'completed'
                  ? 'Belum Ada Impian Terlaksana'
                  : 'Belum Ada Impian di Kategori Ini',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Ayo rencanakan momen indah berdua berikutnya!',
              style: TextStyle(color: AppColors.outline, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => AddBucketItemDialog(storageService: widget.storageService),
                );
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Tambah Impian Sekarang'),
            ),
          ],
        ),
      ),
    );
  }
}
