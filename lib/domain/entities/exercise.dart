import 'package:equatable/equatable.dart';

class Exercise extends Equatable {
  final int id;
  final String name;
  final String? muscleGroup;
  final String? difficulty; // beginner, intermediate, advanced
  final int? sets;
  final int? reps;
  final int? restTimeSec;
  final int? caloriesBurned; // per set
  final String? instructions;
  final String? imageUrl;

  const Exercise({
    required this.id,
    required this.name,
    this.muscleGroup,
    this.difficulty,
    this.sets,
    this.reps,
    this.restTimeSec,
    this.caloriesBurned,
    this.instructions,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        muscleGroup,
        difficulty,
        sets,
        reps,
        restTimeSec,
        caloriesBurned,
        instructions,
        imageUrl,
      ];
}

