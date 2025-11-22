import 'package:equatable/equatable.dart';
import '../../../../../domain/entities/profile_metrics.dart';

class ProfileMetricsState extends Equatable {
  final ProfileMetrics? metrics;
  final bool isLoading;
  final String? errorMessage;

  const ProfileMetricsState({
    this.metrics,
    this.isLoading = false,
    this.errorMessage,
  });

  ProfileMetricsState copyWith({
    ProfileMetrics? metrics,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ProfileMetricsState(
      metrics: metrics ?? this.metrics,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [metrics, isLoading, errorMessage];
}

