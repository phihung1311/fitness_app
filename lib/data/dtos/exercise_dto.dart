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
      id: _parseInt(json['id']) ?? 0,
      name: json['name'] as String? ?? '',
      muscle_group: json['muscle_group'] as String?,
      difficulty: json['difficulty'] as String?,
      sets: _parseInt(json['sets']),
      reps: _parseInt(json['reps']),
      rest_time_sec: _parseInt(json['rest_time_sec']),
      calories_burned: _parseInt(json['calories_burned']),
      instructions: json['instructions'] as String?,
      image_url: json['image_url'] as String?,
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final normalized = value.replaceAll(',', '.').trim();
      final doubleValue = double.tryParse(normalized);
      return doubleValue?.round();
    }
    return null;
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

