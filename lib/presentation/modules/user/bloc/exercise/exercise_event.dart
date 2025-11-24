import 'package:equatable/equatable.dart';

abstract class ExerciseEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadExercises extends ExerciseEvent {}

class FilterExercises extends ExerciseEvent {
  final String? muscleGroup;
  final String? difficulty;

  FilterExercises({this.muscleGroup, this.difficulty});

  @override
  List<Object?> get props => [muscleGroup, difficulty];
}

class SearchExercises extends ExerciseEvent {
  final String query;

  SearchExercises({required this.query});

  @override
  List<Object?> get props => [query];
}

