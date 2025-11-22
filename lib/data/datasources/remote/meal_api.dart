import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../services/storage/token_storage.dart';

class MealApi {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  MealApi(this._dio, this._tokenStorage);

  Future<int> getTodayCalories() async {
    try {
      final token = _tokenStorage.readToken();
      final response = await _dio.get(
        '${ApiEndpoints.baseUrl}/user/meals/today-calories',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      return (response.data['total_calories'] as num?)?.toInt() ?? 0;
    } on DioException catch (e) {
      throw Exception('Lỗi lấy calo hôm nay: ${e.message}');
    }
  }
}

