import '../../../repositories/admin/admin_food_repository.dart';

class DeleteFood {
  final AdminFoodRepository _repository;

  DeleteFood(this._repository);

  Future<void> call(int foodId) => _repository.deleteFood(foodId);
}

