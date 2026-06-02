import 'package:flutter/material.dart';

class CustomBottomBarAdmin extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomBarAdmin({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      {
        'label': 'DASHBOARD',
        'activeIcon': Icons.dashboard_rounded,
        'inactiveIcon': Icons.dashboard_outlined,
      },
      {
        'label': 'USERS',
        'activeIcon': Icons.group_rounded,
        'inactiveIcon': Icons.group_outlined,
      },
      {
        'label': 'VERIFICATION',
        'activeIcon': Icons.fact_check_rounded,
        'inactiveIcon': Icons.fact_check_outlined,
      },
      {
        'label': 'COMMUNITIES',
        'activeIcon': Icons.security_rounded,
        'inactiveIcon': Icons.security_outlined,
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        border: Border.all(width: 1, color: const Color(0xFFE8F5E9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = currentIndex == index;
              final color = isSelected ? const Color(0xFF00450D) : const Color(0xFF94A3B8);

              return GestureDetector(
                onTap: () => onTap(index),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFE8F5E9) : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected ? (item['activeIcon'] as IconData) : (item['inactiveIcon'] as IconData),
                        color: color,
                        size: 24,
                      ),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isSelected) const SizedBox(width: 6),
                            if (isSelected)
                              Text(
                                item['label'] as String,
                                style: TextStyle(
                                  color: color,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}