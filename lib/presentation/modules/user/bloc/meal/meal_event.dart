import 'package:equatable/equatable.dart';

abstract class MealEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AddMealEvent extends MealEvent {
  final int foodId;
  final String mealSession;
  final int weightGrams;

  AddMealEvent({
    required this.foodId,
    required this.mealSession,
    required this.weightGrams,
  });

  @override
  List<Object?> get props => [foodId, mealSession, weightGrams];
}

class LoadTodayMeals extends MealEvent {}

