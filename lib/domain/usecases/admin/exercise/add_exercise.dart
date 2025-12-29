import '../../../entities/exercise.dart';
import '../../../repositories/admin/admin_exercise_repository.dart';

class AddExercise {
  final AdminExerciseRepository _repository;

  AddExercise(this._repository);

  Future<Exercise> call({
    required String name,
    required String muscleGroup,
    required String difficulty,
    int? sets,
    int? reps,
    int? restTimeSec,
    int? caloriesBurned,
    String? instructions,
    String? imagePath,
  }) =>
      _repository.addExercise(
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

