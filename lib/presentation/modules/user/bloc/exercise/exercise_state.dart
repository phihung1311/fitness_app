import 'package:equatable/equatable.dart';
import '../../../../../domain/entities/exercise.dart';

class ExerciseState extends Equatable {
  final List<Exercise> exercises;
  final List<Exercise> filteredExercises;
  final bool isLoading;
  final String? errorMessage;
  final String? selectedMuscleGroup;
  final String? selectedDifficulty;
  final String searchQuery;

  const ExerciseState({
    this.exercises = const [],
    this.filteredExercises = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedMuscleGroup,
    this.selectedDifficulty,
    this.searchQuery = '',
  });

  ExerciseState copyWith({
    List<Exercise>? exercises,
    List<Exercise>? filteredExercises,
    bool? isLoading,
    String? errorMessage,
    String? selectedMuscleGroup,
    String? selectedDifficulty,
    String? searchQuery,
  }) {
    return ExerciseState(
      exercises: exercises ?? this.exercises,
      filteredExercises: filteredExercises ?? this.filteredExercises,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      selectedMuscleGroup: selectedMuscleGroup,
      selectedDifficulty: selectedDifficulty,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
        exercises,
        filteredExercises,
        isLoading,
        errorMessage,
        selectedMuscleGroup,
        selectedDifficulty,
        searchQuery,
      ];
}

