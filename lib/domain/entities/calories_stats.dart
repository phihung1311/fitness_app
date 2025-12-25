class CaloriesStats {
  final String period;
  final String startDate;
  final String endDate;
  final List<DailyCaloriesData> dailyData;
  final CaloriesSummary summary;

  CaloriesStats({
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.dailyData,
    required this.summary,
  });
}

class DailyCaloriesData {
  final String date;
  final int caloriesIn;
  final int caloriesOut;
  final int netCalories;

  DailyCaloriesData({
    required this.date,
    required this.caloriesIn,
    required this.caloriesOut,
    required this.netCalories,
  });
}

class CaloriesSummary {
  final int totalCaloriesIn;
  final int totalCaloriesOut;
  final int totalNetCalories;
  final int avgDailyNet;
  final int calorieGoal;
  final int daysCount;

  CaloriesSummary({
    required this.totalCaloriesIn,
    required this.totalCaloriesOut,
    required this.totalNetCalories,
    required this.avgDailyNet,
    required this.calorieGoal,
    required this.daysCount,
  });
}

