import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/home_data.dart';
import '../models/product.dart';
import '../models/product_details.dart';

class StoreRepository {
  StoreRepository({this.simulateError = false});

  /// Pune `true` ca sa vezi starea Error la demonstratie.
  final bool simulateError;

  static const _asset = 'assets/data/lab_v1.json';
  Map<String, dynamic>? _cache;

  Future<Map<String, dynamic>> _load() async {
    if (simulateError) throw Exception('Eroare simulata');
    // Fisierul JSON este citit asincron din assets si decodat o singura data.
    final raw = await rootBundle.loadString(_asset);
    return _cache ??= jsonDecode(raw) as Map<String, dynamic>;
  }

  Map<String, dynamic> _productJson(Map<String, dynamic> json) =>
      (json['productPage'] as Map<String, dynamic>)['product']
          as Map<String, dynamic>;

  Future<HomeData> fetchHome() async {
    await Future<void>.delayed(const Duration(milliseconds: 900)); // vizibil: Loading
    final json = await _load();
    return HomeData.fromJson(json['homePage'] as Map<String, dynamic>);
  }

  Future<ProductDetails> fetchDetails(Product tapped) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final json = await _load();
    return ProductDetails.fromJson(_productJson(json), override: tapped);
  }

  /// Produsele marcate `isFavorite: true` in JSON.
  Future<Set<String>> fetchInitialFavorites() async {
    final json = await _load();
    final p = _productJson(json);
    final actions = p['actions'] as Map<String, dynamic>;
    return (actions['isFavorite'] as bool? ?? false)
        ? {p['id'] as String}
        : <String>{};
  }
}
