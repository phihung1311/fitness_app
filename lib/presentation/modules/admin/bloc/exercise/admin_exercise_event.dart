import 'package:equatable/equatable.dart';

/// Events cho AdminExerciseBloc
/// Tách biệt hoàn toàn với ExerciseEvent của User
abstract class AdminExerciseEvent extends Equatable {
  const AdminExerciseEvent();

  @override
  List<Object?> get props => [];
}

/// Load danh sách bài tập
class LoadExercises extends AdminExerciseEvent {
  const LoadExercises();
}

/// Thêm bài tập mới
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

/// Cập nhật bài tập
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

/// Xóa bài tập
class DeleteExerciseEvent extends AdminExerciseEvent {
  final int exerciseId;

  const DeleteExerciseEvent(this.exerciseId);

  @override
  List<Object?> get props => [exerciseId];
}

/// Tìm kiếm bài tập
class SearchExercisesEvent extends AdminExerciseEvent {
  final String query;

  const SearchExercisesEvent(this.query);

  @override
  List<Object?> get props => [query];
}

/// Lọc bài tập theo nhóm cơ
class FilterExercisesByMuscleGroupEvent extends AdminExerciseEvent {
  final String? muscleGroup;

  const FilterExercisesByMuscleGroupEvent(this.muscleGroup);

  @override
  List<Object?> get props => [muscleGroup];
}

/// Lọc bài tập theo độ khó
class FilterExercisesByDifficultyEvent extends AdminExerciseEvent {
  final String? difficulty;

  const FilterExercisesByDifficultyEvent(this.difficulty);

  @override
  List<Object?> get props => [difficulty];
}

