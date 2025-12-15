class CalculateExerciseCalories {
  // Constants
  static const double standardWeight = 70.0; // kg

  static const Map<String, double> intensityMultipliers = {
    'beginner': 0.8,
    'intermediate': 1.0,
    'advanced': 1.2,
  };

  static int calculateCaloriesPerSet({
    required int baseCalories,
    required double userWeight,
    String difficulty = 'intermediate',
  }) {
    if (baseCalories == 0 || userWeight == 0) {
      return baseCalories;
    }

    final double weightFactor = userWeight / standardWeight;
    final double intensityMultiplier = intensityMultipliers[difficulty] ?? 1.0;

    final double adjustedCalories = baseCalories * weightFactor * intensityMultiplier;

    return adjustedCalories.round();
  }

  // Tính tổng calories cho toàn bộ bài tập
  static int calculateTotalCalories({
    required int caloriesPerSet,
    required int sets,
  }) {
    return (caloriesPerSet * sets).round();
  }

  // Tính tổng calories cho workout session
  static int calculateWorkoutTotalCalories({
    required List<Map<String, dynamic>> exercises,
    required double userWeight,
  }) {
    int total = 0;

    for (final exercise in exercises) {
      final baseCalories = exercise['calories_burned'] as int? ?? 0;
      final difficulty = exercise['difficulty'] as String? ?? 'intermediate';
      final sets = exercise['sets'] as int? ?? 1;

      final caloriesPerSet = calculateCaloriesPerSet(
        baseCalories: baseCalories,
        userWeight: userWeight,
        difficulty: difficulty,
      );

      total += calculateTotalCalories(
        caloriesPerSet: caloriesPerSet,
        sets: sets,
      );
    }

    return total;
  }
}

