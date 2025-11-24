import '../../repositories/meal_repository.dart';

class GetTodayMeals {
  final MealRepository _repository;

  GetTodayMeals(this._repository);

  Future<Map<String, dynamic>> call() async {
    return await _repository.getTodayMeals();
  }
}

