import '../../entities/exercise.dart';
import '../../repositories/exercise_repository.dart';

class GetExerciseDetail {
  final ExerciseRepository _repository;

  GetExerciseDetail(this._repository);

  Future<Exercise> call(int id) async {
    return await _repository.getExerciseDetail(id);
  }
}

