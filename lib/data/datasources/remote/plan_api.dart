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
}
