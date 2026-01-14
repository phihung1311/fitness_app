import 'package:equatable/equatable.dart';

class AdminPlanState extends Equatable {
  final List<Map<String, dynamic>> plans;
  final Map<String, dynamic>? planDetail;
  final bool isLoading;
  final bool isLoadingDetail;
  final bool isSubmitting;
  final String? errorMessage;
  final String? successMessage;
  final Map<String, dynamic>? createdPlan;

  const AdminPlanState({
    this.plans = const [],
    this.planDetail,
    this.isLoading = false,
    this.isLoadingDetail = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.successMessage,
    this.createdPlan,
  });

  AdminPlanState copyWith({
    List<Map<String, dynamic>>? plans,
    Map<String, dynamic>? planDetail,
    bool? isLoading,
    bool? isLoadingDetail,
    bool? isSubmitting,
    String? errorMessage,
    String? successMessage,
    Map<String, dynamic>? createdPlan,
  }) {
    return AdminPlanState(
      plans: plans ?? this.plans,
      planDetail: planDetail,
      isLoading: isLoading ?? this.isLoading,
      isLoadingDetail: isLoadingDetail ?? this.isLoadingDetail,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
      successMessage: successMessage,
      createdPlan: createdPlan ?? this.createdPlan,
    );
  }

  @override
  List<Object?> get props => [
        plans,
        planDetail,
        isLoading,
        isLoadingDetail,
        isSubmitting,
        errorMessage,
        successMessage,
        createdPlan,
      ];
}
