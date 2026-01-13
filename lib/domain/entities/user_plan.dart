class UserPlan {
  final int id;
  final int userId;
  final int? mealPlanId;
  final int? workoutPlanId;
  final String startDate;
  final String endDate;
  final double? targetWeightChange;
  final String status;
  final int? createdBy;
  final String? mealPlanName;
  final String? workoutPlanName;

  const UserPlan({
    required this.id,
    required this.userId,
    this.mealPlanId,
    this.workoutPlanId,
    required this.startDate,
    required this.endDate,
    this.targetWeightChange,
    required this.status,
    this.createdBy,
    this.mealPlanName,
    this.workoutPlanName,
  });
}
