import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/di/injector.dart';
import '../../../../../data/datasources/remote/admin/admin_plan_api.dart';
import 'admin_plan_event.dart';
import 'admin_plan_state.dart';

class AdminPlanBloc extends Bloc<AdminPlanEvent, AdminPlanState> {
  final AdminPlanApi _api = injector<AdminPlanApi>();

  AdminPlanBloc() : super(const AdminPlanState()) {
    on<CreateTemplatePlanEvent>(_onCreateTemplatePlan);
    on<LoadTemplatePlansEvent>(_onLoadTemplatePlans);
    on<DeleteTemplatePlanEvent>(_onDeleteTemplatePlan);
    on<LoadTemplatePlanDetailEvent>(_onLoadTemplatePlanDetail);
    on<AddFoodToMealPlanEvent>(_onAddFoodToMealPlan);
    on<UpdateFoodInMealPlanEvent>(_onUpdateFoodInMealPlan);
    on<DeleteFoodFromMealPlanEvent>(_onDeleteFoodFromMealPlan);
    on<AddExerciseToWorkoutPlanEvent>(_onAddExerciseToWorkoutPlan);
    on<UpdateExerciseInWorkoutPlanEvent>(_onUpdateExerciseInWorkoutPlan);
    on<DeleteExerciseFromWorkoutPlanEvent>(_onDeleteExerciseFromWorkoutPlan);
  }

