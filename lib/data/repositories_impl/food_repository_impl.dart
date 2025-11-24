import '../../domain/entities/food.dart';
import '../../domain/repositories/food_repository.dart';
import '../datasources/remote/meal_api.dart';

class FoodRepositoryImpl implements FoodRepository {
  final MealApi _mealApi;

  FoodRepositoryImpl(this._mealApi);

  @override
  Future<List<Food>> getAllFoods() async {
    try {
      final dtos = await _mealApi.getAllFoods();
      return dtos.map((dto) => dto.toEntity()).toList();
    } catch (e) {
      throw Exception('Lỗi lấy danh sách món ăn: $e');
    }
  }
}

