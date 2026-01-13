import 'package:equatable/equatable.dart';
import '../../../../../domain/entities/user_plan.dart';

class PlanState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final UserPlan? userPlan;
  final Map<String, dynamic>? planDetails;
  final bool isLoadingDetails;

  const PlanState({
    this.isLoading = false,
    this.errorMessage,
    this.userPlan,
    this.planDetails,
    this.isLoadingDetails = false,
  });

  PlanState copyWith({
    bool? isLoading,
    String? errorMessage,
    UserPlan? userPlan,
    Map<String, dynamic>? planDetails,
    bool? isLoadingDetails,
  }) {
    return PlanState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      userPlan: userPlan ?? this.userPlan,
      planDetails: planDetails ?? this.planDetails,
      isLoadingDetails: isLoadingDetails ?? this.isLoadingDetails,
    );
  }

  @override
  List<Object?> get props => [isLoading, errorMessage, userPlan, planDetails, isLoadingDetails];
}
