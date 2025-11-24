import '../entities/exercise.dart';

abstract class ExerciseRepository {
  Future<List<Exercise>> getAllExercises({
    String? muscleGroup,
    String? difficulty,
    String? search,
  });
  
  Future<Exercise> getExerciseDetail(int id);
}

