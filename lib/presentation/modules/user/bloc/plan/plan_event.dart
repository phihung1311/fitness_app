import 'package:equatable/equatable.dart';

abstract class PlanEvent extends Equatable {
  const PlanEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserPlan extends PlanEvent {
  const LoadUserPlan();
}

class LoadPlanDetails extends PlanEvent {
  final String? dayOfWeek;
  const LoadPlanDetails({this.dayOfWeek});
  
  @override
  List<Object?> get props => [dayOfWeek];
}
