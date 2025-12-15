import '../../repositories/meal_repository.dart';

class UpdateMeal {
  final MealRepository _repository;
  UpdateMeal(this._repository);

  Future<void> call({required int mealId, required int weightGrams}) {
    return _repository.updateMeal(mealId: mealId, weightGrams: weightGrams);
  }
}

