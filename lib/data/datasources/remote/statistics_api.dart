import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../services/storage/token_storage.dart';
import '../../dtos/calories_stats_dto.dart';
import '../../dtos/weight_prediction_dto.dart';

class StatisticsApi {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  StatisticsApi(this._dio, this._tokenStorage);

  //lay thong ke tuan/thang
  Future<CaloriesStatsDto> getCaloriesStats({
    required String period,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final token = _tokenStorage.readToken();
      final queryParams = <String, dynamic>{
        'period': period,
      };
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;

      final response = await _dio.get(
        '${ApiEndpoints.baseUrl}/user/stats/calories-stats',
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      return CaloriesStatsDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage = e.response?.data['error'] ??
            e.response?.data['message'] ??
            e.message;
        throw Exception('Lỗi lấy thống kê calories: $errorMessage');
      }
      throw Exception('Lỗi lấy thống kê calories: ${e.message}');
    }
  }

  //du doan weight va thoi gian hoan thanh
  Future<WeightPredictionDto> getWeightPrediction() async {
    try {
      final token = _tokenStorage.readToken();
      final response = await _dio.get(
        '${ApiEndpoints.baseUrl}/user/stats/weight-prediction',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      return WeightPredictionDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage = e.response?.data['error'] ??
            e.response?.data['message'] ??
            e.message;
        throw Exception('Lỗi lấy dự đoán weight: $errorMessage');
      }
      throw Exception('Lỗi lấy dự đoán weight: ${e.message}');
    }
  }
}

