import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../services/storage/token_storage.dart';
import '../../dtos/exercise_dto.dart';

class ExerciseApi {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  ExerciseApi(this._dio, this._tokenStorage);

  Future<List<ExerciseDto>> getAllExercises({
    String? muscleGroup,
    String? difficulty,
    String? search,
  }) async {
    try {
      final token = _tokenStorage.readToken();
      final queryParams = <String, dynamic>{};
      
      if (muscleGroup != null) queryParams['muscle_group'] = muscleGroup;
      if (difficulty != null) queryParams['difficulty'] = difficulty;
      if (search != null) queryParams['search'] = search;
      
      final response = await _dio.get(
        '${ApiEndpoints.baseUrl}/user/exercises',
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      
      final List<dynamic> exercisesJson = response.data as List<dynamic>;
      return exercisesJson.map((json) => ExerciseDto.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception('Lỗi lấy danh sách bài tập: ${e.message}');
    }
  }

  Future<ExerciseDto> getExerciseDetail(int id) async {
    try {
      final token = _tokenStorage.readToken();
      final response = await _dio.get(
        '${ApiEndpoints.baseUrl}/user/exercises/$id',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      
      return ExerciseDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Lỗi lấy chi tiết bài tập: ${e.message}');
    }
  }

  // Lấy random exercises
  Future<List<ExerciseDto>> getRandomExercises({int limit = 4}) async {
    try {
      final token = _tokenStorage.readToken();
      final response = await _dio.get(
        '${ApiEndpoints.baseUrl}/user/exercises/random',
        queryParameters: {'limit': limit},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      
      final List<dynamic> exercisesJson = response.data as List<dynamic>;
      return exercisesJson.map((json) => ExerciseDto.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception('Lỗi lấy bài tập ngẫu nhiên: ${e.message}');
    }
  }

  // them bai tap or len lich
  Future<Map<String, dynamic>> addUserExercise({
    required int exerciseId,
    String? workoutDate,
    int? sets,
    int? reps,
    int? durationMin,
  }) async {
    try {
      final token = _tokenStorage.readToken();
      final response = await _dio.post(
        '${ApiEndpoints.baseUrl}/user/exercises/add',
        data: {
          'exercise_id': exerciseId,
          if (workoutDate != null) 'workout_date': workoutDate,
          if (sets != null) 'sets': sets,
          if (reps != null) 'reps': reps,
          if (durationMin != null) 'duration_min': durationMin,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception('Lỗi thêm bài tập: ${e.message}');
    }
  }

  //add yeu thich
  Future<Map<String, dynamic>> addToFavorites(int exerciseId) async {
    try {
      final token = _tokenStorage.readToken();
      final response = await _dio.post(
        '${ApiEndpoints.baseUrl}/user/exercises/favorite',
        data: {'exercise_id': exerciseId},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception('Lỗi thêm vào yêu thích: ${e.message}');
    }
  }

  // Lấy tổng calories hôm nay
  Future<Map<String, dynamic>> getTodayCalories({String? date}) async {
    try {
      final token = _tokenStorage.readToken();
      final response = await _dio.get(
        '${ApiEndpoints.baseUrl}/user/stats/today-calories',
        queryParameters: date != null ? {'date': date} : null,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception('Lỗi lấy tổng calories: ${e.message}');
    }
  }

  //lich su tap
  Future<Map<String, dynamic>> getExerciseHistory(String date) async {
    try {
      final token = _tokenStorage.readToken();
      final response = await _dio.get(
        '${ApiEndpoints.baseUrl}/user/exercises/history',
        queryParameters: {'date': date},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception('Lỗi lấy lịch sử tập luyện: ${e.message}');
    }
  }

  // ds yeu thich
  Future<List<dynamic>> getFavorites() async {
    try {
      final token = _tokenStorage.readToken();
      final response = await _dio.get(
        '${ApiEndpoints.baseUrl}/user/exercises/favorites',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      throw Exception('Lỗi lấy danh sách yêu thích: ${e.message}');
    }
  }

  // Xoa yeu thich
  Future<void> removeFromFavorites(int exerciseId) async {
    try {
      final token = _tokenStorage.readToken();
      await _dio.delete(
        '${ApiEndpoints.baseUrl}/user/exercises/favorite/$exerciseId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } on DioException catch (e) {
      throw Exception('Lỗi xóa khỏi yêu thích: ${e.message}');
    }
  }
}

