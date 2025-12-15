class ProfileMetricsDto {
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

  ProfileMetricsDto({
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

  factory ProfileMetricsDto.fromJson(Map<String, dynamic> json) {
    return ProfileMetricsDto(
      name: json['name'] as String?,
      weight: json['weight']?.toDouble(),
      height: json['height']?.toDouble(),
      bmi: json['bmi']?.toDouble(),
      tdee: json['tdee']?.toInt(),
      bmr: json['bmr']?.toInt(),
      calorieGoal: json['calorie_goal']?.toInt(),
      weightGoal: json['weight_goal']?.toDouble(),
      goalType: json['goal_type'] as String?,
      activityLevel: json['activity_level'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'weight': weight,
      'height': height,
      'bmi': bmi,
      'tdee': tdee,
      'bmr': bmr,
      'calorie_goal': calorieGoal,
      'weight_goal': weightGoal,
      'goal_type': goalType,
      'activity_level': activityLevel,
    };
  }
}

