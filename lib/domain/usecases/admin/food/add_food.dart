import '../../../entities/food.dart';
import '../../../repositories/admin/admin_food_repository.dart';

/// UseCase: Thêm món ăn mới (chỉ admin)
class AddFood {
  final AdminFoodRepository _repository;

  AddFood(this._repository);

  Future<Food> call({
    required String name,
    required int calories100g,
    required int protein,
    required int carbs,
    required int fat,
    required String mealType,
    String? imagePath,
  }) =>
      _repository.addFood(
        name: name,
        calories100g: calories100g,
        protein: protein,
        carbs: carbs,
        fat: fat,
        mealType: mealType,
        imagePath: imagePath,
      );
}

