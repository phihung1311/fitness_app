import 'package:equatable/equatable.dart';
import '../../../../../domain/entities/exercise.dart';


class AdminExerciseState extends Equatable {
  final List<Exercise> exercises;
  final List<Exercise> displayedExercises; // Danh sách đã filter/search
  final bool isLoading;
  final bool isSubmitting;
  final String? errorMessage;
  final String? successMessage;
  final String searchQuery;
  final String? selectedMuscleGroup;
  final String? selectedDifficulty;

  const AdminExerciseState({
    this.exercises = const [],
    this.displayedExercises = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.successMessage,
    this.searchQuery = '',
    this.selectedMuscleGroup,
    this.selectedDifficulty,
  });

  AdminExerciseState copyWith({
    List<Exercise>? exercises,
    List<Exercise>? displayedExercises,
    bool? isLoading,
    bool? isSubmitting,
    String? errorMessage,
    String? successMessage,
    String? searchQuery,
    String? selectedMuscleGroup,
    String? selectedDifficulty,
  }) {
    return AdminExerciseState(
      exercises: exercises ?? this.exercises,
      displayedExercises: displayedExercises ?? this.displayedExercises,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
      successMessage: successMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedMuscleGroup: selectedMuscleGroup ?? this.selectedMuscleGroup,
      selectedDifficulty: selectedDifficulty ?? this.selectedDifficulty,
    );
  }

  @override
  List<Object?> get props => [
        exercises,
        displayedExercises,
        isLoading,
        isSubmitting,
        errorMessage,
        successMessage,
        searchQuery,
        selectedMuscleGroup,
        selectedDifficulty,
      ];
}

