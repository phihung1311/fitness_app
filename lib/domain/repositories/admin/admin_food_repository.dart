import '../../entities/food.dart';

/// Repository interface cho Admin quản lý món ăn
/// Tách biệt hoàn toàn với FoodRepository của User
abstract class AdminFoodRepository {
  Future<List<Food>> getFoods();
  Future<Food> addFood({
    required String name,
    required int calories100g,
    required int protein,
    required int carbs,
    required int fat,
    required String mealType,
    String? imagePath,
  });
  Future<void> updateFood({
    required int foodId,
    String? name,
    int? calories100g,
    int? protein,
    int? carbs,
    int? fat,
    String? mealType,
    String? imagePath,
  });
  Future<void> deleteFood(int foodId);
}

