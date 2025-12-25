import '../entities/calories_stats.dart';
import '../entities/weight_prediction.dart';

abstract class StatisticsRepository {
  Future<CaloriesStats> getCaloriesStats({
    required String period, // 'week' hoặc 'month'
    String? startDate,
    String? endDate,
  });

  Future<WeightPrediction> getWeightPrediction();
}

