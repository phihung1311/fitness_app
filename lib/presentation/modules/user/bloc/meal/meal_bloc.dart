import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../domain/entities/user_meal.dart';
import '../../../../../domain/usecases/meal/add_meal.dart';
import '../../../../../domain/usecases/meal/get_today_meals.dart';
import '../../../../../domain/usecases/meal/update_meal.dart';
import '../../../../../domain/usecases/meal/delete_meal.dart';
import 'meal_event.dart';
import 'meal_state.dart';

class MealBloc extends Bloc<MealEvent, MealState> {
  final AddMeal _addMeal;
  final GetTodayMeals _getTodayMeals;
  final UpdateMeal _updateMeal;
  final DeleteMeal _deleteMeal;

  MealBloc(
    this._addMeal,
    this._getTodayMeals,
    this._updateMeal,
    this._deleteMeal,
  ) : super(const MealState()) {
    on<AddMealEvent>(_onAddMeal);
    on<LoadTodayMeals>(_onLoadTodayMeals);
    on<UpdateMealEvent>(_onUpdateMeal);
    on<DeleteMealEvent>(_onDeleteMeal);
  }

  Future<void> _onAddMeal(
    AddMealEvent event,
    Emitter<MealState> emit,
  ) async {
    emit(state.copyWith(isAdding: true, errorMessage: null, successMessage: null));
    try {
      await _addMeal(
        foodId: event.foodId,
        mealSession: event.mealSession,
        weightGrams: event.weightGrams,
      );
      
      // Reload today meals after adding
      add(LoadTodayMeals());
      
      emit(state.copyWith(
        isAdding: false,
        successMessage: 'Đã thêm món ăn thành công!',
      ));
    } catch (e) {
      emit(state.copyWith(
        isAdding: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadTodayMeals(
    LoadTodayMeals event,
    Emitter<MealState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final data = await _getTodayMeals();
      
      // Repository đã trả về đúng type rồi, chỉ cần cast thẳng
      final meals = data['meals'] as Map<String, List<UserMeal>>?;
      final totalCalories = data['total_calories'] as int? ?? 0;
      
      emit(state.copyWith(
        todayMeals: meals,
        totalCalories: totalCalories,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateMeal(
    UpdateMealEvent event,
    Emitter<MealState> emit,
  ) async {
    emit(state.copyWith(isUpdating: true, errorMessage: null, successMessage: null));
    try {
      await _updateMeal(mealId: event.mealId, weightGrams: event.weightGrams);
      add(LoadTodayMeals());
      emit(state.copyWith(
        isUpdating: false,
        successMessage: 'Đã cập nhật món ăn',
      ));
    } catch (e) {
      emit(state.copyWith(
        isUpdating: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDeleteMeal(
    DeleteMealEvent event,
    Emitter<MealState> emit,
  ) async {
    emit(state.copyWith(isUpdating: true, errorMessage: null, successMessage: null));
    try {
      await _deleteMeal(event.mealId);
      add(LoadTodayMeals());
      emit(state.copyWith(
        isUpdating: false,
        successMessage: 'Đã xóa món ăn',
      ));
    } catch (e) {
      emit(state.copyWith(
        isUpdating: false,
        errorMessage: e.toString(),
      ));
    }
  }
}

