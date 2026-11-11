import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/product.dart';
import '../../data/models/product_details.dart';
import '../../data/repositories/store_repository.dart';

part 'details_state.dart';

class DetailsCubit extends Cubit<DetailsState> {
  DetailsCubit(this._repository, this._product) : super(const DetailsLoading());

  final StoreRepository _repository;
  final Product _product;

  Future<void> load() async {
    emit(const DetailsLoading());
    try {
      final d = await _repository.fetchDetails(_product);
      emit(DetailsSuccess(
        details: d,
        selectedColorId: d.defaultColorId,
        selectedSize: d.defaultSize,
      ));
    } catch (_) {
      emit(const DetailsError('Nu am putut încărca produsul.'));
    }
  }

  void selectColor(String id) {
    final s = state;
    if (s is DetailsSuccess) emit(s.copyWith(selectedColorId: id));
  }

  void selectSize(String size) {
    final s = state;
    if (s is! DetailsSuccess) return;
    if (s.details.sizeAvailability[size] != true) return; // mărime indisponibilă
    emit(s.copyWith(selectedSize: size));
  }

  void toggleDescription() {
    final s = state;
    if (s is DetailsSuccess) {
      emit(s.copyWith(descriptionExpanded: !s.descriptionExpanded));
    }
  }

  void addToCart() {
    final s = state;
    if (s is DetailsSuccess && s.details.canAddToCart) {
      emit(s.copyWith(cartCount: s.cartCount + 1));
    }
  }
}
