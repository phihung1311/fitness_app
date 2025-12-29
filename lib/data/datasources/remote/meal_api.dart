import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../services/storage/token_storage.dart';
import '../../dtos/food_dto.dart';
import '../../dtos/user_meal_dto.dart';

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

  Future<List<FoodDto>> getAllFoods() async {
    try {
      final token = _tokenStorage.readToken();
      final response = await _dio.get(
        '${ApiEndpoints.baseUrl}/user/meals/foods',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      
      final List<dynamic> foodsJson = response.data as List<dynamic>;
      return foodsJson.map((json) => FoodDto.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception('Lỗi lấy danh sách món ăn: ${e.message}');
    }
  }

  // Lấy random foods
  Future<List<FoodDto>> getRandomFoods({int limit = 4}) async {
    try {
      final token = _tokenStorage.readToken();
      final response = await _dio.get(
        '${ApiEndpoints.baseUrl}/user/meals/foods/random',
        queryParameters: {'limit': limit},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      
      final List<dynamic> foodsJson = response.data as List<dynamic>;
      return foodsJson.map((json) => FoodDto.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception('Lỗi lấy món ăn ngẫu nhiên: ${e.message}');
    }
  }

  // Thêm bữa ăn
  Future<UserMealDto> addMeal(AddMealRequest request) async {
    try {
      final token = _tokenStorage.readToken();
      final response = await _dio.post(
        '${ApiEndpoints.baseUrl}/user/meals',
        data: request.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      return UserMealDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Lỗi thêm bữa ăn: ${e.message}');
    }
  }

  // Lấy meals hôm nay
  Future<Map<String, dynamic>> getTodayMeals() async {
    try {
      final token = _tokenStorage.readToken();
      final response = await _dio.get(
        '${ApiEndpoints.baseUrl}/user/meals/today',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception('Lỗi lấy bữa ăn hôm nay: ${e.message}');
    }
  }

  // Lấy meals theo ngày
  Future<List<UserMealDto>> getMealsByDate(String date) async {
    try {
      final token = _tokenStorage.readToken();
      final response = await _dio.get(
        '${ApiEndpoints.baseUrl}/user/meals/my',
        queryParameters: {'date': date},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      
      final List<dynamic> mealsJson = response.data as List<dynamic>;
      return mealsJson.map((json) => UserMealDto.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception('Lỗi lấy lịch sử bữa ăn: ${e.message}');
    }
  }

  Future<void> updateMeal({
    required int mealId,
    required int weightGrams,
  }) async {
    try {
      final token = _tokenStorage.readToken();
      await _dio.put(
        '${ApiEndpoints.baseUrl}/user/meals/$mealId',
        data: {'weight_grams': weightGrams},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } on DioException catch (e) {
      throw Exception('Lỗi cập nhật món ăn: ${e.message}');
    }
  }

  Future<void> deleteMeal(int mealId) async {
    try {
      final token = _tokenStorage.readToken();
      await _dio.delete(
        '${ApiEndpoints.baseUrl}/user/meals/$mealId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } on DioException catch (e) {
      throw Exception('Lỗi xóa món ăn: ${e.message}');
    }
  }
}

