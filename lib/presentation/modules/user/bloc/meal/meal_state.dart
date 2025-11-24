import 'package:equatable/equatable.dart';
import '../../../../../domain/entities/user_meal.dart';

class MealState extends Equatable {
  final Map<String, List<UserMeal>>? todayMeals; // breakfast, lunch, dinner, snack
  final int totalCalories;
  final bool isLoading;
  final bool isAdding;
  final String? errorMessage;
  final String? successMessage;

  const MealState({
    this.todayMeals,
    this.totalCalories = 0,
    this.isLoading = false,
    this.isAdding = false,
    this.errorMessage,
    this.successMessage,
  });

  MealState copyWith({
    Map<String, List<UserMeal>>? todayMeals,
    int? totalCalories,
    bool? isLoading,
    bool? isAdding,
    String? errorMessage,
    String? successMessage,
  }) {
    return MealState(
      todayMeals: todayMeals ?? this.todayMeals,
      totalCalories: totalCalories ?? this.totalCalories,
      isLoading: isLoading ?? this.isLoading,
      isAdding: isAdding ?? this.isAdding,
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
        errorMessage,
        successMessage,
      ];
}

