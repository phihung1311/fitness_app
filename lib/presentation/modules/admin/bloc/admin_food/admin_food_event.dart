import 'package:equatable/equatable.dart';

/// Events cho AdminFoodBloc
/// Tách biệt hoàn toàn với MealEvent của User
abstract class AdminFoodEvent extends Equatable {
  const AdminFoodEvent();

  @override
  List<Object?> get props => [];
}

/// Load danh sách món ăn
class LoadFoods extends AdminFoodEvent {
  const LoadFoods();
}

/// Thêm món ăn mới
class AddFoodEvent extends AdminFoodEvent {
  final String name;
  final int calories100g;
  final int protein;
  final int carbs;
  final int fat;
  final String mealType;
  final String? imagePath;

  const AddFoodEvent({
    required this.name,
    required this.calories100g,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.mealType,
    this.imagePath,
  });

  @override
  List<Object?> get props => [
        name,
        calories100g,
        protein,
        carbs,
        fat,
        mealType,
        imagePath,
      ];
}

/// Cập nhật món ăn
class UpdateFoodEvent extends AdminFoodEvent {
  final int foodId;
  final String? name;
  final int? calories100g;
  final int? protein;
  final int? carbs;
  final int? fat;
  final String? mealType;
  final String? imagePath;

  const UpdateFoodEvent({
    required this.foodId,
    this.name,
    this.calories100g,
    this.protein,
    this.carbs,
    this.fat,
    this.mealType,
    this.imagePath,
  });

  @override
  List<Object?> get props => [
        foodId,
        name,
        calories100g,
        protein,
        carbs,
        fat,
        mealType,
        imagePath,
      ];
}

/// Xóa món ăn
class DeleteFoodEvent extends AdminFoodEvent {
  final int foodId;

  const DeleteFoodEvent(this.foodId);

  @override
  List<Object?> get props => [foodId];
}

/// Tìm kiếm món ăn
class SearchFoodsEvent extends AdminFoodEvent {
  final String query;

  const SearchFoodsEvent(this.query);

  @override
  List<Object?> get props => [query];
}

/// Lọc món ăn theo loại bữa ăn
class FilterFoodsByMealTypeEvent extends AdminFoodEvent {
  final String? mealType;

  const FilterFoodsByMealTypeEvent(this.mealType);

  @override
  List<Object?> get props => [mealType];
}

