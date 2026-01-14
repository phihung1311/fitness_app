import 'package:equatable/equatable.dart';

abstract class TemplatePlanEvent extends Equatable {
  const TemplatePlanEvent();

  @override
  List<Object?> get props => [];
}

class LoadTemplatePlans extends TemplatePlanEvent {
  final String? goalType;
  final String? level;
  
  const LoadTemplatePlans({this.goalType, this.level});
  
  @override
  List<Object?> get props => [goalType, level];
}

class LoadTemplatePlanDetail extends TemplatePlanEvent {
  final int mealPlanId;
  final int workoutPlanId;
  
  const LoadTemplatePlanDetail({
    required this.mealPlanId,
    required this.workoutPlanId,
  });
  
  @override
  List<Object?> get props => [mealPlanId, workoutPlanId];
}

class ApplyTemplatePlan extends TemplatePlanEvent {
  final int mealPlanId;
  final int workoutPlanId;
  
  const ApplyTemplatePlan({
    required this.mealPlanId,
    required this.workoutPlanId,
  });
  
  @override
  List<Object?> get props => [mealPlanId, workoutPlanId];
}
