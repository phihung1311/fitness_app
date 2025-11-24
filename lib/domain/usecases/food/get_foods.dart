import '../../entities/food.dart';
import '../../repositories/food_repository.dart';

class GetFoods {
  final FoodRepository _repository;

  GetFoods(this._repository);

  Future<List<Food>> call() async {
    return await _repository.getAllFoods();
  }
}

