import '../../domain/entities/calories_stats.dart';
import '../../domain/entities/weight_prediction.dart';
import '../../domain/repositories/statistics_repository.dart';
import '../datasources/remote/statistics_api.dart';

class StatisticsRepositoryImpl implements StatisticsRepository {
  final StatisticsApi _api;

  StatisticsRepositoryImpl(this._api);

  @override
  Future<CaloriesStats> getCaloriesStats({
    required String period,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final dto = await _api.getCaloriesStats(
        period: period,
        startDate: startDate,
        endDate: endDate,
      );
      return dto.toEntity();
    } catch (e) {
      throw Exception('Lỗi lấy thống kê calories: $e');
    }
  }

  @override
  Future<WeightPrediction> getWeightPrediction() async {
    try {
      final dto = await _api.getWeightPrediction();
      return dto.toEntity();
    } catch (e) {
      throw Exception('Lỗi lấy dự đoán weight: $e');
    }
  }
}

