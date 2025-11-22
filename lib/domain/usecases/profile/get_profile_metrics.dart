import '../../entities/profile_metrics.dart';
import '../../repositories/profile_repository.dart';

class GetProfileMetrics {
  final ProfileRepository _repository;

  GetProfileMetrics(this._repository);

  Future<ProfileMetrics> call() async {
    return await _repository.getProfileMetrics();
  }
}

