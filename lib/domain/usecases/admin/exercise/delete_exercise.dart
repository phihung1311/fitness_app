import '../../../repositories/admin/exercise/admin_exercise_repository.dart';

/// UseCase: Xóa bài tập (chỉ admin)
class DeleteExercise {
  final AdminExerciseRepository _repository;

  DeleteExercise(this._repository);

  Future<void> call(int exerciseId) => _repository.deleteExercise(exerciseId);
}

