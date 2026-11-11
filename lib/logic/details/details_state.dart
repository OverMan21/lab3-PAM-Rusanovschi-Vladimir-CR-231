part of 'details_cubit.dart';

sealed class DetailsState extends Equatable {
  const DetailsState();

  @override
  List<Object?> get props => const [];
}

final class DetailsLoading extends DetailsState {
  const DetailsLoading();
}

final class DetailsError extends DetailsState {
  const DetailsError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

final class DetailsSuccess extends DetailsState {
  const DetailsSuccess({
    required this.details,
    required this.selectedColorId,
    required this.selectedSize,
    this.descriptionExpanded = false,
    this.cartCount = 0,
  });

  final ProductDetails details;
  final String selectedColorId;
  final String selectedSize;
  final bool descriptionExpanded;
  final int cartCount;

  DetailsSuccess copyWith({
    String? selectedColorId,
    String? selectedSize,
    bool? descriptionExpanded,
    int? cartCount,
  }) =>
      DetailsSuccess(
        details: details,
        selectedColorId: selectedColorId ?? this.selectedColorId,
        selectedSize: selectedSize ?? this.selectedSize,
        descriptionExpanded: descriptionExpanded ?? this.descriptionExpanded,
        cartCount: cartCount ?? this.cartCount,
      );

  @override
  List<Object?> get props =>
      [details, selectedColorId, selectedSize, descriptionExpanded, cartCount];
}
