import '../../entities/exercise.dart';
import '../../repositories/exercise_repository.dart';

class GetExercises {
  final ExerciseRepository _repository;

  GetExercises(this._repository);

  Future<List<Exercise>> call({
    String? muscleGroup,
    String? difficulty,
    String? search,
  }) async {
    return await _repository.getAllExercises(
      muscleGroup: muscleGroup,
      difficulty: difficulty,
      search: search,
    );
  }
}

