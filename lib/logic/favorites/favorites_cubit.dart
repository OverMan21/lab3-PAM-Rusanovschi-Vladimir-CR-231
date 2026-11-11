import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/store_repository.dart';

/// Starea = multimea id-urilor produselor favorite.
class FavoritesCubit extends Cubit<Set<String>> {
  FavoritesCubit(this._repository) : super(const {});

  final StoreRepository _repository;

  Future<void> load() async {
    try {
      emit(await _repository.fetchInitialFavorites());
    } catch (_) {
      // Favoritele raman goale daca JSON-ul nu poate fi citit.
    }
  }

  void toggle(String productId) {
    final next = {...state};
    if (!next.remove(productId)) next.add(productId);
    emit(next);
  }
}
