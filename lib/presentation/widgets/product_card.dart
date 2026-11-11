import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../data/models/product.dart';
import 'favorite_button.dart';
import 'network_image_box.dart';

/// Card vertical: Feature Products si Similar Product.
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.width = 120,
  });

  final Product product;
  final VoidCallback onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 3 / 4,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: NetworkImageBox(product.imageUrl),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: FavoriteButton(productId: product.id),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: AppColors.dark)),
            const SizedBox(height: 2),
            Text(product.priceLabel,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.dark)),
          ],
        ),
      ),
    );
  }
}

/// Card orizontal compact: sectiunea Recommended.
class ProductTile extends StatelessWidget {
  const ProductTile({super.key, required this.product, required this.onTap});

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 200,
        height: 72,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(10)),
              child: SizedBox(width: 72, child: NetworkImageBox(product.imageUrl)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: AppColors.dark)),
                  const SizedBox(height: 4),
                  Text(product.priceLabel,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.dark)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: FavoriteButton(productId: product.id, size: 24),
            ),
          ],
        ),
      ),
    );
  }
}
