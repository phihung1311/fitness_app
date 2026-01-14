import 'package:equatable/equatable.dart';

class TemplatePlanState extends Equatable {
  final bool isLoading;
  final bool isLoadingDetail;
  final bool isApplying;
  final String? errorMessage;
  final String? successMessage;
  final List<Map<String, dynamic>>? templatePlans;
  final Map<String, dynamic>? templatePlanDetail;

  const TemplatePlanState({
    this.isLoading = false,
    this.isLoadingDetail = false,
    this.isApplying = false,
    this.errorMessage,
    this.successMessage,
    this.templatePlans,
    this.templatePlanDetail,
  });

  TemplatePlanState copyWith({
    bool? isLoading,
    bool? isLoadingDetail,
    bool? isApplying,
    String? errorMessage,
    String? successMessage,
    List<Map<String, dynamic>>? templatePlans,
    Map<String, dynamic>? templatePlanDetail,
  }) {
    return TemplatePlanState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingDetail: isLoadingDetail ?? this.isLoadingDetail,
      isApplying: isApplying ?? this.isApplying,
      errorMessage: errorMessage,
      successMessage: successMessage,
      templatePlans: templatePlans ?? this.templatePlans,
      templatePlanDetail: templatePlanDetail ?? this.templatePlanDetail,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isLoadingDetail,
        isApplying,
        errorMessage,
        successMessage,
        templatePlans,
        templatePlanDetail,
      ];
}
