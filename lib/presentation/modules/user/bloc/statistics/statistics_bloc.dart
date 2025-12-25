import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../domain/usecases/statistics/get_calories_stats.dart';
import '../../../../../domain/usecases/statistics/get_weight_prediction.dart';
import 'statistics_event.dart';
import 'statistics_state.dart';

class StatisticsBloc extends Bloc<StatisticsEvent, StatisticsState> {
  final GetCaloriesStats _getCaloriesStats;
  final GetWeightPrediction _getWeightPrediction;

  StatisticsBloc(
    this._getCaloriesStats,
    this._getWeightPrediction,
  ) : super(const StatisticsState()) {
    on<LoadCaloriesStats>(_onLoadCaloriesStats);
    on<LoadWeightPrediction>(_onLoadWeightPrediction);
    on<ChangePeriod>(_onChangePeriod);
  }

  Future<void> _onLoadCaloriesStats(
    LoadCaloriesStats event,
    Emitter<StatisticsState> emit,
  ) async {
    emit(state.copyWith(isLoadingCalories: true, errorMessage: null));
    try {
      final stats = await _getCaloriesStats.execute(
        period: event.period,
        startDate: event.startDate,
        endDate: event.endDate,
      );
      emit(state.copyWith(
        caloriesStats: stats,
        isLoadingCalories: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingCalories: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadWeightPrediction(
    LoadWeightPrediction event,
    Emitter<StatisticsState> emit,
  ) async {
    emit(state.copyWith(isLoadingPrediction: true, errorMessage: null));
    try {
      final prediction = await _getWeightPrediction.execute();
      emit(state.copyWith(
        weightPrediction: prediction,
        isLoadingPrediction: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingPrediction: false,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onChangePeriod(
    ChangePeriod event,
    Emitter<StatisticsState> emit,
  ) {
    emit(state.copyWith(selectedPeriod: event.period));
    // Tự động reload data với period mới
    add(LoadCaloriesStats(period: event.period));
  }
}

