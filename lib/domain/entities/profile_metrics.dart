class ProfileMetrics {
  final String? name;
  final double? weight;
  final double? height;
  final double? bmi;
  final int? tdee;
  final int? bmr;
  final int? calorieGoal;
  final double? weightGoal;
  final String? goalType;
  final String? activityLevel;

  ProfileMetrics({
    this.name,
    this.weight,
    this.height,
    this.bmi,
    this.tdee,
    this.bmr,
    this.calorieGoal,
    this.weightGoal,
    this.goalType,
    this.activityLevel,
  });

  // Helper methods để format hiển thị
  String get weightDisplay => weight != null ? '${weight!.toStringAsFixed(1)} kg' : '--';
  String get heightDisplay => height != null ? '${height!.toStringAsFixed(0)} cm' : '--';
  String get bmiDisplay => bmi != null ? bmi!.toStringAsFixed(1) : '--';
  String get tdeeDisplay => tdee != null ? '$tdee' : '--';
  String get bmrDisplay => bmr != null ? '$bmr kcal' : '--';
  String get calorieGoalDisplay => calorieGoal != null ? '$calorieGoal' : '--';
  String get weightGoalDisplay => weightGoal != null ? '${weightGoal!.toStringAsFixed(1)} kg' : '--';
  String get goalTypeDisplay {
    final g = (goalType ?? '').toLowerCase();
    switch (g) {
      case 'lose':
        return 'Giảm cân';
      case 'gain':
        return 'Tăng cân';
      case 'muscle_gain':
        return 'Tăng cơ';
      case 'maintain':
        return 'Duy trì';
      default:
        return '--';
    }
  }
  String get activityLevelDisplay => activityLevel ?? '--';
}

