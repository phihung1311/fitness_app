import '../../../entities/exercise.dart';
import '../../../repositories/admin/admin_exercise_repository.dart';

class GetExercises {
  final AdminExerciseRepository _repository;

  GetExercises(this._repository);

  Future<List<Exercise>> call() => _repository.getExercises();
}

