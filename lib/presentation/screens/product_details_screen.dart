import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme.dart';
import '../../data/models/product.dart';
import '../../data/models/product_details.dart';
import '../../data/repositories/store_repository.dart';
import '../../logic/details/details_cubit.dart';
import '../widgets/favorite_button.dart';
import '../widgets/network_image_box.dart';
import '../widgets/product_card.dart';
import '../widgets/rating_stars.dart';
import '../widgets/state_views.dart';

/// Deschide pagina de detalii cu propriul DetailsCubit.
Future<void> openProductDetails(BuildContext context, Product product) {
  final repository = context.read<StoreRepository>();
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => BlocProvider(
        create: (_) => DetailsCubit(repository, product)..load(),
        child: const ProductDetailsScreen(),
      ),
    ),
  );
}

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DetailsCubit, DetailsState>(
      listenWhen: (prev, curr) =>
          prev is DetailsSuccess &&
          curr is DetailsSuccess &&
          curr.cartCount != prev.cartCount,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(
            content: Text('Produs adăugat în coș'),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(left: 16, right: 16, bottom: 90),
            duration: Duration(seconds: 2),
          ));
      },
      builder: (context, state) => switch (state) {
        DetailsLoading() => const _PlainScaffold(child: LoadingView()),
        DetailsError(:final message) => _PlainScaffold(
            child: ErrorView(
              message: message,
              onRetry: context.read<DetailsCubit>().load,
            ),
          ),
        DetailsSuccess() => _DetailsBody(state: state),
      },
    );
  }
}

class _PlainScaffold extends StatelessWidget {
  const _PlainScaffold({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      Scaffold(appBar: AppBar(), body: child);
}

class _DetailsBody extends StatelessWidget {
  const _DetailsBody({required this.state});

  final DetailsSuccess state;

  @override
  Widget build(BuildContext context) {
    final d = state.details;
    return Scaffold(
      backgroundColor: AppColors.heroBg,
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.zero,
            children: [
              _Gallery(urls: d.gallery, productId: d.product.id),
              _Sheet(state: state),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _AddToCartBar(
              label: d.addToCartLabel,
              enabled: d.canAddToCart,
            ),
          ),
        ],
      ),
    );
  }
}

class _Gallery extends StatefulWidget {
  const _Gallery({required this.urls, required this.productId});

  final List<String> urls;
  final String productId;

  @override
  State<_Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<_Gallery> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 380,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            itemCount: widget.urls.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (_, i) => NetworkImageBox(widget.urls[i]),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.chevron_left, color: AppColors.dark),
                    ),
                  ),
                  FavoriteButton(productId: widget.productId, size: 36),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < widget.urls.length; i++)
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == _index ? AppColors.dark : Colors.white,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Sheet extends StatelessWidget {
  const _Sheet({required this.state});

  final DetailsSuccess state;

  @override
  Widget build(BuildContext context) {
    final d = state.details;
    final cubit = context.read<DetailsCubit>();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(d.product.name,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.dark)),
              ),
              Text(d.product.priceLabel,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.dark)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              RatingStars(rating: d.rating, size: 16),
              const SizedBox(width: 4),
              Text('(${d.ratingCount})',
                  style: const TextStyle(fontSize: 9, color: AppColors.grey)),
            ],
          ),
          const Divider(height: 28),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _Label('Color'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        for (final c in d.colors)
                          _ColorDot(
                            color: c,
                            selected: c.id == state.selectedColorId,
                            onTap: () => cubit.selectColor(c.id),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Label('Size'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      for (final s in d.sizes)
                        _SizeBox(
                          size: s,
                          selected: s == state.selectedSize,
                          available: d.sizeAvailability[s] ?? false,
                          onTap: () => cubit.selectSize(s),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 28),
          _Section(
            title: 'Description',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  d.description,
                  maxLines: state.descriptionExpanded ? null : 3,
                  overflow: state.descriptionExpanded
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 11, height: 1.5, color: AppColors.grey),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: cubit.toggleDescription,
                  child: Text(
                    state.descriptionExpanded ? 'Read less' : 'Read more',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.grey,
                        decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 28),
          _Section(title: 'Reviews', child: _Reviews(details: d)),
          const SizedBox(height: 8),
          _Section(
            title: 'Similar Product',
            child: SizedBox(
              height: 210,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: d.similar.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) => ProductCard(
                  product: d.similar[i],
                  width: 100,
                  onTap: () => openProductDetails(context, d.similar[i]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(fontSize: 12, color: AppColors.dark));
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      initiallyExpanded: true,
      tilePadding: EdgeInsets.zero,
      childrenPadding: EdgeInsets.zero,
      shape: const Border(),
      collapsedShape: const Border(),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      title: Text(title,
          style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.dark)),
      children: [child],
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({required this.color, required this.selected, required this.onTap});

  final ProductColor color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? AppColors.dark : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(shape: BoxShape.circle, color: color.color),
        ),
      ),
    );
  }
}

class _SizeBox extends StatelessWidget {
  const _SizeBox({
    required this.size,
    required this.selected,
    required this.available,
    required this.onTap,
  });

  final String size;
  final bool selected;
  final bool available;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: available ? onTap : null,
      child: Container(
        width: 28,
        height: 28,
        margin: const EdgeInsets.only(left: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.dark : AppColors.surface,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          size,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: selected
                ? Colors.white
                : available
                    ? AppColors.dark
                    : AppColors.grey.withOpacity(0.5),
          ),
        ),
      ),
    );
  }
}

class _Reviews extends StatelessWidget {
  const _Reviews({required this.details});

  final ProductDetails details;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(details.rating.toString(),
                    style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: AppColors.dark)),
                const Text('out of 5',
                    style: TextStyle(fontSize: 10, color: AppColors.grey)),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  for (final r in details.ratingBreakdown)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          Text('${r.stars}',
                              style: const TextStyle(
                                  fontSize: 9, color: AppColors.grey)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: r.percentage / 100,
                                minHeight: 4,
                                color: AppColors.green,
                                backgroundColor: AppColors.surface,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 32,
                            child: Text('${r.percentage}%',
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                    fontSize: 9, color: AppColors.grey)),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text('${details.reviewCount} Reviews',
            style: const TextStyle(fontSize: 9, color: AppColors.grey)),
        const SizedBox(height: 12),
        for (final r in details.reviews)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.surface,
                  backgroundImage: NetworkImage(r.avatarUrl),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(r.author,
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.dark)),
                          Text(r.createdAtLabel,
                              style: const TextStyle(
                                  fontSize: 9, color: AppColors.grey)),
                        ],
                      ),
                      RatingStars(rating: r.rating, size: 11),
                      const SizedBox(height: 4),
                      Text(r.text,
                          style: const TextStyle(
                              fontSize: 10, height: 1.4, color: AppColors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _AddToCartBar extends StatelessWidget {
  const _AddToCartBar({required this.label, required this.enabled});

  final String label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Material(
          color: enabled ? AppColors.dark : AppColors.grey,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: enabled ? context.read<DetailsCubit>().addToCart : null,
            child: SizedBox(
              height: 56,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_bag_outlined,
                      color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Text(label,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
