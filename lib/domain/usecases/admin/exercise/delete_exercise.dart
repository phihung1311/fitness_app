import '../../../repositories/admin/admin_exercise_repository.dart';

class DeleteExercise {
  final AdminExerciseRepository _repository;

  DeleteExercise(this._repository);

  Future<void> call(int exerciseId) => _repository.deleteExercise(exerciseId);
}

