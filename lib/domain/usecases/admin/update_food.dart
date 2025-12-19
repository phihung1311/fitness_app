import '../../repositories/admin/admin_food_repository.dart';

/// UseCase: Cập nhật món ăn (chỉ admin)
class UpdateFood {
  final AdminFoodRepository _repository;

  UpdateFood(this._repository);

  Future<void> call({
    required int foodId,
    String? name,
    int? calories100g,
    int? protein,
    int? carbs,
    int? fat,
    String? mealType,
    String? imagePath,
  }) =>
      _repository.updateFood(
        foodId: foodId,
        name: name,
        calories100g: calories100g,
        protein: protein,
        carbs: carbs,
        fat: fat,
        mealType: mealType,
        imagePath: imagePath,
      );
}

