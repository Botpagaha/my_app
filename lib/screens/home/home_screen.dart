import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../services/storage_service.dart';
import '../../models/bucket_item.dart';
import '../bucket_list/widgets/add_bucket_item_dialog.dart';
import '../timeline/widgets/add_moment_dialog.dart';
import '../bucket_list/bucket_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final StorageService storageService;
  final Function(int) onNavigateTab;

  const HomeScreen({
    super.key,
    required this.storageService,
    required this.onNavigateTab,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final List<_HeartParticle> _particles = [];
  final Random _random = Random();

  void _triggerHeartAnimation(Offset tapPosition) {
    for (int i = 0; i < 6; i++) {
      setState(() {
        _particles.add(
          _HeartParticle(
            key: UniqueKey(),
            position: tapPosition,
            dx: (_random.nextDouble() - 0.5) * 80,
            dy: -60 - _random.nextDouble() * 60,
            size: 18 + _random.nextDouble() * 16,
            color: [
              AppColors.primary,
              AppColors.secondary,
              Colors.redAccent,
              const Color(0xFFFF8B9F)
            ][_random.nextInt(4)],
          ),
        );
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.favorite_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Pelukan hangat & cinta terkirim! 💖'),
          ],
        ),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _removeParticle(Key key) {
    setState(() {
      _particles.removeWhere((p) => p.key == key);
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final anniversary = widget.storageService.anniversaryDate;
    final now = DateTime.now();

    // Days together calculation
    final totalDays = now.difference(anniversary).inDays;

    // Year, Month, Day calculation
    int years = now.year - anniversary.year;
    int months = now.month - anniversary.month;
    int days = now.day - anniversary.day;

    if (days < 0) {
      months -= 1;
      final prevMonth = DateTime(now.year, now.month - 1, anniversary.day);
      days = now.difference(prevMonth).inDays;
    }
    if (months < 0) {
      years -= 1;
      months += 12;
    }

    final formattedAnniv = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(anniversary);

    final uncompletedItems = widget.storageService.bucketItems.where((i) => !i.isCompleted).toList();
    final nearestDates = widget.storageService.importantDates.take(3).toList();

    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            scrolledUnderElevation: 0,
            titleSpacing: 16,
            title: Row(
              children: [
                // Couple Avatars
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 17,
                      backgroundColor: AppColors.primary,
                      child: const Text('M', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                    ),
                    Positioned(
                      left: 20,
                      child: CircleAvatar(
                        radius: 17,
                        backgroundColor: AppColors.secondary,
                        child: const Text('C', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 32),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hai, Miftah & Cinta ❤️',
                      style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Ruang Privat Berdua',
                      style: textTheme.bodySmall?.copyWith(fontSize: 11, color: AppColors.outline),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.cloud_done_rounded, color: AppColors.success, size: 14),
                    SizedBox(width: 4),
                    Text('Sinkron', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Countdown Card
                _buildHeroCountdownCard(
                  context: context,
                  totalDays: totalDays,
                  years: years,
                  months: months,
                  days: days,
                  formattedAnniv: formattedAnniv,
                ),
                const SizedBox(height: 20),

                // Quick Action Buttons
                _buildQuickActions(context),
                const SizedBox(height: 28),

                // Upcoming Important Milestones
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Target Indah Terdekat',
                      style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () => widget.onNavigateTab(2), // Go to Kenangan / Tanggal
                      child: const Text('Lihat Semua', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                if (nearestDates.isNotEmpty)
                  ...nearestDates.map((d) => _buildImportantDateCard(context, d))
                else
                  _buildEmptyMilestoneCard(context),

                const SizedBox(height: 24),

                // Selected Bucket List Items
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Bucket List Pilihan',
                      style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () => widget.onNavigateTab(1), // Go to Bucket List
                      child: const Text('Buka Semua', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                if (uncompletedItems.isNotEmpty)
                  ...uncompletedItems.take(3).map((item) => _buildBucketItemSnippet(context, item))
                else
                  _buildEmptyBucketCard(context),
              ],
            ),
          ),
        ),

        // Floating Heart Particles Layer
        IgnorePointer(
          child: Stack(
            children: _particles.map((p) {
              return _AnimatedParticleWidget(
                key: p.key,
                particle: p,
                onComplete: () => _removeParticle(p.key),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCountdownCard({
    required BuildContext context,
    required int totalDays,
    required int years,
    required int months,
    required int days,
    required String formattedAnniv,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.28),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background decorative subtle circles
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            left: -10,
            bottom: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'Kisah Cinta Kita',
                            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),

                    // Heart tap reaction button
                    Builder(
                      builder: (btnCtx) => GestureDetector(
                        onTapDown: (details) {
                          final box = btnCtx.findRenderObject() as RenderBox?;
                          final pos = box != null ? box.localToGlobal(Offset.zero) : Offset.zero;
                          _triggerHeartAnimation(Offset(pos.dx + 20, pos.dy + 20));
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.22),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.favorite_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Days Count
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$totalDays',
                      style: textTheme.displayLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 54,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Hari Bersama',
                      style: textTheme.headlineSmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.95),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Breakdown Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$years Tahun • $months Bulan • $days Hari',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Anniversary subtitle
                Row(
                  children: [
                    const Icon(Icons.favorite_border_rounded, color: Colors.white70, size: 14),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Sejak $formattedAnniv',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          _buildActionButton(
            label: '+ Ide Bucket List',
            icon: Icons.add_circle_outline_rounded,
            isPrimary: true,
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => AddBucketItemDialog(storageService: widget.storageService),
              );
            },
          ),
          const SizedBox(width: 10),
          _buildActionButton(
            label: '+ Momen Baru',
            icon: Icons.auto_awesome_rounded,
            isPrimary: false,
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => AddMomentDialog(storageService: widget.storageService),
              );
            },
          ),
          const SizedBox(width: 10),
          _buildActionButton(
            label: 'Atur Tanggal',
            icon: Icons.calendar_month_rounded,
            isPrimary: false,
            onTap: () => widget.onNavigateTab(3), // Navigate to Settings
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
          border: isPrimary ? null : Border.all(color: AppColors.surfaceContainerHigh),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isPrimary ? Colors.white : AppColors.primary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isPrimary ? Colors.white : AppColors.onSurface,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImportantDateCard(BuildContext context, dynamic dateItem) {
    final days = dateItem.daysRemaining();
    final isToday = days == 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceContainerHigh),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                dateItem.iconEmoji,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateItem.title,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('d MMMM yyyy', 'id_ID').format(dateItem.date),
                  style: const TextStyle(fontSize: 12, color: AppColors.outline),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isToday ? AppColors.primary : AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isToday ? 'Hari Ini! 🎉' : '$days Hari Lagi',
              style: TextStyle(
                color: isToday ? Colors.white : AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMilestoneCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceContainerHigh),
      ),
      child: const Center(
        child: Text(
          'Belum ada tanggal penting terdekat. Tambahkan di menu Kenangan!',
          style: TextStyle(color: AppColors.outline, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildBucketItemSnippet(BuildContext context, BucketItem item) {
    return InkWell(
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
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.surfaceContainerHigh),
        ),
        child: Row(
          children: [
            // Check button
            GestureDetector(
              onTap: () => widget.storageService.toggleBucketItemStatus(item.id),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: const Icon(Icons.check, size: 18, color: AppColors.outline),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.categoryLabel,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                        ),
                      ),
                      if (item.targetDate != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('d MMM yyyy', 'id_ID').format(item.targetDate!),
                          style: const TextStyle(fontSize: 11, color: AppColors.outline),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.outline, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyBucketCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceContainerHigh),
      ),
      child: const Center(
        child: Text(
          'Semua impian telah terlaksana! Tambahkan rencana baru yuk ✨',
          style: TextStyle(color: AppColors.outline, fontSize: 13),
        ),
      ),
    );
  }
}

class _HeartParticle {
  final Key key;
  final Offset position;
  final double dx;
  final double dy;
  final double size;
  final Color color;

  _HeartParticle({
    required this.key,
    required this.position,
    required this.dx,
    required this.dy,
    required this.size,
    required this.color,
  });
}

class _AnimatedParticleWidget extends StatefulWidget {
  final _HeartParticle particle;
  final VoidCallback onComplete;

  const _AnimatedParticleWidget({
    super.key,
    required this.particle,
    required this.onComplete,
  });

  @override
  State<_AnimatedParticleWidget> createState() => _AnimatedParticleWidgetState();
}

class _AnimatedParticleWidgetState extends State<_AnimatedParticleWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.6, 1.0)),
    );

    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = _controller.value;
        final x = widget.particle.position.dx + widget.particle.dx * progress;
        final y = widget.particle.position.dy + widget.particle.dy * progress;

        return Positioned(
          left: x,
          top: y,
          child: Opacity(
            opacity: _fade.value,
            child: Icon(
              Icons.favorite_rounded,
              size: widget.particle.size,
              color: widget.particle.color,
            ),
          ),
        );
      },
    );
  }
}
