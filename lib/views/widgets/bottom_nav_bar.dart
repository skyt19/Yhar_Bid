/// lib/views/widgets/bottom_nav_bar.dart
/// Bottom Navigation Bar — 4 Circular Icon Buttons (Mockup-Compliant)
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
      height: 90,
      decoration: BoxDecoration(
        color: AppTheme.navBarBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavButton(0, Icons.home, 'Home'),
            _buildNavButton(1, _GoogleIcon(), 'Calendar'),
            _buildNavButton(2, Icons.memory, 'AI'),
            _buildNavButton(3, Icons.settings, 'Settings'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton(int index, dynamic icon, String label) {
    final isActive = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          shape: BoxShape.circle,
          border: Border.all(
            color: isActive ? AppTheme.accentPrimary : Colors.transparent,
            width: 3,
          ),
        ),
        child: icon is Widget
            ? icon
            : Icon(
                icon as IconData,
                color: isActive ? AppTheme.accentPrimary : AppTheme.textPrimary,
                size: 28,
              ),
      ),
    );
  }
}

// Custom Google "G" Icon Widget (Rainbow Colors)
class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
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
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

