import 'package:flutter/material.dart';
import 'package:lexiadapt/core/theme/app_colors.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  const SectionHeader({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark)),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(subtitle!,
              style: TextStyle(fontSize: 13, color: Colors.grey[600])),
        ],
      ],
    );
  }
}
