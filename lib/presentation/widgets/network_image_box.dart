import 'package:flutter/material.dart';

import '../../core/theme.dart';

class NetworkImageBox extends StatelessWidget {
  const NetworkImageBox(this.url, {super.key, this.fit = BoxFit.cover});

  final String url;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : Container(color: AppColors.surface),
      errorBuilder: (context, error, stack) => Container(
        color: AppColors.surface,
        alignment: Alignment.center,
        child: const Icon(Icons.image_not_supported_outlined,
            color: AppColors.grey),
      ),
    );
  }
}
