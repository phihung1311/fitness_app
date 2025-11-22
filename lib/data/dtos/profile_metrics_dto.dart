class ProfileMetricsDto {
  final String? name;
  final double? weight;
  final double? height;
  final double? bmi;
  final int? tdee;
  final int? calorieGoal;

  ProfileMetricsDto({
    this.name,
    this.weight,
    this.height,
    this.bmi,
    this.tdee,
    this.calorieGoal,
  });

  factory ProfileMetricsDto.fromJson(Map<String, dynamic> json) {
    return ProfileMetricsDto(
      name: json['name'] as String?,
      weight: json['weight']?.toDouble(),
      height: json['height']?.toDouble(),
      bmi: json['bmi']?.toDouble(),
      tdee: json['tdee']?.toInt(),
      calorieGoal: json['calorie_goal']?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'weight': weight,
      'height': height,
      'bmi': bmi,
      'tdee': tdee,
      'calorie_goal': calorieGoal,
    };
  }
}

