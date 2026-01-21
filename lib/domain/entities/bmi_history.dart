class BMIHistory {
  final List<DailyBMIData> dailyData;
  final BMISummary summary;

  BMIHistory({
    required this.dailyData,
    required this.summary,
  });
}

class DailyBMIData {
  final String date;
  final double bmi;

  DailyBMIData({
    required this.date,
    required this.bmi,
  });
}

class BMISummary {
  final double? currentBMI;
  final double? averageBMI;
  final double? minBMI;
  final double? maxBMI;

  BMISummary({
    this.currentBMI,
    this.averageBMI,
    this.minBMI,
    this.maxBMI,
  });
}
