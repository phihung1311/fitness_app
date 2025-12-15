import '../../repositories/meal_repository.dart';

class DeleteMeal {
  final MealRepository _repository;
  DeleteMeal(this._repository);

  Future<void> call(int mealId) {
    return _repository.deleteMeal(mealId);
  }
}

