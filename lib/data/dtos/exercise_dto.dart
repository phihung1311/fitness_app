import '../../domain/entities/exercise.dart';

class ExerciseDto {
  final int id;
  final String name;
  final String? muscle_group;
  final String? difficulty;
  final int? sets;
  final int? reps;
  final int? rest_time_sec;
  final int? calories_burned;
  final String? instructions;
  final String? image_url;

  const ExerciseDto({
    required this.id,
    required this.name,
    this.muscle_group,
    this.difficulty,
    this.sets,
    this.reps,
    this.rest_time_sec,
    this.calories_burned,
    this.instructions,
    this.image_url,
  });

  factory ExerciseDto.fromJson(Map<String, dynamic> json) {
    return ExerciseDto(
      id: json['id'] as int,
      name: json['name'] as String,
      muscle_group: json['muscle_group'] as String?,
      difficulty: json['difficulty'] as String?,
      sets: json['sets'] as int?,
      reps: json['reps'] as int?,
      rest_time_sec: json['rest_time_sec'] as int?,
      calories_burned: json['calories_burned'] as int?,
      instructions: json['instructions'] as String?,
      image_url: json['image_url'] as String?,
    );
  }

  Exercise toEntity() {
    return Exercise(
      id: id,
      name: name,
      muscleGroup: muscle_group,
      difficulty: difficulty,
      sets: sets,
      reps: reps,
      restTimeSec: rest_time_sec,
      caloriesBurned: calories_burned,
      instructions: instructions,
      imageUrl: image_url,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'muscle_group': muscle_group,
      'difficulty': difficulty,
      'sets': sets,
      'reps': reps,
      'rest_time_sec': rest_time_sec,
      'calories_burned': calories_burned,
      'instructions': instructions,
      'image_url': image_url,
    };
  }
}

