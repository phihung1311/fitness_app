import '../entities/profile_metrics.dart';

abstract class ProfileRepository {
  Future<ProfileMetrics> getProfileMetrics();
}

