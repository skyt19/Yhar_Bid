/// lib/views/widgets/bottom_nav_bar.dart
/// Bottom Navigation Bar — 4 Circular Icon Buttons (Mockup-Compliant 100%)
/// สีพื้น: #757575 | วงกลมปุ่ม: สีขาว | ไอคอน: สีดำ | Google G: สีรุ้ง
import 'package:flutter/material.dart';

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
      decoration: const BoxDecoration(
        color: Color(0xFF757575), // สีเทาเข้มตาม Mockup
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
          color: Colors.white, // วงกลมสีขาวตาม Mockup
          shape: BoxShape.circle,
          border: isActive
              ? Border.all(color: const Color(0xFF4CAF50), width: 3)
              : null,
        ),
        child: icon is Widget
            ? icon
            : Icon(
                icon as IconData,
                color: Colors.black, // ไอคอนสีดำตาม Mockup
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

