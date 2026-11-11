import 'package:equatable/equatable.dart';

import 'product.dart';

class StoreCategory extends Equatable {
  const StoreCategory({
    required this.id,
    required this.name,
    required this.iconUrl,
    required this.selected,
  });

  final String id;
  final String name;
  final String iconUrl;
  final bool selected;

  factory StoreCategory.fromJson(Map<String, dynamic> json) => StoreCategory(
        id: json['id'] as String,
        name: json['name'] as String,
        iconUrl: json['iconUrl'] as String,
        selected: (json['selected'] as bool?) ?? false,
      );

  @override
  List<Object?> get props => [id, name, iconUrl, selected];
}

/// Model generic pentru bannere/colectii: heroBanner, newCollection,
/// topCollections si categoryPromos au aceeasi forma (label, title, image).
class Promo extends Equatable {
  const Promo({
    required this.id,
    required this.label,
    required this.title,
    required this.imageUrl,
    this.slides = 1,
    this.activeSlide = 0,
  });

  final String id;
  final String label;
  final String title;
  final String imageUrl;
  final int slides;
  final int activeSlide;

  factory Promo.fromJson(Map<String, dynamic> json) => Promo(
        id: (json['id'] as String?) ?? '',
        label: ((json['label'] ?? json['category']) as String?) ?? '',
        title: json['title'] as String,
        imageUrl: json['imageUrl'] as String,
        slides: (json['slides'] as int?) ?? 1,
        activeSlide: (json['activeSlide'] as int?) ?? 0,
      );

  @override
  List<Object?> get props => [id, label, title, imageUrl, slides, activeSlide];
}

class HomeData extends Equatable {
  const HomeData({
    required this.storeName,
    required this.categories,
    required this.hero,
    required this.featureProducts,
    required this.newCollection,
    required this.recommended,
    required this.topCollections,
    required this.categoryPromos,
  });

  final String storeName;
  final List<StoreCategory> categories;
  final Promo hero;
  final List<Product> featureProducts;
  final Promo newCollection;
  final List<Product> recommended;
  final List<Promo> topCollections;
  final List<Promo> categoryPromos;

  bool get hasProducts => featureProducts.isNotEmpty || recommended.isNotEmpty;

  factory HomeData.fromJson(Map<String, dynamic> json) {
    List<T> list<T>(String key, T Function(Map<String, dynamic>) parse) =>
        (json[key] as List<dynamic>? ?? [])
            .map((e) => parse(e as Map<String, dynamic>))
            .toList();

    return HomeData(
      storeName: json['storeName'] as String,
      categories: list('categories', StoreCategory.fromJson),
      hero: Promo.fromJson(json['heroBanner'] as Map<String, dynamic>),
      featureProducts: list('featureProducts', Product.fromJson),
      newCollection:
          Promo.fromJson(json['newCollection'] as Map<String, dynamic>),
      recommended: list('recommended', Product.fromJson),
      topCollections: list('topCollections', Promo.fromJson),
      categoryPromos: list('categoryPromos', Promo.fromJson),
    );
  }

  @override
  List<Object?> get props => [
        storeName,
        categories,
        hero,
        featureProducts,
        newCollection,
        recommended,
        topCollections,
        categoryPromos,
      ];
}
