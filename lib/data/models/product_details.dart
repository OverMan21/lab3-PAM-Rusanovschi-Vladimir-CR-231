import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'product.dart';

class ProductColor extends Equatable {
  const ProductColor({required this.id, required this.name, required this.color});

  final String id;
  final String name;
  final Color color;

  factory ProductColor.fromJson(Map<String, dynamic> json) => ProductColor(
        id: json['id'] as String,
        name: json['name'] as String,
        color: Color(int.parse((json['value'] as String).replaceFirst('#', '0xFF'))),
      );

  @override
  List<Object?> get props => [id, name, color];
}

class RatingShare extends Equatable {
  const RatingShare({required this.stars, required this.percentage});

  final int stars;
  final int percentage;

  factory RatingShare.fromJson(Map<String, dynamic> json) => RatingShare(
        stars: json['stars'] as int,
        percentage: json['percentage'] as int,
      );

  @override
  List<Object?> get props => [stars, percentage];
}

class Review extends Equatable {
  const Review({
    required this.id,
    required this.author,
    required this.avatarUrl,
    required this.rating,
    required this.createdAtLabel,
    required this.text,
  });

  final String id;
  final String author;
  final String avatarUrl;
  final double rating;
  final String createdAtLabel;
  final String text;

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: json['id'] as String,
        author: json['author'] as String,
        avatarUrl: json['avatarUrl'] as String,
        rating: (json['rating'] as num).toDouble(),
        createdAtLabel: json['createdAtLabel'] as String,
        text: json['text'] as String,
      );

  @override
  List<Object?> get props => [id, author, rating, text];
}

class ProductDetails extends Equatable {
  const ProductDetails({
    required this.product,
    required this.gallery,
    required this.rating,
    required this.ratingCount,
    required this.reviewCount,
    required this.description,
    required this.colors,
    required this.defaultColorId,
    required this.sizes,
    required this.defaultSize,
    required this.sizeAvailability,
    required this.ratingBreakdown,
    required this.reviews,
    required this.similar,
    required this.canAddToCart,
    required this.addToCartLabel,
  });

  final Product product;
  final List<String> gallery;
  final double rating;
  final int ratingCount;
  final int reviewCount;
  final String description;
  final List<ProductColor> colors;
  final String defaultColorId;
  final List<String> sizes;
  final String defaultSize;
  final Map<String, bool> sizeAvailability;
  final List<RatingShare> ratingBreakdown;
  final List<Review> reviews;
  final List<Product> similar;
  final bool canAddToCart;
  final String addToCartLabel;

  /// [override] = produsul pe care s-a apasat. JSON-ul contine detalii complete
  /// doar pentru p003, deci pentru celelalte produse refolosim aceleasi detalii
  /// (descriere, recenzii etc.), dar cu numele, pretul si poza produsului ales.
  factory ProductDetails.fromJson(
    Map<String, dynamic> json, {
    Product? override,
  }) {
    final base = Product.fromJson(json);
    final product = override ?? base;
    final overridden = product.id != base.id;
    final actions = json['actions'] as Map<String, dynamic>;

    List<T> list<T>(String key, T Function(Map<String, dynamic>) parse) =>
        (json[key] as List<dynamic>)
            .map((e) => parse(e as Map<String, dynamic>))
            .toList();

    return ProductDetails(
      product: product,
      gallery: overridden
          ? [product.imageUrl]
          : (json['galleryImageUrls'] as List<dynamic>).cast<String>(),
      rating: (json['rating'] as num).toDouble(),
      ratingCount: json['ratingCount'] as int,
      reviewCount: json['reviewCount'] as int,
      description: json['description'] as String,
      colors: list('availableColors', ProductColor.fromJson),
      defaultColorId: json['selectedColor'] as String,
      sizes: (json['availableSizes'] as List<dynamic>).cast<String>(),
      defaultSize: json['selectedSize'] as String,
      sizeAvailability: (json['sizeAvailability'] as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, v as bool)),
      ratingBreakdown: list('ratingBreakdown', RatingShare.fromJson),
      reviews: list('reviews', Review.fromJson),
      similar: list('similarProducts', Product.fromJson)
          .where((p) => p.id != product.id)
          .toList(),
      canAddToCart: (actions['canAddToCart'] as bool?) ?? true,
      addToCartLabel: (actions['addToCartLabel'] as String?) ?? 'Add To Cart',
    );
  }

  @override
  List<Object?> get props => [product, gallery, rating, reviews, similar];
}
