import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../services/storage/token_storage.dart';

class ProgressApi {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  ProgressApi(this._dio, this._tokenStorage);

  Future<Map<String, dynamic>> updateProgress({
    required double weight,
    required double height,
    double? bodyFatPercent,
  }) async {
    try {
      final token = _tokenStorage.readToken();
      final response = await _dio.post(
        '${ApiEndpoints.baseUrl}/user/progress',
        data: {
          'weight': weight,
          'height': height,
          if (bodyFatPercent != null) 'body_fat_percent': bodyFatPercent,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception('Lỗi cập nhật cân nặng: ${e.message}');
    }
  }

  Future<List<Map<String, dynamic>>> getProgressHistory() async {
    try {
      final token = _tokenStorage.readToken();
      final response = await _dio.get(
        '${ApiEndpoints.baseUrl}/user/progress',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw Exception('Lỗi lấy lịch sử cân nặng: ${e.message}');
    }
  }
}

