/// lib/views/widgets/bottom_nav_bar.dart
/// Bottom Navigation Bar — 4 ปุ่มวงกลม ตาม Mockup 3_Main.jpg
/// ตำแหน่ง: AI จสวีส | Calendar | จัดการงาน | ตั้งค่า
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

  static const List<_NavItem> _items = <_NavItem>[
    _NavItem(icon: Icons.smart_toy_outlined, label: 'AI จสวีส'),
    _NavItem(icon: Icons.calendar_month_outlined, label: 'Calendar'),
    _NavItem(icon: Icons.task_outlined, label: 'จัดการงาน'),
    _NavItem(icon: Icons.settings_outlined, label: 'ตั้งค่า'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        // ขอบบนโค้งตามสไตล์ Mockup
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppTheme.radiusLarge),
          topRight: Radius.circular(AppTheme.radiusLarge),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 12,
            offset: Offset(0, -3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List<Widget>.generate(_items.length, (int index) {
          final bool isSelected = index == currentIndex;
          return GestureDetector(
            onTap: () => onTap(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.cardLight
                    : AppTheme.cardLight.withOpacity(0.6),
                shape: BoxShape.circle,
                boxShadow: isSelected
                    ? <BoxShadow>[
                        BoxShadow(
                          color: AppTheme.accentPrimary.withOpacity(0.25),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    _items[index].icon,
                    color: isSelected ? AppTheme.accentPrimary : AppTheme.textPrimary,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _items[index].label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? AppTheme.accentPrimary : AppTheme.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
