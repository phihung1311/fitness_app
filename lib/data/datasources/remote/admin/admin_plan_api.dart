import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../services/storage/token_storage.dart';

class AdminPlanApi {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  AdminPlanApi(this._dio, this._tokenStorage);

  // Tạo template plan
  Future<Map<String, dynamic>> createTemplatePlan({
    required String name,
    String? description,
    required String goalType,
    required double targetWeightChange,
    required int durationDays,
    required String level,
    String? activityLevel,
    int? targetCalories,
  }) async {
    try {
      final token = _tokenStorage.readToken();
      final response = await _dio.post(
        '${ApiEndpoints.baseUrl}/admin/plans/create-template',
        data: {
          'name': name,
          if (description != null) 'description': description,
          'goal_type': goalType,
          'target_weight_change': targetWeightChange,
          'duration_days': durationDays,
          'level': level,
          if (activityLevel != null) 'activity_level': activityLevel,
          if (targetCalories != null) 'target_calories': targetCalories,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      String errorMessage = 'Lỗi tạo template plan';
      if (e.response != null) {
        final errorData = e.response?.data;
        if (errorData is Map && errorData['error'] != null) {
          errorMessage = errorData['error'] as String;
        } else if (errorData is Map && errorData['message'] != null) {
          errorMessage = errorData['message'] as String;
        } else {
          errorMessage = '${e.response?.statusCode}: ${e.message}';
        }
      } else {
        errorMessage = e.message ?? 'Lỗi kết nối';
      }
      throw Exception(errorMessage);
    }
  }

  // List template plans
  Future<List<Map<String, dynamic>>> listTemplatePlans({
    String? goalType,
    String? level,
  }) async {
    try {
      final token = _tokenStorage.readToken();
      final queryParams = <String, dynamic>{};
      if (goalType != null) queryParams['goal_type'] = goalType;
      if (level != null) queryParams['level'] = level;

      final response = await _dio.get(
        '${ApiEndpoints.baseUrl}/admin/plans',
        queryParameters: queryParams.isEmpty ? null : queryParams,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      return (response.data['plans'] as List)
          .map((e) => e as Map<String, dynamic>)
          .toList();
    } on DioException catch (e) {
      throw Exception('Lỗi lấy danh sách template plans: ${e.message}');
    }
  }

  // Get template plan detail
  Future<Map<String, dynamic>> getTemplatePlanDetail({
    required int mealPlanId,
    required int workoutPlanId,
  }) async {
    try {
      final token = _tokenStorage.readToken();
      final response = await _dio.get(
        '${ApiEndpoints.baseUrl}/admin/plans/$mealPlanId/$workoutPlanId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception('Lỗi lấy chi tiết template plan: ${e.message}');
    }
  }

  // Update template plan
  Future<void> updateTemplatePlan({
    required int mealPlanId,
    required int workoutPlanId,
    String? name,
    String? description,
    int? targetCalories,
    String? level,
  }) async {
    try {
      final token = _tokenStorage.readToken();
      await _dio.put(
        '${ApiEndpoints.baseUrl}/admin/plans/$mealPlanId/$workoutPlanId',
        data: {
          if (name != null) 'name': name,
          if (description != null) 'description': description,
          if (targetCalories != null) 'target_calories': targetCalories,
          if (level != null) 'level': level,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } on DioException catch (e) {
      throw Exception('Lỗi cập nhật template plan: ${e.message}');
    }
  }

  // Delete template plan
  Future<void> deleteTemplatePlan({
    required int mealPlanId,
    required int workoutPlanId,
  }) async {
    try {
      final token = _tokenStorage.readToken();
      final response = await _dio.delete(
        '${ApiEndpoints.baseUrl}/admin/plans/$mealPlanId/$workoutPlanId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      return response.data;
    } on DioException catch (e) {
      String errorMessage = 'Lỗi xóa template plan';
      if (e.response != null) {
        final errorData = e.response?.data;
        if (errorData is Map && errorData['error'] != null) {
          errorMessage = errorData['error'] as String;
        } else if (errorData is Map && errorData['message'] != null) {
          errorMessage = errorData['message'] as String;
        } else {
          errorMessage = '${e.response?.statusCode}: ${e.message}';
        }
      } else {
        errorMessage = e.message ?? 'Lỗi kết nối';
      }
      throw Exception(errorMessage);
    }
  }

  // ========== MEAL PLAN FOODS ==========
  // Add food to meal plan
  Future<Map<String, dynamic>> addFoodToMealPlan({
    required int mealPlanId,
    required int foodId,
    required String dayOfWeek,
    required String mealSession,
    required int sizeGram,
  }) async {
    try {
      final token = _tokenStorage.readToken();
      final response = await _dio.post(
        '${ApiEndpoints.baseUrl}/admin/plans/$mealPlanId/foods',
        data: {
          'food_id': foodId,
          'day_of_week': dayOfWeek,
          'meal_session': mealSession,
          'size_gram': sizeGram,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception('Lỗi thêm món ăn: ${e.message}');
    }
  }

  // Update food in meal plan
  Future<Map<String, dynamic>> updateFoodInMealPlan({
    required int mealPlanId,
    required int foodId,
    int? sizeGram,
    String? dayOfWeek,
    String? mealSession,
  }) async {
    try {
      final token = _tokenStorage.readToken();
      final response = await _dio.put(
        '${ApiEndpoints.baseUrl}/admin/plans/$mealPlanId/foods/$foodId',
        data: {
          if (sizeGram != null) 'size_gram': sizeGram,
          if (dayOfWeek != null) 'day_of_week': dayOfWeek,
          if (mealSession != null) 'meal_session': mealSession,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception('Lỗi cập nhật món ăn: ${e.message}');
    }
  }

  // Delete food from meal plan
  Future<void> deleteFoodFromMealPlan({
    required int mealPlanId,
    required int foodId,
  }) async {
    try {
      final token = _tokenStorage.readToken();
      final response = await _dio.delete(
        '${ApiEndpoints.baseUrl}/admin/plans/$mealPlanId/foods/$foodId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      return response.data;
    } on DioException catch (e) {
      String errorMessage = 'Lỗi xóa món ăn';
      if (e.response != null) {
        final errorData = e.response?.data;
        if (errorData is Map && errorData['error'] != null) {
          errorMessage = errorData['error'] as String;
        } else if (errorData is Map && errorData['message'] != null) {
          errorMessage = errorData['message'] as String;
        } else {
          errorMessage = '${e.response?.statusCode}: ${e.message}';
        }
      } else {
        errorMessage = e.message ?? 'Lỗi kết nối';
      }
      throw Exception(errorMessage);
    }
  }

  // ========== WORKOUT PLAN EXERCISES ==========
  // Add exercise to workout plan
  Future<Map<String, dynamic>> addExerciseToWorkoutPlan({
    required int workoutPlanId,
    required int exerciseId,
    required String dayOfWeek,
    int? sets,
    int? reps,
    int? durationMin,
    int? orderIndex,
  }) async {
    try {
      final token = _tokenStorage.readToken();
      final response = await _dio.post(
        '${ApiEndpoints.baseUrl}/admin/plans/$workoutPlanId/exercises',
        data: {
          'exercise_id': exerciseId,
          'day_of_week': dayOfWeek,
          if (sets != null) 'sets': sets,
          if (reps != null) 'reps': reps,
          if (durationMin != null) 'duration_min': durationMin,
          if (orderIndex != null) 'order_index': orderIndex,
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

  // Update exercise in workout plan
  Future<Map<String, dynamic>> updateExerciseInWorkoutPlan({
    required int workoutPlanId,
    required int exerciseId,
    int? sets,
    int? reps,
    int? durationMin,
    String? dayOfWeek,
    int? orderIndex,
  }) async {
    try {
      final token = _tokenStorage.readToken();
      final response = await _dio.put(
        '${ApiEndpoints.baseUrl}/admin/plans/$workoutPlanId/exercises/$exerciseId',
        data: {
          if (sets != null) 'sets': sets,
          if (reps != null) 'reps': reps,
          if (durationMin != null) 'duration_min': durationMin,
          if (dayOfWeek != null) 'day_of_week': dayOfWeek,
          if (orderIndex != null) 'order_index': orderIndex,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception('Lỗi cập nhật bài tập: ${e.message}');
    }
  }

  // Delete exercise from workout plan
  Future<void> deleteExerciseFromWorkoutPlan({
    required int workoutPlanId,
    required int exerciseId,
  }) async {
    try {
      final token = _tokenStorage.readToken();
      final response = await _dio.delete(
        '${ApiEndpoints.baseUrl}/admin/plans/$workoutPlanId/exercises/$exerciseId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      return response.data;
    } on DioException catch (e) {
      String errorMessage = 'Lỗi xóa bài tập';
      if (e.response != null) {
        final errorData = e.response?.data;
        if (errorData is Map && errorData['error'] != null) {
          errorMessage = errorData['error'] as String;
        } else if (errorData is Map && errorData['message'] != null) {
          errorMessage = errorData['message'] as String;
        } else {
          errorMessage = '${e.response?.statusCode}: ${e.message}';
        }
      } else {
        errorMessage = e.message ?? 'Lỗi kết nối';
      }
      throw Exception(errorMessage);
    }
  }
}
