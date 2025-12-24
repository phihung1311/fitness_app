import '../../../entities/exercise.dart';
import '../../../repositories/admin/exercise/admin_exercise_repository.dart';

/// UseCase: Lấy danh sách bài tập (chỉ admin)
class GetExercises {
  final AdminExerciseRepository _repository;

  GetExercises(this._repository);

  Future<List<Exercise>> call() => _repository.getExercises();
}

