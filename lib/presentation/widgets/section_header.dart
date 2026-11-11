import 'package:flutter/material.dart';

import '../../core/theme.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.onShowAll});

  final String title;
  final VoidCallback? onShowAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.dark)),
          GestureDetector(
            onTap: onShowAll,
            child: const Text('Show all',
                style: TextStyle(fontSize: 11, color: AppColors.grey)),
          ),
        ],
      ),
    );
  }
}
