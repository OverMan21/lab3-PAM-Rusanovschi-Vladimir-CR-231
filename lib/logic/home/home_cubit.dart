import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/home_data.dart';
import '../../data/models/product.dart';
import '../../data/repositories/store_repository.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._repository) : super(const HomeLoading());

  final StoreRepository _repository;

  HomeData? _data;
  Timer? _debounce;
  String _query = '';
  String _categoryId = '';
  SortType _sort = SortType.none;
  PriceFilter _price = PriceFilter.all;

  SortType get sort => _sort;
  PriceFilter get priceFilter => _price;

  Future<void> load() async {
    emit(const HomeLoading());
    try {
      final data = await _repository.fetchHome();
      _data = data;
      _categoryId = data.categories
              .where((c) => c.selected)
              .map((c) => c.id)
              .firstOrNull ??
          '';
      if (!data.hasProducts) {
        emit(const HomeEmpty(hasFilters: false));
      } else {
        _apply();
      }
    } catch (_) {
      emit(const HomeError('Nu am putut încărca datele. Încearcă din nou.'));
    }
  }

  void search(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _query = query;
      _apply();
    });
  }

  void setSort(SortType sort) {
    _sort = sort;
    _apply();
  }

  void setPriceFilter(PriceFilter filter) {
    _price = filter;
    _apply();
  }

  void selectCategory(String id) {
    _categoryId = id;
    _apply();
  }

  void resetFilters() {
    _debounce?.cancel();
    _query = '';
    _sort = SortType.none;
    _price = PriceFilter.all;
    _apply();
  }

  bool _matchesPrice(Product p) => switch (_price) {
        PriceFilter.all => true,
        PriceFilter.under40 => p.price < 40,
        PriceFilter.from40 => p.price >= 40,
      };

  List<Product> _run(List<Product> source) {
    final q = _query.trim().toLowerCase();
    final result = source
        .where((p) => p.name.toLowerCase().contains(q))
        .where(_matchesPrice)
        .toList();
    switch (_sort) {
      case SortType.none:
        break;
      case SortType.priceAsc:
        result.sort((a, b) => a.price.compareTo(b.price));
      case SortType.priceDesc:
        result.sort((a, b) => b.price.compareTo(a.price));
      case SortType.nameAsc:
        result.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    }
    return result;
  }

  void _apply() {
    final data = _data;
    if (data == null) return;

    final feature = _run(data.featureProducts);
    final recommended = _run(data.recommended);

    if (feature.isEmpty && recommended.isEmpty) {
      emit(HomeEmpty(
        hasFilters: true,
        query: _query,
        sort: _sort,
        priceFilter: _price,
      ));
      return;
    }
    emit(HomeSuccess(
      data: data,
      feature: feature,
      recommended: recommended,
      selectedCategoryId: _categoryId,
      query: _query,
      sort: _sort,
      priceFilter: _price,
    ));
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
