import '../../entities/exercise.dart';

abstract class AdminExerciseRepository {
  Future<List<Exercise>> getExercises();
  Future<Exercise> addExercise({
    required String name,
    required String muscleGroup,
    required String difficulty,
    int? sets,
    int? reps,
    int? restTimeSec,
    int? caloriesBurned,
    String? instructions,
    String? imagePath,
  });
  Future<void> updateExercise({
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
  });
  Future<void> deleteExercise(int exerciseId);
}

