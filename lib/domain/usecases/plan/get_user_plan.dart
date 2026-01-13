import '../../../domain/entities/user_plan.dart';
import '../../../domain/repositories/plan_repository.dart';

class GetUserPlan {
  final PlanRepository _repository;

  GetUserPlan(this._repository);

  Future<UserPlan?> call() async {
    return await _repository.getUserPlan();
  }
}
