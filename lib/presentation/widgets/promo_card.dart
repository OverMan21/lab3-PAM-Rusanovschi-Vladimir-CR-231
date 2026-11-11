import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../data/models/home_data.dart';
import 'network_image_box.dart';

/// Card cu text + imagine (New Collection, Top Collection, promo categorii).
class PromoCard extends StatelessWidget {
  const PromoCard({
    super.key,
    required this.promo,
    this.height = 120,
    this.imageOnRight = true,
    this.titleSize = 15,
  });

  final Promo promo;
  final double height;
  final bool imageOnRight;
  final double titleSize;

  @override
  Widget build(BuildContext context) {
    final text = Expanded(
      flex: 5,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (promo.label.isNotEmpty)
              Text(promo.label,
                  style: const TextStyle(fontSize: 9, color: AppColors.grey)),
            const SizedBox(height: 6),
            Text(promo.title,
                style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                    color: AppColors.dark)),
          ],
        ),
      ),
    );
    final image = Expanded(flex: 4, child: NetworkImageBox(promo.imageUrl));

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: height,
        color: AppColors.surface,
        child: Row(children: imageOnRight ? [text, image] : [image, text]),
      ),
    );
  }
}
