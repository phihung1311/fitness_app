import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../domain/entities/food.dart';
import '../../../../../domain/usecases/admin/get_foods.dart';
import '../../../../../domain/usecases/admin/add_food.dart';
import '../../../../../domain/usecases/admin/update_food.dart';
import '../../../../../domain/usecases/admin/delete_food.dart';
import 'admin_food_event.dart';
import 'admin_food_state.dart';

class AdminFoodBloc extends Bloc<AdminFoodEvent, AdminFoodState> {
  final GetFoods _getFoods;
  final AddFood _addFood;
  final UpdateFood _updateFood;
  final DeleteFood _deleteFood;

  AdminFoodBloc(
    this._getFoods,
    this._addFood,
    this._updateFood,
    this._deleteFood,
  ) : super(const AdminFoodState()) {
    on<LoadFoods>(_onLoadFoods);
    on<AddFoodEvent>(_onAddFood);
    on<UpdateFoodEvent>(_onUpdateFood);
    on<DeleteFoodEvent>(_onDeleteFood);
    on<SearchFoodsEvent>(_onSearchFoods);
    on<FilterFoodsByMealTypeEvent>(_onFilterFoodsByMealType);
  }

  Future<void> _onLoadFoods(
    LoadFoods event,
    Emitter<AdminFoodState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final foods = await _getFoods();
      emit(state.copyWith(
        foods: foods,
        displayedFoods: foods,
        isLoading: false,
      ));
      // Áp dụng lại filter/search nếu có
      _applyFilters(emit, foods, state.searchQuery, state.selectedMealType);
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  void _applyFilters(
    Emitter<AdminFoodState> emit,
    List<Food> foods,
    String searchQuery,
    String? mealType,
  ) {
    List<Food> filtered = foods;

    // Filter theo meal type
    if (mealType != null && mealType.isNotEmpty) {
      filtered = filtered
          .where((food) => 
              (food.mealType ?? 'all') == mealType || 
              (food.mealType ?? 'all') == 'all')
          .toList();
    }

    // Filter theo search query
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered
          .where((food) => food.name.toLowerCase().contains(query))
          .toList();
    }

    emit(state.copyWith(displayedFoods: filtered));
  }

  void _onSearchFoods(
    SearchFoodsEvent event,
    Emitter<AdminFoodState> emit,
  ) {
    _applyFilters(emit, state.foods, event.query, state.selectedMealType);
    emit(state.copyWith(searchQuery: event.query));
  }

  void _onFilterFoodsByMealType(
    FilterFoodsByMealTypeEvent event,
    Emitter<AdminFoodState> emit,
  ) {
    _applyFilters(emit, state.foods, state.searchQuery, event.mealType);
    emit(state.copyWith(selectedMealType: event.mealType));
  }

  Future<void> _onAddFood(
    AddFoodEvent event,
    Emitter<AdminFoodState> emit,
  ) async {
    // Tránh xử lý nếu đang submit
    if (state.isSubmitting) return;
    
    emit(state.copyWith(isSubmitting: true, errorMessage: null, successMessage: null));
    try {
      await _addFood(
        name: event.name,
        calories100g: event.calories100g,
        protein: event.protein,
        carbs: event.carbs,
        fat: event.fat,
        mealType: event.mealType,
        imagePath: event.imagePath,
      );
      // Reload danh sách trước khi emit success
      final foods = await _getFoods();
      _applyFilters(emit, foods, state.searchQuery, state.selectedMealType);
      emit(state.copyWith(
        foods: foods,
        isSubmitting: false,
        successMessage: 'Đã thêm món ăn thành công!',
      ));
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateFood(
    UpdateFoodEvent event,
    Emitter<AdminFoodState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null, successMessage: null));
    try {
      await _updateFood(
        foodId: event.foodId,
        name: event.name,
        calories100g: event.calories100g,
        protein: event.protein,
        carbs: event.carbs,
        fat: event.fat,
        mealType: event.mealType,
        imagePath: event.imagePath,
      );
      // Reload danh sách
      final foods = await _getFoods();
      _applyFilters(emit, foods, state.searchQuery, state.selectedMealType);
      emit(state.copyWith(
        foods: foods,
        isSubmitting: false,
        successMessage: 'Đã cập nhật món ăn thành công!',
      ));
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDeleteFood(
    DeleteFoodEvent event,
    Emitter<AdminFoodState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null, successMessage: null));
    try {
      await _deleteFood(event.foodId);
      // Reload danh sách
      final foods = await _getFoods();
      _applyFilters(emit, foods, state.searchQuery, state.selectedMealType);
      emit(state.copyWith(
        foods: foods,
        isSubmitting: false,
        successMessage: 'Đã xóa món ăn thành công!',
      ));
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString(),
      ));
    }
  }
}

