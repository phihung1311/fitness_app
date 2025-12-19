import '../../../domain/entities/food.dart';
import '../../../domain/repositories/admin/admin_food_repository.dart';
import '../../datasources/remote/admin/admin_food_api.dart';

/// Repository implementation cho Admin quản lý món ăn
/// Tách biệt hoàn toàn với FoodRepositoryImpl của User
class AdminFoodRepositoryImpl implements AdminFoodRepository {
  final AdminFoodApi _api;

  AdminFoodRepositoryImpl(this._api);

  @override
  Future<List<Food>> getFoods() async {
    try {
      final dtos = await _api.getFoods();
      return dtos.map((dto) => dto.toEntity()).whereType<Food>().toList();
    } catch (e) {
      throw Exception('Lỗi lấy danh sách món ăn: $e');
    }
  }

  @override
  Future<Food> addFood({
    required String name,
    required int calories100g,
    required int protein,
    required int carbs,
    required int fat,
    required String mealType,
    String? imagePath,
  }) async {
    try {
      final dto = await _api.addFood(
        name: name,
        calories100g: calories100g,
        protein: protein,
        carbs: carbs,
        fat: fat,
        mealType: mealType,
        imagePath: imagePath,
      );
      return dto.toEntity();
    } catch (e) {
      throw Exception('Lỗi thêm món ăn: $e');
    }
  }

  @override
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
      await _api.updateFood(
        foodId: foodId,
        name: name,
        calories100g: calories100g,
        protein: protein,
        carbs: carbs,
        fat: fat,
        mealType: mealType,
        imagePath: imagePath,
      );
    } catch (e) {
      throw Exception('Lỗi cập nhật món ăn: $e');
    }
  }

  @override
  Future<void> deleteFood(int foodId) async {
    try {
      await _api.deleteFood(foodId);
    } catch (e) {
      throw Exception('Lỗi xóa món ăn: $e');
    }
  }
}

