import 'package:flutter/material.dart';
import 'package:lexiadapt/core/theme/app_colors.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xD9FFFFFF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.auto_stories,
              color: AppColors.deepBlue, size: 26),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xD9FFFFFF),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.language, size: 18, color: Colors.grey[700]),
              const SizedBox(width: 4),
              Text('EN',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Colors.grey[700])),
              Icon(Icons.arrow_drop_down, size: 20, color: Colors.grey[700]),
            ],
          ),
        ),
      ],
    );
  }
}
