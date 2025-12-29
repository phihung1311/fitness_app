import '../../../entities/food.dart';
import '../../../repositories/admin/admin_food_repository.dart';

class GetFoods {
  final AdminFoodRepository _repository;

  GetFoods(this._repository);

  Future<List<Food>> call() => _repository.getFoods();
}

