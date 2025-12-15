import '../../domain/entities/profile_metrics.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/remote/profile_api.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileApi _profileApi;

  ProfileRepositoryImpl(this._profileApi);

  @override
  Future<ProfileMetrics> getProfileMetrics() async {
    try {
      final dto = await _profileApi.getProfileMetrics();
      return ProfileMetrics(
        name: dto.name,
        weight: dto.weight,
        height: dto.height,
        bmi: dto.bmi,
        tdee: dto.tdee,
        bmr: dto.bmr,
        calorieGoal: dto.calorieGoal,
        weightGoal: dto.weightGoal,
        goalType: dto.goalType,
        activityLevel: dto.activityLevel,
      );
    } catch (e) {
      throw Exception('Lỗi lấy thông tin metrics: $e');
    }
  }
}

