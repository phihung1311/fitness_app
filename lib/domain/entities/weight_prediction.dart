class WeightPrediction {
  final double currentWeight;
  final double goalWeight;
  final String goalType;
  final double weightToChange;
  final double ratePerDay;
  final double ratePerWeek;
  final double ratePerMonth;
  final bool canReachGoal;
  final String? message;
  final int? daysToGoal;
  final int? weeksToGoal;
  final int? monthsToGoal;
  final String? targetDate;
  final FuturePredictions? predictions;
  final String trend; // 'increasing', 'decreasing', 'stable'

  WeightPrediction({
    required this.currentWeight,
    required this.goalWeight,
    required this.goalType,
    required this.weightToChange,
    required this.ratePerDay,
    required this.ratePerWeek,
    required this.ratePerMonth,
    required this.canReachGoal,
    this.message,
    this.daysToGoal,
    this.weeksToGoal,
    this.monthsToGoal,
    this.targetDate,
    this.predictions,
    required this.trend,
  });
}

class FuturePredictions {
  final double in1Week;
  final double in1Month;
  final double in3Months;

  FuturePredictions({
    required this.in1Week,
    required this.in1Month,
    required this.in3Months,
  });
}

