import '../../domain/entities/exercise.dart';
import '../../domain/repositories/exercise_repository.dart';
import '../datasources/remote/exercise_api.dart';

class ExerciseRepositoryImpl implements ExerciseRepository {
  final ExerciseApi _exerciseApi;

  ExerciseRepositoryImpl(this._exerciseApi);

  @override
  Future<List<Exercise>> getAllExercises({
    String? muscleGroup,
    String? difficulty,
    String? search,
  }) async {
    try {
      final dtos = await _exerciseApi.getAllExercises(
        muscleGroup: muscleGroup,
        difficulty: difficulty,
        search: search,
      );
      return dtos.map((dto) => dto.toEntity()).toList();
    } catch (e) {
      throw Exception('Lỗi lấy danh sách bài tập từ repository: $e');
    }
  }

  @override
  Future<Exercise> getExerciseDetail(int id) async {
    try {
      final dto = await _exerciseApi.getExerciseDetail(id);
      return dto.toEntity();
    } catch (e) {
      throw Exception('Lỗi lấy chi tiết bài tập: $e');
    }
  }
}

