import 'package:equatable/equatable.dart';
import '../../../../../domain/entities/food.dart';

class FoodState extends Equatable {
  final List<Food> allFoods;
  final List<Food> displayedFoods;
  final bool isLoading;
  final String? errorMessage;
  final String searchQuery;
  final String? selectedCategory;

  const FoodState({
    this.allFoods = const [],
    this.displayedFoods = const [],
    this.isLoading = false,
    this.errorMessage,
    this.searchQuery = '',
    this.selectedCategory,
  });

  FoodState copyWith({
    List<Food>? allFoods,
    List<Food>? displayedFoods,
    bool? isLoading,
    String? errorMessage,
    String? searchQuery,
    String? selectedCategory,
  }) {
    return FoodState(
      allFoods: allFoods ?? this.allFoods,
      displayedFoods: displayedFoods ?? this.displayedFoods,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory,
    );
  }

  @override
  List<Object?> get props => [
        allFoods,
        displayedFoods,
        isLoading,
        errorMessage,
        searchQuery,
        selectedCategory,
      ];
}

