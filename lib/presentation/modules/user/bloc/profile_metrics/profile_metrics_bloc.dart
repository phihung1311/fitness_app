import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../domain/usecases/profile/get_profile_metrics.dart';
import 'profile_metrics_event.dart';
import 'profile_metrics_state.dart';

class ProfileMetricsBloc extends Bloc<ProfileMetricsEvent, ProfileMetricsState> {
  final GetProfileMetrics _getProfileMetrics;

  ProfileMetricsBloc(GetProfileMetrics getProfileMetrics) 
      : _getProfileMetrics = getProfileMetrics,
        super(const ProfileMetricsState()) {
    on<LoadProfileMetrics>(_onLoadProfileMetrics);
  }

  Future<void> _onLoadProfileMetrics(
    LoadProfileMetrics event,
    Emitter<ProfileMetricsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final metrics = await _getProfileMetrics();
      emit(state.copyWith(metrics: metrics, isLoading: false));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }
}

