import '../entities/user_meal.dart';

abstract class MealRepository {
  Future<UserMeal> addMeal({
    required int foodId,
    required String mealSession,
    required int weightGrams,
    String? mealDate,
  });

  Future<List<UserMeal>> getMealsByDate(String date);
  Future<Map<String, dynamic>> getTodayMeals();
}

