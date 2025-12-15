import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../services/storage/token_storage.dart';
import '../../dtos/profile_metrics_dto.dart';

class ProfileApi {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  ProfileApi(this._dio, this._tokenStorage);

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final token = _tokenStorage.readToken();
      final response = await _dio.get(
        '${ApiEndpoints.baseUrl}/user/profile',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception('Lỗi lấy thông tin tài khoản: ${e.message}');
    }
  }

  Future<ProfileMetricsDto> getProfileMetrics() async {
    try {
      final token = _tokenStorage.readToken();
      final response = await _dio.get(
        '${ApiEndpoints.baseUrl}/user/profile/metrics',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      return ProfileMetricsDto.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Lỗi lấy thông tin metrics: ${e.message}');
    }
  }

  Future<void> onboardingProfile({
    required String name,
    required String gender,
    required int age,
    required double height,
    required double weight,
    required double weightGoal,
    required String goalType,
    String activityLevel = 'moderate',
  }) async {
    try {
      final token = _tokenStorage.readToken();
      await _dio.post(
        '${ApiEndpoints.baseUrl}/user/profile/onboarding',
        data: {
          'name': name,
          'gender': gender,
          'age': age,
          'height': height,
          'weight': weight,
          'weight_goal': weightGoal,
          'goal_type': goalType,
          'activity_level': activityLevel,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } on DioException catch (e) {
      throw Exception('Lỗi hoàn tất hồ sơ: ${e.message}');
    }
  }

  Future<void> updateProfile({
    String? name,
    String? gender,
    int? age,
  }) async {
    try {
      final token = _tokenStorage.readToken();
      await _dio.put(
        '${ApiEndpoints.baseUrl}/user/profile',
        data: {
          if (name != null) 'name': name,
          if (gender != null) 'gender': gender,
          if (age != null) 'age': age,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } on DioException catch (e) {
      throw Exception('Lỗi cập nhật thông tin: ${e.message}');
    }
  }
}

