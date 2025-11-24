import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../domain/usecases/exercise/get_exercises.dart';
import 'exercise_event.dart';
import 'exercise_state.dart';

class ExerciseBloc extends Bloc<ExerciseEvent, ExerciseState> {
  final GetExercises _getExercises;

  ExerciseBloc(this._getExercises) : super(const ExerciseState()) {
    on<LoadExercises>(_onLoadExercises);
    on<FilterExercises>(_onFilterExercises);
    on<SearchExercises>(_onSearchExercises);
  }

  Future<void> _onLoadExercises(
    LoadExercises event,
    Emitter<ExerciseState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final exercises = await _getExercises();
      emit(state.copyWith(
        exercises: exercises,
        filteredExercises: exercises,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onFilterExercises(
    FilterExercises event,
    Emitter<ExerciseState> emit,
  ) {
    final filtered = state.exercises.where((exercise) {
      final matchesMuscleGroup = event.muscleGroup == null ||
          exercise.muscleGroup == event.muscleGroup;
      final matchesDifficulty = event.difficulty == null ||
          exercise.difficulty == event.difficulty;
      return matchesMuscleGroup && matchesDifficulty;
    }).toList();

    emit(state.copyWith(
      filteredExercises: filtered,
      selectedMuscleGroup: event.muscleGroup,
      selectedDifficulty: event.difficulty,
    ));
  }

  void _onSearchExercises(
    SearchExercises event,
    Emitter<ExerciseState> emit,
  ) {
    final query = event.query.toLowerCase();
    final filtered = state.exercises.where((exercise) {
      final matchesSearch = exercise.name.toLowerCase().contains(query);
      final matchesMuscleGroup = state.selectedMuscleGroup == null ||
          exercise.muscleGroup == state.selectedMuscleGroup;
      final matchesDifficulty = state.selectedDifficulty == null ||
          exercise.difficulty == state.selectedDifficulty;
      return matchesSearch && matchesMuscleGroup && matchesDifficulty;
    }).toList();

    emit(state.copyWith(
      filteredExercises: filtered,
      searchQuery: query,
    ));
  }
}

