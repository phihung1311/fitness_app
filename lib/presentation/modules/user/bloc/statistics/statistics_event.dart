import 'package:equatable/equatable.dart';

abstract class StatisticsEvent extends Equatable {
  const StatisticsEvent();

  @override
  List<Object?> get props => [];
}

class LoadCaloriesStats extends StatisticsEvent {
  final String period; // 'week' hoặc 'month'
  final String? startDate;
  final String? endDate;

  const LoadCaloriesStats({
    required this.period,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [period, startDate, endDate];
}

class LoadWeightPrediction extends StatisticsEvent {
  const LoadWeightPrediction();
}

class ChangePeriod extends StatisticsEvent {
  final String period; // 'week' hoặc 'month'

  const ChangePeriod(this.period);

  @override
  List<Object?> get props => [period];
}

