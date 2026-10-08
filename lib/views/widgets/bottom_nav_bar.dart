/// lib/views/widgets/bottom_nav_bar.dart
/// Bottom Navigation Bar — 4 ปุ่มวงกลม
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
    final List<_NavItem> items = <_NavItem>[
      _NavItem(icon: Icons.psychology_outlined, labelKey: 'ai_assistant'),
      _NavItem(icon: Icons.calendar_month_outlined, labelKey: 'calendar'),
      _NavItem(icon: Icons.assignment_outlined, labelKey: 'tasks_manage'),
      _NavItem(icon: Icons.settings_outlined, labelKey: 'settings'),
    ];

    return Container(
      decoration: const BoxDecoration(
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
        children: List<Widget>.generate(items.length, (int index) {
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
                    : AppTheme.cardLight.withValues(alpha: 0.6),
                shape: BoxShape.circle,
                boxShadow: isSelected
                    ? <BoxShadow>[
                        BoxShadow(
                          color: AppTheme.accentPrimary.withValues(alpha: 0.25),
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
                    items[index].icon,
                    color: isSelected ? AppTheme.accentPrimary : AppTheme.textPrimary,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    items[index].labelKey.tr,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? AppTheme.accentPrimary : AppTheme.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
  final String labelKey;
  const _NavItem({required this.icon, required this.labelKey});
}

