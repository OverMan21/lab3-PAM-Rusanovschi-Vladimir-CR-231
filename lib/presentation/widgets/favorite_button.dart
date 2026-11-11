import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme.dart';
import '../../logic/favorites/favorites_cubit.dart';

/// Inima de favorite, refolosita pe carduri si pe pagina de detalii.
class FavoriteButton extends StatelessWidget {
  const FavoriteButton({super.key, required this.productId, this.size = 28});

  final String productId;
  final double size;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<FavoritesCubit, Set<String>, bool>(
      selector: (favorites) => favorites.contains(productId),
      builder: (context, isFavorite) {
        return GestureDetector(
          onTap: () => context.read<FavoritesCubit>().toggle(productId),
          child: Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              size: size * 0.55,
              color: isFavorite ? AppColors.red : AppColors.grey,
            ),
          ),
        );
      },
    );
  }
}
