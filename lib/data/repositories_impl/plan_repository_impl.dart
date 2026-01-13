import '../../../domain/entities/user_plan.dart';
import '../../../domain/repositories/plan_repository.dart';
import '../datasources/remote/plan_api.dart';

class PlanRepositoryImpl implements PlanRepository {
  final PlanApi _planApi;

  PlanRepositoryImpl(this._planApi);

  @override
  Future<UserPlan?> getUserPlan() async {
    final dto = await _planApi.getUserPlan();
    return dto?.toEntity();
  }
}
