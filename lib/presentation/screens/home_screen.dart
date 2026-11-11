import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme.dart';
import '../../data/models/home_data.dart';
import '../../logic/home/home_cubit.dart';
import '../widgets/network_image_box.dart';
import '../widgets/product_card.dart';
import '../widgets/promo_card.dart';
import '../widgets/section_header.dart';
import '../widgets/state_views.dart';
import 'product_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _reset() {
    _search.clear();
    context.read<HomeCubit>().resetFilters();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final title = state is HomeSuccess ? state.data.storeName : 'GemStore';
        return Scaffold(
          appBar: AppBar(
            leading: const Icon(Icons.menu),
            title: Text(title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none),
              ),
            ],
          ),
          body: Column(
            children: [
              _Toolbar(controller: _search),
              Expanded(child: _buildBody(context, state)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, HomeState state) {
    final cubit = context.read<HomeCubit>();
    return switch (state) {
      HomeLoading() => const LoadingView(),
      HomeError(:final message) =>
        ErrorView(message: message, onRetry: cubit.load),
      HomeEmpty(:final hasFilters) => EmptyView(
          message: hasFilters
              ? 'Nu am găsit produse pentru căutarea sau filtrele alese.'
              : 'Momentan nu există produse.',
          actionLabel: hasFilters ? 'Resetează filtrele' : null,
          onAction: hasFilters ? _reset : null,
        ),
      HomeSuccess() => _HomeContent(state: state),
    };
  }
}

/// Cautare + filtru de pret + sortare.
class _Toolbar extends StatelessWidget {
  const _Toolbar({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HomeCubit>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        children: [
          TextField(
            controller: controller,
            onChanged: cubit.search,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Caută produse...',
              prefixIcon: const Icon(Icons.search, color: AppColors.grey),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final f in PriceFilter.values)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(f.label, style: const TextStyle(fontSize: 12)),
                            selected: cubit.priceFilter == f,
                            onSelected: (_) => cubit.setPriceFilter(f),
                            selectedColor: AppColors.dark,
                            labelStyle: TextStyle(
                              color: cubit.priceFilter == f
                                  ? Colors.white
                                  : AppColors.dark,
                            ),
                            checkmarkColor: Colors.white,
                            backgroundColor: AppColors.surface,
                            side: BorderSide.none,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              PopupMenuButton<SortType>(
                tooltip: 'Sortare',
                icon: const Icon(Icons.sort, color: AppColors.dark),
                onSelected: cubit.setSort,
                itemBuilder: (_) => [
                  for (final s in SortType.values)
                    CheckedPopupMenuItem(
                      value: s,
                      checked: cubit.sort == s,
                      child: Text(s.label),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.state});

  final HomeSuccess state;

  @override
  Widget build(BuildContext context) {
    final d = state.data;
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        _CategoryRow(
          categories: d.categories,
          selectedId: state.selectedCategoryId,
          onSelect: context.read<HomeCubit>().selectCategory,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: _HeroBanner(promo: d.hero),
        ),
        if (state.feature.isNotEmpty) ...[
          const SectionHeader('Feature Products'),
          SizedBox(
            height: 240,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: state.feature.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) => ProductCard(
                product: state.feature[i],
                onTap: () => openProductDetails(context, state.feature[i]),
              ),
            ),
          ),
        ],
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: PromoCard(promo: d.newCollection, height: 110, titleSize: 14),
        ),
        if (state.recommended.isNotEmpty) ...[
          const SectionHeader('Recommended'),
          SizedBox(
            height: 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: state.recommended.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) => ProductTile(
                product: state.recommended[i],
                onTap: () => openProductDetails(context, state.recommended[i]),
              ),
            ),
          ),
        ],
        const SectionHeader('Top Collection'),
        for (final promo in d.topCollections)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: PromoCard(promo: promo, height: 130),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              for (final promo in d.categoryPromos)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: PromoCard(
                      promo: promo,
                      height: 170,
                      titleSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.categories,
    required this.selectedId,
    required this.onSelect,
  });

  final List<StoreCategory> categories;
  final String selectedId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (final c in categories)
            GestureDetector(
              onTap: () => onSelect(c.id),
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: c.id == selectedId ? AppColors.dark : AppColors.surface,
                    ),
                    padding: const EdgeInsets.all(12),
                    child: SvgPicture.network(
                      c.iconUrl,
                      colorFilter: ColorFilter.mode(
                        c.id == selectedId ? Colors.white : AppColors.grey,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(c.name,
                      style: const TextStyle(fontSize: 10, color: AppColors.grey)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.promo});

  final Promo promo;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 160,
        child: Stack(
          fit: StackFit.expand,
          children: [
            NetworkImageBox(promo.imageUrl),
            Container(color: Colors.black.withOpacity(0.18)),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 20),
                child: SizedBox(
                  width: 120,
                  child: Text(promo.title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          height: 1.3)),
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < promo.slides; i++)
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == promo.activeSlide
                            ? Colors.white
                            : Colors.white54,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
