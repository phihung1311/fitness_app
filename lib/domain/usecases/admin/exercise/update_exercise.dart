import '../../../repositories/admin/exercise/admin_exercise_repository.dart';

/// UseCase: Cập nhật bài tập (chỉ admin)
class UpdateExercise {
  final AdminExerciseRepository _repository;

  UpdateExercise(this._repository);

  Future<void> call({
    required int exerciseId,
    String? name,
    String? muscleGroup,
    String? difficulty,
    int? sets,
    int? reps,
    int? restTimeSec,
    int? caloriesBurned,
    String? instructions,
    String? imagePath,
  }) =>
      _repository.updateExercise(
        exerciseId: exerciseId,
        name: name,
        muscleGroup: muscleGroup,
        difficulty: difficulty,
        sets: sets,
        reps: reps,
        restTimeSec: restTimeSec,
        caloriesBurned: caloriesBurned,
        instructions: instructions,
        imagePath: imagePath,
      );
}

