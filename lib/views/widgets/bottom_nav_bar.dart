/// lib/views/widgets/bottom_nav_bar.dart
/// Bottom Navigation Bar — 5 Circular Icon Buttons (Mockup-Compliant + Tasks Page)
/// สีพื้น: #757575 | วงกลมปุ่ม: สีขาว | ไอคอน: สีดำ | Google G: สีรุ้ง
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: AppTheme.navBarBackground,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavButton(context, 0, Icons.home_rounded,     'Home'),
            _buildNavButton(context, 1, null,                   'Calendar',
                customIcon: const _GoogleIcon()),
            _buildNavButton(context, 2, Icons.psychology_rounded, 'AI'),
            _buildNavButton(context, 3, Icons.task_alt_rounded,  'Tasks'),
            _buildNavButton(context, 4, Icons.settings_rounded,  'Settings'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton(
    BuildContext context,
    int index,
    IconData? icon,
    String label, {
    Widget? customIcon,
  }) {
    final bool isActive = currentIndex == index;
    return Semantics(
      label: label,
      button: true,
      selected: isActive,
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 64,
          height: 64,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.textOnDark,
              shape: BoxShape.circle,
              border: isActive
                  ? Border.all(color: AppTheme.accentGreen, width: 2.5)
                  : null,
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppTheme.accentGreen.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ]
                  : null,
            ),
            child: Center(
              child: customIcon ??
                  Icon(
                    icon,
                    color: isActive ? AppTheme.accentGreen : AppTheme.textPrimary,
                    size: 26,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

// Google Calendar icon — rainbow gradient per mockup
class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Color(0xFF4285F4), // Blue
            Color(0xFFEA4335), // Red
            Color(0xFFFBBC05), // Yellow
            Color(0xFF34A853), // Green
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Text(
          'G',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textOnDark,
          ),
        ),
      ),
    );
  }
}
