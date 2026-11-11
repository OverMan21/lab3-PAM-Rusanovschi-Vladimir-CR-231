part of 'home_cubit.dart';

enum SortType {
  none('Implicit'),
  priceAsc('Preț crescător'),
  priceDesc('Preț descrescător'),
  nameAsc('Nume A–Z');

  const SortType(this.label);
  final String label;
}

enum PriceFilter {
  all('Toate'),
  under40('Sub \$40'),
  from40('\$40+');

  const PriceFilter(this.label);
  final String label;
}

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => const [];
}

final class HomeLoading extends HomeState {
  const HomeLoading();
}

final class HomeError extends HomeState {
  const HomeError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

/// Fie nu exista deloc produse, fie filtrele/cautarea nu intorc nimic.
final class HomeEmpty extends HomeState {
  const HomeEmpty({
    required this.hasFilters,
    this.query = '',
    this.sort = SortType.none,
    this.priceFilter = PriceFilter.all,
  });

  final bool hasFilters;
  final String query;
  final SortType sort;
  final PriceFilter priceFilter;

  @override
  List<Object?> get props => [hasFilters, query, sort, priceFilter];
}

final class HomeSuccess extends HomeState {
  const HomeSuccess({
    required this.data,
    required this.feature,
    required this.recommended,
    required this.selectedCategoryId,
    required this.query,
    required this.sort,
    required this.priceFilter,
  });

  final HomeData data;
  final List<Product> feature; // dupa cautare/filtrare/sortare
  final List<Product> recommended;
  final String selectedCategoryId;
  final String query;
  final SortType sort;
  final PriceFilter priceFilter;

  @override
  List<Object?> get props => [
        data,
        feature,
        recommended,
        selectedCategoryId,
        query,
        sort,
        priceFilter,
      ];
}
