import '../../domain/entities/user_meal.dart';
import '../../domain/repositories/meal_repository.dart';
import '../datasources/remote/meal_api.dart';
import '../dtos/user_meal_dto.dart';

class MealRepositoryImpl implements MealRepository {
  final MealApi _mealApi;

  MealRepositoryImpl(this._mealApi);

  @override
  Future<UserMeal> addMeal({
    required int foodId,
    required String mealSession,
    required int weightGrams,
    String? mealDate,
  }) async {
    try {
      final request = AddMealRequest(
        foodId: foodId,
        mealSession: mealSession,
        weightGrams: weightGrams,
        mealDate: mealDate,
      );
      final dto = await _mealApi.addMeal(request);
      return dto.toEntity();
    } catch (e) {
      throw Exception('Lỗi thêm bữa ăn: $e');
    }
  }

  @override
  Future<List<UserMeal>> getMealsByDate(String date) async {
    try {
      final dtos = await _mealApi.getMealsByDate(date);
      return dtos.map((dto) => dto.toEntity()).toList();
    } catch (e) {
      throw Exception('Lỗi lấy lịch sử bữa ăn: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getTodayMeals() async {
    try {
      final data = await _mealApi.getTodayMeals();
      
      // Parse meals
      final Map<String, List<UserMeal>> meals = {};
      if (data['meals'] != null) {
        final mealsData = data['meals'] as Map<String, dynamic>;
        mealsData.forEach((key, value) {
          if (value is List) {
            meals[key] = value
                .map((json) => UserMealDto.fromJson(json as Map<String, dynamic>).toEntity())
                .toList();
          }
        });
      }
      
      return {
        'date': data['date'],
        'total_calories': data['total_calories'],
        'meals': meals,
      };
    } catch (e) {
      throw Exception('Lỗi lấy bữa ăn hôm nay: $e');
    }
  }
}

