import 'package:equatable/equatable.dart';

abstract class MealEvent extends Equatable {
  const MealEvent();

  @override
  List<Object?> get props => [];
}

class AddMealEvent extends MealEvent {
  final int foodId;
  final String mealSession;
  final int weightGrams;

  const AddMealEvent({
    required this.foodId,
    required this.mealSession,
    required this.weightGrams,
  });

  @override
  List<Object?> get props => [foodId, mealSession, weightGrams];
}

class LoadTodayMeals extends MealEvent {}

class UpdateMealEvent extends MealEvent {
  final int mealId;
  final int weightGrams;

  const UpdateMealEvent({required this.mealId, required this.weightGrams});

  @override
  List<Object?> get props => [mealId, weightGrams];
}

class DeleteMealEvent extends MealEvent {
  final int mealId;

  const DeleteMealEvent(this.mealId);

  @override
  List<Object?> get props => [mealId];
}

