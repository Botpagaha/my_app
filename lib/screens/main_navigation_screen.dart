import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/storage_service.dart';
import 'home/home_screen.dart';
import 'bucket_list/bucket_list_screen.dart';
import 'timeline/timeline_screen.dart';
import 'settings/settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final StorageService storageService;
  final VoidCallback onLogout;

  const MainNavigationScreen({
    super.key,
    required this.storageService,
    required this.onLogout,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        storageService: widget.storageService,
        onNavigateTab: _onTabTapped,
      ),
      BucketListScreen(
        storageService: widget.storageService,
      ),
      TimelineScreen(
        storageService: widget.storageService,
      ),
      SettingsScreen(
        storageService: widget.storageService,
        onLogout: widget.onLogout,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  label: 'Beranda',
                  icon: Icons.favorite_border_rounded,
                  activeIcon: Icons.favorite_rounded,
                ),
                _buildNavItem(
                  index: 1,
                  label: 'Bucket List',
                  icon: Icons.checklist_rtl_rounded,
                  activeIcon: Icons.checklist_rtl_rounded,
                ),
                _buildNavItem(
                  index: 2,
                  label: 'Kenangan',
                  icon: Icons.auto_awesome_motion_rounded,
                  activeIcon: Icons.auto_awesome_motion_rounded,
                ),
                _buildNavItem(
                  index: 3,
                  label: 'Pengaturan',
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings_rounded,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String label,
    required IconData icon,
    required IconData activeIcon,
  }) {
    final isActive = _currentIndex == index;

    return InkWell(
      onTap: () => _onTabTapped(index),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryContainer.withValues(alpha: 0.7) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              size: 22,
              color: isActive ? AppColors.primary : AppColors.outline,
            ),
            if (isActive) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
