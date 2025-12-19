import '../../entities/food.dart';
import '../../repositories/admin/admin_food_repository.dart';

/// UseCase: Lấy danh sách món ăn (chỉ admin)
class GetFoods {
  final AdminFoodRepository _repository;

  GetFoods(this._repository);

  Future<List<Food>> call() => _repository.getFoods();
}

