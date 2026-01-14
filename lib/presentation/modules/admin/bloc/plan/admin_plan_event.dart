import 'package:equatable/equatable.dart';

abstract class AdminPlanEvent extends Equatable {
  const AdminPlanEvent();

  @override
  List<Object?> get props => [];
}

class CreateTemplatePlanEvent extends AdminPlanEvent {
  final String name;
  final String? description;
  final String goalType;
  final double targetWeightChange;
  final int durationDays;
  final String level;
  final String? activityLevel;
  final int? targetCalories;

  const CreateTemplatePlanEvent({
    required this.name,
    this.description,
    required this.goalType,
    required this.targetWeightChange,
    required this.durationDays,
    required this.level,
    this.activityLevel,
    this.targetCalories,
  });

  @override
  List<Object?> get props => [
        name,
        description,
        goalType,
        targetWeightChange,
        durationDays,
        level,
        activityLevel,
        targetCalories,
      ];
}

class LoadTemplatePlansEvent extends AdminPlanEvent {
  final String? goalType;
  final String? level;

  const LoadTemplatePlansEvent({this.goalType, this.level});

  @override
  List<Object?> get props => [goalType, level];
}

class DeleteTemplatePlanEvent extends AdminPlanEvent {
  final int mealPlanId;
  final int workoutPlanId;

  const DeleteTemplatePlanEvent({
    required this.mealPlanId,
    required this.workoutPlanId,
  });

  @override
  List<Object?> get props => [mealPlanId, workoutPlanId];
}

class LoadTemplatePlanDetailEvent extends AdminPlanEvent {
  final int mealPlanId;
  final int workoutPlanId;

  const LoadTemplatePlanDetailEvent({
    required this.mealPlanId,
    required this.workoutPlanId,
  });

  @override
  List<Object?> get props => [mealPlanId, workoutPlanId];
}

// Meal Plan Foods Events
class AddFoodToMealPlanEvent extends AdminPlanEvent {
  final int mealPlanId;
  final int foodId;
  final String dayOfWeek;
  final String mealSession;
  final int sizeGram;

  const AddFoodToMealPlanEvent({
    required this.mealPlanId,
    required this.foodId,
    required this.dayOfWeek,
    required this.mealSession,
    required this.sizeGram,
  });

  @override
  List<Object?> get props => [mealPlanId, foodId, dayOfWeek, mealSession, sizeGram];
}

class UpdateFoodInMealPlanEvent extends AdminPlanEvent {
  final int mealPlanId;
  final int foodId;
  final int? sizeGram;
  final String? dayOfWeek;
  final String? mealSession;

  const UpdateFoodInMealPlanEvent({
    required this.mealPlanId,
    required this.foodId,
    this.sizeGram,
    this.dayOfWeek,
    this.mealSession,
  });

  @override
  List<Object?> get props => [mealPlanId, foodId, sizeGram, dayOfWeek, mealSession];
}

class DeleteFoodFromMealPlanEvent extends AdminPlanEvent {
  final int mealPlanId;
  final int foodId;

  const DeleteFoodFromMealPlanEvent({
    required this.mealPlanId,
    required this.foodId,
  });

  @override
  List<Object?> get props => [mealPlanId, foodId];
}

// Workout Plan Exercises Events
class AddExerciseToWorkoutPlanEvent extends AdminPlanEvent {
  final int workoutPlanId;
  final int exerciseId;
  final String dayOfWeek;
  final int? sets;
  final int? reps;
  final int? durationMin;
  final int? orderIndex;

  const AddExerciseToWorkoutPlanEvent({
    required this.workoutPlanId,
    required this.exerciseId,
    required this.dayOfWeek,
    this.sets,
    this.reps,
    this.durationMin,
    this.orderIndex,
  });

  @override
  List<Object?> get props => [workoutPlanId, exerciseId, dayOfWeek, sets, reps, durationMin, orderIndex];
}

class UpdateExerciseInWorkoutPlanEvent extends AdminPlanEvent {
  final int workoutPlanId;
  final int exerciseId;
  final int? sets;
  final int? reps;
  final int? durationMin;
  final String? dayOfWeek;
  final int? orderIndex;

  const UpdateExerciseInWorkoutPlanEvent({
    required this.workoutPlanId,
    required this.exerciseId,
    this.sets,
    this.reps,
    this.durationMin,
    this.dayOfWeek,
    this.orderIndex,
  });

  @override
  List<Object?> get props => [workoutPlanId, exerciseId, sets, reps, durationMin, dayOfWeek, orderIndex];
}

class DeleteExerciseFromWorkoutPlanEvent extends AdminPlanEvent {
  final int workoutPlanId;
  final int exerciseId;

  const DeleteExerciseFromWorkoutPlanEvent({
    required this.workoutPlanId,
    required this.exerciseId,
  });

  @override
  List<Object?> get props => [workoutPlanId, exerciseId];
}
