import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../services/storage_service.dart';
import 'widgets/add_moment_dialog.dart';
import 'widgets/add_date_dialog.dart';

class TimelineScreen extends StatefulWidget {
  final StorageService storageService;

  const TimelineScreen({super.key, required this.storageService});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  String _activeTab = 'timeline'; // 'timeline' | 'dates'

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
          'Linimasa & Tanggal',
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Segmented Switcher
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
                    child: _buildSegmentButton(
                      label: 'Linimasa Kenangan',
                      icon: Icons.auto_awesome_motion_rounded,
                      isActive: _activeTab == 'timeline',
                      onTap: () => setState(() => _activeTab = 'timeline'),
                    ),
                  ),
                  Expanded(
                    child: _buildSegmentButton(
                      label: 'Tanggal Penting',
                      icon: Icons.event_repeat_rounded,
                      isActive: _activeTab == 'dates',
                      onTap: () => setState(() => _activeTab = 'dates'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: _activeTab == 'timeline'
                ? _buildTimelineList(context)
                : _buildDatesList(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_activeTab == 'timeline') {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => AddMomentDialog(storageService: widget.storageService),
            );
          } else {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => AddDateDialog(storageService: widget.storageService),
            );
          }
        },
        backgroundColor: AppColors.primary,
        icon: Icon(
          _activeTab == 'timeline' ? Icons.add_a_photo_rounded : Icons.add_rounded,
          color: Colors.white,
        ),
        label: Text(
          _activeTab == 'timeline' ? 'Abadikan Momen' : 'Tambah Tanggal',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSegmentButton({
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

  Widget _buildTimelineList(BuildContext context) {
    final moments = widget.storageService.moments;

    if (moments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome_rounded, size: 48, color: AppColors.outlineVariant),
            const SizedBox(height: 12),
            const Text(
              'Belum ada kenangan yang dicatat.',
              style: TextStyle(color: AppColors.outline),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => AddMomentDialog(storageService: widget.storageService),
                );
              },
              child: const Text('Tulis Kenangan Pertama'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 80),
      itemCount: moments.length,
      itemBuilder: (context, index) {
        final moment = moments[index];
        final isLast = index == moments.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vertical Timeline indicator
              Column(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: moment.isBucketListCompleted
                          ? AppColors.primary
                          : AppColors.primaryContainer,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        moment.isBucketListCompleted
                            ? Icons.celebration_rounded
                            : Icons.favorite_rounded,
                        color: moment.isBucketListCompleted ? Colors.white : AppColors.primary,
                        size: 14,
                      ),
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: AppColors.surfaceContainerHighest,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),

              // Content Card
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(16),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Date & Tag
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('d MMMM yyyy', 'id_ID').format(moment.date),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: moment.isBucketListCompleted
                                  ? AppColors.successContainer
                                  : AppColors.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              moment.isBucketListCompleted
                                  ? 'Bucket List ✨'
                                  : 'Momen Spesial ❤️',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: moment.isBucketListCompleted
                                    ? AppColors.success
                                    : AppColors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Title
                      Text(
                        moment.title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),

                      if (moment.location.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.place_rounded, size: 13, color: AppColors.outline),
                            const SizedBox(width: 4),
                            Text(
                              moment.location,
                              style: const TextStyle(fontSize: 12, color: AppColors.outline),
                            ),
                          ],
                        ),
                      ],

                      if (moment.story.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          moment.story,
                          style: const TextStyle(fontSize: 13, height: 1.5, color: AppColors.onSurface),
                        ),
                      ],
                      const SizedBox(height: 10),

                      // Footer with author and delete
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Oleh: ${moment.createdBy}',
                            style: const TextStyle(fontSize: 11, color: AppColors.outline),
                          ),
                          GestureDetector(
                            onTap: () {
                              widget.storageService.deleteMoment(moment.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Momen dihapus dari linimasa.'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                            child: const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.outlineVariant),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDatesList(BuildContext context) {
    final dates = widget.storageService.importantDates;

    if (dates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_month_rounded, size: 48, color: AppColors.outlineVariant),
            const SizedBox(height: 12),
            const Text(
              'Belum ada tanggal penting.',
              style: TextStyle(color: AppColors.outline),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => AddDateDialog(storageService: widget.storageService),
                );
              },
              child: const Text('Tambah Tanggal Baru'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      itemCount: dates.length,
      itemBuilder: (context, index) {
        final d = dates[index];
        final days = d.daysRemaining();
        final isToday = days == 0;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
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
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(d.iconEmoji, style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d.title,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          DateFormat('d MMMM yyyy', 'id_ID').format(d.date),
                          style: const TextStyle(fontSize: 12, color: AppColors.outline),
                        ),
                        if (d.repeatsYearly) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('🔁 Tahunan', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isToday ? AppColors.primary : AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isToday ? 'Hari Ini! 🎉' : '$days Hari',
                      style: TextStyle(
                        color: isToday ? Colors.white : AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () {
                      widget.storageService.deleteImportantDate(d.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tanggal penting dihapus.'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    child: const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.outlineVariant),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
