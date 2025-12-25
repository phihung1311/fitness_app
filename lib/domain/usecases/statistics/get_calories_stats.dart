import '../../entities/calories_stats.dart';
import '../../repositories/statistics_repository.dart';

class GetCaloriesStats {
  GetCaloriesStats(this._repository);

  final StatisticsRepository _repository;

  Future<CaloriesStats> execute({
    required String period,
    String? startDate,
    String? endDate,
  }) {
    return _repository.getCaloriesStats(
      period: period,
      startDate: startDate,
      endDate: endDate,
    );
  }
}

