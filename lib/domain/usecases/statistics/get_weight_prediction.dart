import '../../entities/weight_prediction.dart';
import '../../repositories/statistics_repository.dart';

class GetWeightPrediction {
  GetWeightPrediction(this._repository);

  final StatisticsRepository _repository;

  Future<WeightPrediction> execute() {
    return _repository.getWeightPrediction();
  }
}