  Future<void> _onCreateTemplatePlan(
    CreateTemplatePlanEvent event,
    Emitter<AdminPlanState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null, successMessage: null));

    try {
      final result = await _api.createTemplatePlan(
        name: event.name,
        description: event.description,
        goalType: event.goalType,
        targetWeightChange: event.targetWeightChange,
        durationDays: event.durationDays,
        level: event.level,
        activityLevel: event.activityLevel,
        targetCalories: event.targetCalories,
      );

      emit(state.copyWith(
        isSubmitting: false,
        successMessage: 'Tạo template plan thành công!',
        createdPlan: result,
      ));
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onLoadTemplatePlans(
    LoadTemplatePlansEvent event,
    Emitter<AdminPlanState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final plans = await _api.listTemplatePlans(
        goalType: event.goalType,
        level: event.level,
      );

      emit(state.copyWith(
        isLoading: false,
        plans: plans,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onDeleteTemplatePlan(
    DeleteTemplatePlanEvent event,
    Emitter<AdminPlanState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null, successMessage: null));

    try {
      await _api.deleteTemplatePlan(
        mealPlanId: event.mealPlanId,
        workoutPlanId: event.workoutPlanId,
      );

      emit(state.copyWith(
        isSubmitting: false,
        successMessage: 'Xóa thành công!',
      ));
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onLoadTemplatePlanDetail(
    LoadTemplatePlanDetailEvent event,
    Emitter<AdminPlanState> emit,
  ) async {
    emit(state.copyWith(isLoadingDetail: true, errorMessage: null));

    try {
      final detail = await _api.getTemplatePlanDetail(
        mealPlanId: event.mealPlanId,
        workoutPlanId: event.workoutPlanId,
      );

      emit(state.copyWith(
        isLoadingDetail: false,
        planDetail: detail,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingDetail: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onAddFoodToMealPlan(
    AddFoodToMealPlanEvent event,
    Emitter<AdminPlanState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null, successMessage: null));

    try {
      await _api.addFoodToMealPlan(
        mealPlanId: event.mealPlanId,
        foodId: event.foodId,
        dayOfWeek: event.dayOfWeek,
        mealSession: event.mealSession,
        sizeGram: event.sizeGram,
      );

      // Reload detail
      if (state.planDetail != null) {
        final mealPlanId = state.planDetail!['meal_plan']?['id'] as int?;
        final workoutPlanId = state.planDetail!['workout_plan']?['id'] as int?;
        if (mealPlanId != null && workoutPlanId != null) {
          add(LoadTemplatePlanDetailEvent(
            mealPlanId: mealPlanId,
            workoutPlanId: workoutPlanId,
          ));
        }
      }

      emit(state.copyWith(
        isSubmitting: false,
        successMessage: 'Thêm món ăn thành công!',
      ));
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onUpdateFoodInMealPlan(
    UpdateFoodInMealPlanEvent event,
    Emitter<AdminPlanState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null, successMessage: null));

    try {
      await _api.updateFoodInMealPlan(
        mealPlanId: event.mealPlanId,
        foodId: event.foodId,
        sizeGram: event.sizeGram,
        dayOfWeek: event.dayOfWeek,
        mealSession: event.mealSession,
      );

      // Reload detail
      if (state.planDetail != null) {
        final mealPlanId = state.planDetail!['meal_plan']?['id'] as int?;
        final workoutPlanId = state.planDetail!['workout_plan']?['id'] as int?;
        if (mealPlanId != null && workoutPlanId != null) {
          add(LoadTemplatePlanDetailEvent(
            mealPlanId: mealPlanId,
            workoutPlanId: workoutPlanId,
          ));
        }
      }

      emit(state.copyWith(
        isSubmitting: false,
        successMessage: 'Cập nhật món ăn thành công!',
      ));
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onDeleteFoodFromMealPlan(
    DeleteFoodFromMealPlanEvent event,
    Emitter<AdminPlanState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null, successMessage: null));

    try {
      await _api.deleteFoodFromMealPlan(
        mealPlanId: event.mealPlanId,
        foodId: event.foodId,
      );

      emit(state.copyWith(
        isSubmitting: false,
        successMessage: 'Xóa món ăn thành công!',
      ));
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onAddExerciseToWorkoutPlan(
    AddExerciseToWorkoutPlanEvent event,
    Emitter<AdminPlanState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null, successMessage: null));

    try {
      await _api.addExerciseToWorkoutPlan(
        workoutPlanId: event.workoutPlanId,
        exerciseId: event.exerciseId,
        dayOfWeek: event.dayOfWeek,
        sets: event.sets,
        reps: event.reps,
        durationMin: event.durationMin,
        orderIndex: event.orderIndex,
      );

      // Reload detail
      if (state.planDetail != null) {
        final mealPlanId = state.planDetail!['meal_plan']?['id'] as int?;
        final workoutPlanId = state.planDetail!['workout_plan']?['id'] as int?;
        if (mealPlanId != null && workoutPlanId != null) {
          add(LoadTemplatePlanDetailEvent(
            mealPlanId: mealPlanId,
            workoutPlanId: workoutPlanId,
          ));
        }
      }

      emit(state.copyWith(
        isSubmitting: false,
        successMessage: 'Thêm bài tập thành công!',
      ));
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onUpdateExerciseInWorkoutPlan(
    UpdateExerciseInWorkoutPlanEvent event,
    Emitter<AdminPlanState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null, successMessage: null));

    try {
      await _api.updateExerciseInWorkoutPlan(
        workoutPlanId: event.workoutPlanId,
        exerciseId: event.exerciseId,
        sets: event.sets,
        reps: event.reps,
        durationMin: event.durationMin,
        dayOfWeek: event.dayOfWeek,
        orderIndex: event.orderIndex,
      );

      // Reload detail
      if (state.planDetail != null) {
        final mealPlanId = state.planDetail!['meal_plan']?['id'] as int?;
        final workoutPlanId = state.planDetail!['workout_plan']?['id'] as int?;
        if (mealPlanId != null && workoutPlanId != null) {
          add(LoadTemplatePlanDetailEvent(
            mealPlanId: mealPlanId,
            workoutPlanId: workoutPlanId,
          ));
        }
      }

      emit(state.copyWith(
        isSubmitting: false,
        successMessage: 'Cập nhật bài tập thành công!',
      ));
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onDeleteExerciseFromWorkoutPlan(
    DeleteExerciseFromWorkoutPlanEvent event,
    Emitter<AdminPlanState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null, successMessage: null));

    try {
      await _api.deleteExerciseFromWorkoutPlan(
        workoutPlanId: event.workoutPlanId,
        exerciseId: event.exerciseId,
      );

      emit(state.copyWith(
        isSubmitting: false,
        successMessage: 'Xóa bài tập thành công!',
      ));
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }
}
