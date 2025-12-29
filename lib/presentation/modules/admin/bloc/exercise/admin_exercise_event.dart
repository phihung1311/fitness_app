import 'package:equatable/equatable.dart';

abstract class AdminExerciseEvent extends Equatable {
  const AdminExerciseEvent();

  @override
  List<Object?> get props => [];
}

// Load ds
class LoadExercises extends AdminExerciseEvent {
  const LoadExercises();
}

//add btap
class AddExerciseEvent extends AdminExerciseEvent {
  final String name;
  final String muscleGroup;
  final String difficulty;
  final int? sets;
  final int? reps;
  final int? restTimeSec;
  final int? caloriesBurned;
  final String? instructions;
  final String? imagePath;

  const AddExerciseEvent({
    required this.name,
    required this.muscleGroup,
    required this.difficulty,
    this.sets,
    this.reps,
    this.restTimeSec,
    this.caloriesBurned,
    this.instructions,
    this.imagePath,
  });

  @override
  List<Object?> get props => [
        name,
        muscleGroup,
        difficulty,
        sets,
        reps,
        restTimeSec,
        caloriesBurned,
        instructions,
        imagePath,
      ];
}

//update btap
class UpdateExerciseEvent extends AdminExerciseEvent {
  final int exerciseId;
  final String? name;
  final String? muscleGroup;
  final String? difficulty;
  final int? sets;
  final int? reps;
  final int? restTimeSec;
  final int? caloriesBurned;
  final String? instructions;
  final String? imagePath;

  const UpdateExerciseEvent({
    required this.exerciseId,
    this.name,
    this.muscleGroup,
    this.difficulty,
    this.sets,
    this.reps,
    this.restTimeSec,
    this.caloriesBurned,
    this.instructions,
    this.imagePath,
  });

  @override
  List<Object?> get props => [
        exerciseId,
        name,
        muscleGroup,
        difficulty,
        sets,
        reps,
        restTimeSec,
        caloriesBurned,
        instructions,
        imagePath,
      ];
}

//xoa
class DeleteExerciseEvent extends AdminExerciseEvent {
  final int exerciseId;

  const DeleteExerciseEvent(this.exerciseId);

  @override
  List<Object?> get props => [exerciseId];
}

//timkiem
class SearchExercisesEvent extends AdminExerciseEvent {
  final String query;

  const SearchExercisesEvent(this.query);

  @override
  List<Object?> get props => [query];
}

//loc nhom cơ
class FilterExercisesByMuscleGroupEvent extends AdminExerciseEvent {
  final String? muscleGroup;

  const FilterExercisesByMuscleGroupEvent(this.muscleGroup);

  @override
  List<Object?> get props => [muscleGroup];
}

//loc theo do khó
class FilterExercisesByDifficultyEvent extends AdminExerciseEvent {
  final String? difficulty;

  const FilterExercisesByDifficultyEvent(this.difficulty);

  @override
  List<Object?> get props => [difficulty];
}

