import 'package:equatable/equatable.dart';
import '../../../../../domain/entities/calories_stats.dart';
import '../../../../../domain/entities/weight_prediction.dart';

class StatisticsState extends Equatable {
  final CaloriesStats? caloriesStats;
  final WeightPrediction? weightPrediction;
  final String selectedPeriod; // 'week' hoặc 'month'
  final bool isLoading;
  final bool isLoadingCalories;
  final bool isLoadingPrediction;
  final String? errorMessage;

  const StatisticsState({
    this.caloriesStats,
    this.weightPrediction,
    this.selectedPeriod = 'week',
    this.isLoading = false,
    this.isLoadingCalories = false,
    this.isLoadingPrediction = false,
    this.errorMessage,
  });

  StatisticsState copyWith({
    CaloriesStats? caloriesStats,
    WeightPrediction? weightPrediction,
    String? selectedPeriod,
    bool? isLoading,
    bool? isLoadingCalories,
    bool? isLoadingPrediction,
    String? errorMessage,
  }) {
    return StatisticsState(
      caloriesStats: caloriesStats ?? this.caloriesStats,
      weightPrediction: weightPrediction ?? this.weightPrediction,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      isLoading: isLoading ?? this.isLoading,
      isLoadingCalories: isLoadingCalories ?? this.isLoadingCalories,
      isLoadingPrediction: isLoadingPrediction ?? this.isLoadingPrediction,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        caloriesStats,
        weightPrediction,
        selectedPeriod,
        isLoading,
        isLoadingCalories,
        isLoadingPrediction,
        errorMessage,
      ];
}

