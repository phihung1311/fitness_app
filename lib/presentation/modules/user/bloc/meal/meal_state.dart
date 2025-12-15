import 'package:equatable/equatable.dart';
import '../../../../../domain/entities/user_meal.dart';

class MealState extends Equatable {
  final Map<String, List<UserMeal>>? todayMeals; // breakfast, lunch, dinner, snack
  final int totalCalories;
  final bool isLoading;
  final bool isAdding;
  final bool isUpdating;
  final String? errorMessage;
  final String? successMessage;

  const MealState({
    this.todayMeals,
    this.totalCalories = 0,
    this.isLoading = false,
    this.isAdding = false,
    this.isUpdating = false,
    this.errorMessage,
    this.successMessage,
  });

  MealState copyWith({
    Map<String, List<UserMeal>>? todayMeals,
    int? totalCalories,
    bool? isLoading,
    bool? isAdding,
    bool? isUpdating,
    String? errorMessage,
    String? successMessage,
  }) {
    return MealState(
      todayMeals: todayMeals ?? this.todayMeals,
      totalCalories: totalCalories ?? this.totalCalories,
      isLoading: isLoading ?? this.isLoading,
      isAdding: isAdding ?? this.isAdding,
      isUpdating: isUpdating ?? this.isUpdating,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
        todayMeals,
        totalCalories,
        isLoading,
        isAdding,
        isUpdating,
        errorMessage,
        successMessage,
      ];
}

