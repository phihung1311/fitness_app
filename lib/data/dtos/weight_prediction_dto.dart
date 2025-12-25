import '../../domain/entities/weight_prediction.dart';

class WeightPredictionDto {
  final double current_weight;
  final double goal_weight;
  final String goal_type;
  final double weight_to_change;
  final double rate_per_day;
  final double rate_per_week;
  final double rate_per_month;
  final bool can_reach_goal;
  final String? message;
  final int? days_to_goal;
  final int? weeks_to_goal;
  final int? months_to_goal;
  final String? target_date;
  final Map<String, dynamic>? predictions;
  final String trend;

  WeightPredictionDto({
    required this.current_weight,
    required this.goal_weight,
    required this.goal_type,
    required this.weight_to_change,
    required this.rate_per_day,
    required this.rate_per_week,
    required this.rate_per_month,
    required this.can_reach_goal,
    this.message,
    this.days_to_goal,
    this.weeks_to_goal,
    this.months_to_goal,
    this.target_date,
    this.predictions,
    required this.trend,
  });

  factory WeightPredictionDto.fromJson(Map<String, dynamic> json) {
    double _parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) {
        return double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
      }
      return 0.0;
    }

    int? _parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) {
        return int.tryParse(value);
      }
      return null;
    }

    return WeightPredictionDto(
      current_weight: _parseDouble(json['current_weight']),
      goal_weight: _parseDouble(json['goal_weight']),
      goal_type: json['goal_type']?.toString() ?? 'maintain',
      weight_to_change: _parseDouble(json['weight_to_change']),
      rate_per_day: _parseDouble(json['rate_per_day']),
      rate_per_week: _parseDouble(json['rate_per_week']),
      rate_per_month: _parseDouble(json['rate_per_month']),
      can_reach_goal: json['can_reach_goal'] == true,
      message: json['message']?.toString(),
      days_to_goal: _parseInt(json['days_to_goal']),
      weeks_to_goal: _parseInt(json['weeks_to_goal']),
      months_to_goal: _parseInt(json['months_to_goal']),
      target_date: json['target_date']?.toString(),
      predictions: json['predictions'] as Map<String, dynamic>?,
      trend: json['trend']?.toString() ?? 'stable',
    );
  }

  WeightPrediction toEntity() {
    FuturePredictions? futurePredictions;
    if (predictions != null) {
      double _parseDouble(dynamic value) {
        if (value == null) return 0.0;
        if (value is num) return value.toDouble();
        if (value is String) {
          return double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
        }
        return 0.0;
      }

      futurePredictions = FuturePredictions(
        in1Week: _parseDouble(predictions!['in_1_week']),
        in1Month: _parseDouble(predictions!['in_1_month']),
        in3Months: _parseDouble(predictions!['in_3_months']),
      );
    }

    return WeightPrediction(
      currentWeight: current_weight,
      goalWeight: goal_weight,
      goalType: goal_type,
      weightToChange: weight_to_change,
      ratePerDay: rate_per_day,
      ratePerWeek: rate_per_week,
      ratePerMonth: rate_per_month,
      canReachGoal: can_reach_goal,
      message: message,
      daysToGoal: days_to_goal,
      weeksToGoal: weeks_to_goal,
      monthsToGoal: months_to_goal,
      targetDate: target_date,
      predictions: futurePredictions,
      trend: trend,
    );
  }
}

