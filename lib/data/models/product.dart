import 'package:equatable/equatable.dart';

class Product extends Equatable {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.currency,
    required this.imageUrl,
  });

  final String id;
  final String name;
  final double price;
  final String currency;
  final String imageUrl;

  /// Functioneaza si pentru produsele din liste (`imageUrl`)
  /// si pentru produsul din `productPage` (`mainImageUrl`).
  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] as String,
        name: json['name'] as String,
        price: (json['price'] as num).toDouble(),
        currency: (json['currency'] as String?) ?? 'USD',
        imageUrl: (json['imageUrl'] ?? json['mainImageUrl']) as String,
      );

  String get priceLabel => '\$${price.toStringAsFixed(2)}';

  @override
  List<Object?> get props => [id, name, price, currency, imageUrl];
}
