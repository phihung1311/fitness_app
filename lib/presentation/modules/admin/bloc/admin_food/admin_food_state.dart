import 'package:equatable/equatable.dart';
import '../../../../../domain/entities/food.dart';

/// States cho AdminFoodBloc
/// Tách biệt hoàn toàn với MealState của User
class AdminFoodState extends Equatable {
  final List<Food> foods;
  final List<Food> displayedFoods; // Danh sách đã filter/search
  final bool isLoading;
  final bool isSubmitting;
  final String? errorMessage;
  final String? successMessage;
  final String searchQuery;
  final String? selectedMealType;

  const AdminFoodState({
    this.foods = const [],
    this.displayedFoods = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.successMessage,
    this.searchQuery = '',
    this.selectedMealType,
  });

  AdminFoodState copyWith({
    List<Food>? foods,
    List<Food>? displayedFoods,
    bool? isLoading,
    bool? isSubmitting,
    String? errorMessage,
    String? successMessage,
    String? searchQuery,
    String? selectedMealType,
  }) {
    return AdminFoodState(
      foods: foods ?? this.foods,
      displayedFoods: displayedFoods ?? this.displayedFoods,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
      successMessage: successMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedMealType: selectedMealType ?? this.selectedMealType,
    );
  }

  @override
  List<Object?> get props => [
        foods,
        displayedFoods,
        isLoading,
        isSubmitting,
        errorMessage,
        successMessage,
        searchQuery,
        selectedMealType,
      ];
}

