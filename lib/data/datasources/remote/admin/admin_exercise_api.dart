import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../services/storage/token_storage.dart';
import '../../../dtos/exercise_dto.dart';

/// API client cho Admin quản lý bài tập
/// Tách biệt hoàn toàn với ExerciseApi của User
class AdminExerciseApi {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  AdminExerciseApi(this._dio, this._tokenStorage);

  /// Lấy danh sách tất cả bài tập (chỉ admin)
  Future<List<ExerciseDto>> getExercises() async {
    try {
      final token = _tokenStorage.readToken();
      final response = await _dio.get(
        '${ApiEndpoints.baseUrl}/admin/exercises',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      final List<dynamic> exercisesJson = response.data as List<dynamic>;
      return exercisesJson
          .map((json) => ExerciseDto.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception('Lỗi lấy danh sách bài tập: ${e.message}');
    }
  }

  /// Thêm bài tập mới (chỉ admin)
  Future<ExerciseDto> addExercise({
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
      final token = _tokenStorage.readToken();
      final formData = FormData.fromMap({
        'name': name,
        'muscle_group': muscleGroup,
        'difficulty': difficulty,
        if (sets != null) 'sets': sets,
        if (reps != null) 'reps': reps,
        if (restTimeSec != null) 'rest_time_sec': restTimeSec,
        if (caloriesBurned != null) 'calories_burned': caloriesBurned,
        if (instructions != null && instructions.isNotEmpty) 'instructions': instructions,
        if (imagePath != null)
          'image': await MultipartFile.fromFile(imagePath),
      });

      final response = await _dio.post(
        '${ApiEndpoints.baseUrl}/admin/exercises',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      return ExerciseDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Lỗi thêm bài tập: ${e.message}');
    }
  }

  /// Cập nhật bài tập (chỉ admin)
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
      final token = _tokenStorage.readToken();
      final formData = FormData.fromMap({
        if (name != null) 'name': name,
        if (muscleGroup != null) 'muscle_group': muscleGroup,
        if (difficulty != null) 'difficulty': difficulty,
        if (sets != null) 'sets': sets,
        if (reps != null) 'reps': reps,
        if (restTimeSec != null) 'rest_time_sec': restTimeSec,
        if (caloriesBurned != null) 'calories_burned': caloriesBurned,
        if (instructions != null) 'instructions': instructions,
        if (imagePath != null)
          'image': await MultipartFile.fromFile(imagePath),
      });

      await _dio.put(
        '${ApiEndpoints.baseUrl}/admin/exercises/$exerciseId',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } on DioException catch (e) {
      throw Exception('Lỗi cập nhật bài tập: ${e.message}');
    }
  }

  /// Xóa bài tập (chỉ admin)
  Future<void> deleteExercise(int exerciseId) async {
    try {
      final token = _tokenStorage.readToken();
      await _dio.delete(
        '${ApiEndpoints.baseUrl}/admin/exercises/$exerciseId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } on DioException catch (e) {
      throw Exception('Lỗi xóa bài tập: ${e.message}');
    }
  }
}

