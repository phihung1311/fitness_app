import '../../entities/user_meal.dart';
import '../../repositories/meal_repository.dart';

class AddMeal {
  final MealRepository _repository;

  AddMeal(this._repository);

  Future<UserMeal> call({
    required int foodId,
    required String mealSession,
    required int weightGrams,
    String? mealDate,
  }) async {
    return await _repository.addMeal(
      foodId: foodId,
      mealSession: mealSession,
      weightGrams: weightGrams,
      mealDate: mealDate,
    );
  }
}

