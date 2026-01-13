import '../../domain/entities/user_plan.dart';

class UserPlanDto {
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

  const UserPlanDto({
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

  factory UserPlanDto.fromJson(Map<String, dynamic> json) {
    return UserPlanDto(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      mealPlanId: json['meal_plan_id'] as int?,
      workoutPlanId: json['workout_plan_id'] as int?,
      startDate: json['start_date'] as String,
      endDate: json['end_date'] as String,
      targetWeightChange: json['target_weight_change'] != null
          ? (json['target_weight_change'] as num).toDouble()
          : null,
      status: json['status'] as String,
      createdBy: json['created_by'] as int?,
      mealPlanName: json['meal_plan_name'] as String?,
      workoutPlanName: json['workout_plan_name'] as String?,
    );
  }

  UserPlan toEntity() {
    return UserPlan(
      id: id,
      userId: userId,
      mealPlanId: mealPlanId,
      workoutPlanId: workoutPlanId,
      startDate: startDate,
      endDate: endDate,
      targetWeightChange: targetWeightChange,
      status: status,
      createdBy: createdBy,
      mealPlanName: mealPlanName,
      workoutPlanName: workoutPlanName,
    );
  }
}
