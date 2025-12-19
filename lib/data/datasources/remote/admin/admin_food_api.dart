import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../services/storage/token_storage.dart';
import '../../../dtos/food_dto.dart';

/// API client cho Admin quản lý món ăn
/// Tách biệt hoàn toàn với FoodApi của User
class AdminFoodApi {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  AdminFoodApi(this._dio, this._tokenStorage);

  /// Lấy danh sách tất cả món ăn (chỉ admin)
  Future<List<FoodDto>> getFoods() async {
    try {
      final token = _tokenStorage.readToken();
      final response = await _dio.get(
        '${ApiEndpoints.baseUrl}/admin/foods',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      return (response.data as List)
          .map((e) => FoodDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception('Lỗi lấy danh sách món ăn: ${e.message}');
    }
  }

  /// Thêm món ăn mới (chỉ admin)
  Future<FoodDto> addFood({
    required String name,
    required int calories100g,
    required int protein,
    required int carbs,
    required int fat,
    required String mealType,
    String? imagePath,
  }) async {
    try {
      final token = _tokenStorage.readToken();
      final formData = FormData.fromMap({
        'name': name,
        'calories_100g': calories100g,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'meal_type': mealType,
        if (imagePath != null)
          'image': await MultipartFile.fromFile(imagePath),
      });

      final response = await _dio.post(
        '${ApiEndpoints.baseUrl}/admin/foods',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      return FoodDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Lỗi thêm món ăn: ${e.message}');
    }
  }

  /// Cập nhật món ăn (chỉ admin)
  Future<void> updateFood({
    required int foodId,
    String? name,
    int? calories100g,
    int? protein,
    int? carbs,
    int? fat,
    String? mealType,
    String? imagePath,
  }) async {
    try {
      final token = _tokenStorage.readToken();
      final formData = FormData.fromMap({
        if (name != null) 'name': name,
        if (calories100g != null) 'calories_100g': calories100g,
        if (protein != null) 'protein': protein,
        if (carbs != null) 'carbs': carbs,
        if (fat != null) 'fat': fat,
        if (mealType != null) 'meal_type': mealType,
        if (imagePath != null)
          'image': await MultipartFile.fromFile(imagePath),
      });

      await _dio.put(
        '${ApiEndpoints.baseUrl}/admin/foods/$foodId',
        data: formData,
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

  /// Xóa món ăn (chỉ admin)
  Future<void> deleteFood(int foodId) async {
    try {
      final token = _tokenStorage.readToken();
      await _dio.delete(
        '${ApiEndpoints.baseUrl}/admin/foods/$foodId',
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

  /// Upload ảnh riêng (chỉ admin)
  Future<String> uploadImage(String imagePath) async {
    try {
      final token = _tokenStorage.readToken();
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(imagePath),
      });

      final response = await _dio.post(
        '${ApiEndpoints.baseUrl}/admin/foods/upload-image',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      return response.data['image_url'] as String;
    } on DioException catch (e) {
      throw Exception('Lỗi upload ảnh: ${e.message}');
    }
  }
}

