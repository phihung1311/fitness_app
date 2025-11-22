import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../services/storage/token_storage.dart';
import '../../dtos/profile_metrics_dto.dart';

class ProfileApi {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  ProfileApi(this._dio, this._tokenStorage);

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
}

