import 'package:dio/dio.dart';
import '../../../../services/storage/token_storage.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../dtos/user_plan_dto.dart';

class PlanApi {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  PlanApi(this._dio, this._tokenStorage);

  Future<UserPlanDto?> getUserPlan() async {
    try {
      final token = _tokenStorage.readToken();
      final response = await _dio.get(
        '${ApiEndpoints.baseUrl}/user/plan',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.data == null || response.data.isEmpty) {
        return null;
      }

      return UserPlanDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null; // No plan found
      }
      throw Exception('Lỗi lấy kế hoạch: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> getPlanDetails({String? dayOfWeek}) async {
    try {
      final token = _tokenStorage.readToken();
      final response = await _dio.get(
        '${ApiEndpoints.baseUrl}/user/plan/details',
        queryParameters: dayOfWeek != null ? {'day_of_week': dayOfWeek} : null,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Chưa có kế hoạch');
      }
      throw Exception('Lỗi lấy chi tiết kế hoạch: ${e.message}');
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
        '${ApiEndpoints.baseUrl}/user/plan/templates',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final data = response.data as Map<String, dynamic>;
      final plans = data['plans'] as List<dynamic>? ?? [];
      return plans.map((p) => p as Map<String, dynamic>).toList();
    } on DioException catch (e) {
      throw Exception('Lỗi lấy danh sách kế hoạch mẫu: ${e.message}');
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
        '${ApiEndpoints.baseUrl}/user/plan/templates/$mealPlanId/$workoutPlanId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Kế hoạch mẫu không tìm thấy');
      }
      throw Exception('Lỗi lấy chi tiết kế hoạch mẫu: ${e.message}');
    }
  }

  // Apply template plan
  Future<Map<String, dynamic>> applyTemplatePlan({
    required int mealPlanId,
    required int workoutPlanId,
  }) async {
    try {
      final token = _tokenStorage.readToken();
      final response = await _dio.post(
        '${ApiEndpoints.baseUrl}/user/plan/templates/apply',
        data: {
          'mealPlanId': mealPlanId,
          'workoutPlanId': workoutPlanId,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception('Lỗi áp dụng kế hoạch mẫu: ${e.message}');
    }
  }
}
