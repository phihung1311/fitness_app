import '../../domain/entities/user_plan.dart';

abstract class PlanRepository {
  Future<UserPlan?> getUserPlan();
}
