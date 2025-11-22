class ProfileMetrics {
  final String? name;
  final double? weight;
  final double? height;
  final double? bmi;
  final int? tdee;
  final int? calorieGoal;

  ProfileMetrics({
    this.name,
    this.weight,
    this.height,
    this.bmi,
    this.tdee,
    this.calorieGoal,
  });

  // Helper methods để format hiển thị
  String get weightDisplay => weight != null ? '${weight!.toStringAsFixed(1)} kg' : '--';
  String get heightDisplay => height != null ? '${height!.toStringAsFixed(0)} cm' : '--';
  String get bmiDisplay => bmi != null ? bmi!.toStringAsFixed(1) : '--';
  String get tdeeDisplay => tdee != null ? '$tdee' : '--';
  String get calorieGoalDisplay => calorieGoal != null ? '$calorieGoal' : '--';
}

