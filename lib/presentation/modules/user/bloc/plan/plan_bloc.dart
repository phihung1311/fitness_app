import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/di/injector.dart';
import '../../../../../data/datasources/remote/plan_api.dart';
import '../../../../../domain/usecases/plan/get_user_plan.dart';
import 'plan_event.dart';
import 'plan_state.dart';

class PlanBloc extends Bloc<PlanEvent, PlanState> {
  final GetUserPlan _getUserPlan;
  final PlanApi _planApi = injector<PlanApi>();

  PlanBloc(this._getUserPlan) : super(const PlanState()) {
    on<LoadUserPlan>(_onLoadUserPlan);
    on<LoadPlanDetails>(_onLoadPlanDetails);
  }

  Future<void> _onLoadUserPlan(
    LoadUserPlan event,
    Emitter<PlanState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final plan = await _getUserPlan();
      emit(state.copyWith(
        isLoading: false,
        userPlan: plan,
      ));
      // Tự động load details sau khi load plan
      if (plan != null) {
        add(const LoadPlanDetails());
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onLoadPlanDetails(
    LoadPlanDetails event,
    Emitter<PlanState> emit,
  ) async {
    emit(state.copyWith(isLoadingDetails: true));

    try {
      final details = await _planApi.getPlanDetails(dayOfWeek: event.dayOfWeek);
      emit(state.copyWith(
        isLoadingDetails: false,
        planDetails: details,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingDetails: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }
}
