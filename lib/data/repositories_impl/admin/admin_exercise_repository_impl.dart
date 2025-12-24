import '../../../domain/entities/exercise.dart';
import '../../../domain/repositories/admin/exercise/admin_exercise_repository.dart';
import '../../datasources/remote/admin/admin_exercise_api.dart';

/// Repository implementation cho Admin quản lý bài tập
/// Tách biệt hoàn toàn với ExerciseRepositoryImpl của User
class AdminExerciseRepositoryImpl implements AdminExerciseRepository {
  final AdminExerciseApi _api;

  AdminExerciseRepositoryImpl(this._api);

  @override
  Future<List<Exercise>> getExercises() async {
    try {
      final dtos = await _api.getExercises();
      return dtos.map((dto) => dto.toEntity()).whereType<Exercise>().toList();
    } catch (e) {
      throw Exception('Lỗi lấy danh sách bài tập: $e');
    }
  }

  @override
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
  }) async {
    try {
      final dto = await _api.addExercise(
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
      return dto.toEntity();
    } catch (e) {
      throw Exception('Lỗi thêm bài tập: $e');
    }
  }

  @override
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
  }) async {
    try {
      await _api.updateExercise(
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
    } catch (e) {
      throw Exception('Lỗi cập nhật bài tập: $e');
    }
  }

  @override
  Future<void> deleteExercise(int exerciseId) async {
    try {
      await _api.deleteExercise(exerciseId);
    } catch (e) {
      throw Exception('Lỗi xóa bài tập: $e');
    }
  }
}

