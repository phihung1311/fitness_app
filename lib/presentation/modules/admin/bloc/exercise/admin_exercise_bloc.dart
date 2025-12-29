import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../domain/entities/exercise.dart';
import '../../../../../domain/usecases/admin/exercise/get_exercises.dart';
import '../../../../../domain/usecases/admin/exercise/add_exercise.dart';
import '../../../../../domain/usecases/admin/exercise/update_exercise.dart';
import '../../../../../domain/usecases/admin/exercise/delete_exercise.dart';
import 'admin_exercise_event.dart';
import 'admin_exercise_state.dart';

class AdminExerciseBloc extends Bloc<AdminExerciseEvent, AdminExerciseState> {
  final GetExercises _getExercises;
  final AddExercise _addExercise;
  final UpdateExercise _updateExercise;
  final DeleteExercise _deleteExercise;

  AdminExerciseBloc(
    this._getExercises,
    this._addExercise,
    this._updateExercise,
    this._deleteExercise,
  ) : super(const AdminExerciseState()) {
    on<LoadExercises>(_onLoadExercises);
    on<AddExerciseEvent>(_onAddExercise);
    on<UpdateExerciseEvent>(_onUpdateExercise);
    on<DeleteExerciseEvent>(_onDeleteExercise);
    on<SearchExercisesEvent>(_onSearchExercises);
    on<FilterExercisesByMuscleGroupEvent>(_onFilterExercisesByMuscleGroup);
    on<FilterExercisesByDifficultyEvent>(_onFilterExercisesByDifficulty);
  }

  Future<void> _onLoadExercises(
    LoadExercises event,
    Emitter<AdminExerciseState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final exercises = await _getExercises();
      emit(state.copyWith(
        exercises: exercises,
        displayedExercises: exercises,
        isLoading: false,
      ));
      // Áp dụng lại filter/search nếu có
      _applyFilters(
        emit,
        exercises,
        state.searchQuery,
        state.selectedMuscleGroup,
        state.selectedDifficulty,
      );
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  void _applyFilters(
    Emitter<AdminExerciseState> emit,
    List<Exercise> exercises,
    String searchQuery,
    String? muscleGroup,
    String? difficulty,
  ) {
    List<Exercise> filtered = exercises;

    // Filter theo muscle group
    if (muscleGroup != null && muscleGroup.isNotEmpty) {
      filtered = filtered
          .where((exercise) => exercise.muscleGroup == muscleGroup)
          .toList();
    }

    // Filter theo difficulty
    if (difficulty != null && difficulty.isNotEmpty) {
      filtered = filtered
          .where((exercise) => exercise.difficulty == difficulty)
          .toList();
    }

    // Filter theo search query
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered
          .where((exercise) => exercise.name.toLowerCase().contains(query))
          .toList();
    }

    emit(state.copyWith(displayedExercises: filtered));
  }

  void _onSearchExercises(
    SearchExercisesEvent event,
    Emitter<AdminExerciseState> emit,
  ) {
    _applyFilters(
      emit,
      state.exercises,
      event.query,
      state.selectedMuscleGroup,
      state.selectedDifficulty,
    );
    emit(state.copyWith(searchQuery: event.query));
  }

  void _onFilterExercisesByMuscleGroup(
    FilterExercisesByMuscleGroupEvent event,
    Emitter<AdminExerciseState> emit,
  ) {
    _applyFilters(
      emit,
      state.exercises,
      state.searchQuery,
      event.muscleGroup,
      state.selectedDifficulty,
    );
    emit(state.copyWith(selectedMuscleGroup: event.muscleGroup));
  }

  void _onFilterExercisesByDifficulty(
    FilterExercisesByDifficultyEvent event,
    Emitter<AdminExerciseState> emit,
  ) {
    _applyFilters(
      emit,
      state.exercises,
      state.searchQuery,
      state.selectedMuscleGroup,
      event.difficulty,
    );
    emit(state.copyWith(selectedDifficulty: event.difficulty));
  }

  Future<void> _onAddExercise(
    AddExerciseEvent event,
    Emitter<AdminExerciseState> emit,
  ) async {
    // Tránh xử lý nếu đang submit
    if (state.isSubmitting) return;
    
    emit(state.copyWith(isSubmitting: true, errorMessage: null, successMessage: null));
    try {
      await _addExercise(
        name: event.name,
        muscleGroup: event.muscleGroup,
        difficulty: event.difficulty,
        sets: event.sets,
        reps: event.reps,
        restTimeSec: event.restTimeSec,
        caloriesBurned: event.caloriesBurned,
        instructions: event.instructions,
        imagePath: event.imagePath,
      );
      // Reload danh sách
      final exercises = await _getExercises();
      _applyFilters(
        emit,
        exercises,
        state.searchQuery,
        state.selectedMuscleGroup,
        state.selectedDifficulty,
      );
      emit(state.copyWith(
        exercises: exercises,
        isSubmitting: false,
        successMessage: 'Đã thêm bài tập thành công!',
      ));
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateExercise(
    UpdateExerciseEvent event,
    Emitter<AdminExerciseState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null, successMessage: null));
    try {
      await _updateExercise(
        exerciseId: event.exerciseId,
        name: event.name,
        muscleGroup: event.muscleGroup,
        difficulty: event.difficulty,
        sets: event.sets,
        reps: event.reps,
        restTimeSec: event.restTimeSec,
        caloriesBurned: event.caloriesBurned,
        instructions: event.instructions,
        imagePath: event.imagePath,
      );
      // Reload danh sách
      final exercises = await _getExercises();
      _applyFilters(
        emit,
        exercises,
        state.searchQuery,
        state.selectedMuscleGroup,
        state.selectedDifficulty,
      );
      emit(state.copyWith(
        exercises: exercises,
        isSubmitting: false,
        successMessage: 'Đã cập nhật bài tập thành công!',
      ));
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDeleteExercise(
    DeleteExerciseEvent event,
    Emitter<AdminExerciseState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null, successMessage: null));
    try {
      await _deleteExercise(event.exerciseId);
      // Reload danh sách
      final exercises = await _getExercises();
      _applyFilters(
        emit,
        exercises,
        state.searchQuery,
        state.selectedMuscleGroup,
        state.selectedDifficulty,
      );
      emit(state.copyWith(
        exercises: exercises,
        isSubmitting: false,
        successMessage: 'Đã xóa bài tập thành công!',
      ));
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString(),
      ));
    }
  }
}

