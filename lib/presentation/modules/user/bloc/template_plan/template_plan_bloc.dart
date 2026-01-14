import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/di/injector.dart';
import '../../../../../data/datasources/remote/plan_api.dart';
import 'template_plan_event.dart';
import 'template_plan_state.dart';

class TemplatePlanBloc extends Bloc<TemplatePlanEvent, TemplatePlanState> {
  final PlanApi _planApi = injector<PlanApi>();

  TemplatePlanBloc() : super(const TemplatePlanState()) {
    on<LoadTemplatePlans>(_onLoadTemplatePlans);
    on<LoadTemplatePlanDetail>(_onLoadTemplatePlanDetail);
    on<ApplyTemplatePlan>(_onApplyTemplatePlan);
  }

  Future<void> _onLoadTemplatePlans(
    LoadTemplatePlans event,
    Emitter<TemplatePlanState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final plans = await _planApi.listTemplatePlans(
        goalType: event.goalType,
        level: event.level,
      );
      emit(state.copyWith(
        isLoading: false,
        templatePlans: plans,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onLoadTemplatePlanDetail(
    LoadTemplatePlanDetail event,
    Emitter<TemplatePlanState> emit,
  ) async {
    emit(state.copyWith(isLoadingDetail: true, errorMessage: null));

    try {
      final detail = await _planApi.getTemplatePlanDetail(
        mealPlanId: event.mealPlanId,
        workoutPlanId: event.workoutPlanId,
      );
      emit(state.copyWith(
        isLoadingDetail: false,
        templatePlanDetail: detail,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingDetail: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onApplyTemplatePlan(
    ApplyTemplatePlan event,
    Emitter<TemplatePlanState> emit,
  ) async {
    emit(state.copyWith(isApplying: true, errorMessage: null, successMessage: null));

    try {
      await _planApi.applyTemplatePlan(
        mealPlanId: event.mealPlanId,
        workoutPlanId: event.workoutPlanId,
      );
      emit(state.copyWith(
        isApplying: false,
        successMessage: 'Áp dụng kế hoạch mẫu thành công!',
      ));
    } catch (e) {
      emit(state.copyWith(
        isApplying: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }
}
