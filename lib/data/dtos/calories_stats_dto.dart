import '../../domain/entities/calories_stats.dart';

class CaloriesStatsDto {
  final String period;
  final String start_date;
  final String end_date;
  final List<Map<String, dynamic>> daily_data;
  final Map<String, dynamic> summary;

  CaloriesStatsDto({
    required this.period,
    required this.start_date,
    required this.end_date,
    required this.daily_data,
    required this.summary,
  });

  factory CaloriesStatsDto.fromJson(Map<String, dynamic> json) {
    return CaloriesStatsDto(
      period: json['period']?.toString() ?? 'week',
      start_date: json['start_date']?.toString() ?? '',
      end_date: json['end_date']?.toString() ?? '',
      daily_data: (json['daily_data'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
      summary: json['summary'] as Map<String, dynamic>? ?? {},
    );
  }

  CaloriesStats toEntity() {
    return CaloriesStats(
      period: period,
      startDate: start_date,
      endDate: end_date,
      dailyData: daily_data.map((d) => DailyCaloriesData(
            date: d['date']?.toString() ?? '',
            caloriesIn: d['calories_in'] is int
                ? d['calories_in'] as int
                : int.tryParse(d['calories_in']?.toString() ?? '0') ?? 0,
            caloriesOut: d['calories_out'] is int
                ? d['calories_out'] as int
                : int.tryParse(d['calories_out']?.toString() ?? '0') ?? 0,
            netCalories: d['net_calories'] is int
                ? d['net_calories'] as int
                : int.tryParse(d['net_calories']?.toString() ?? '0') ?? 0,
          )).toList(),
      summary: CaloriesSummary(
        totalCaloriesIn: summary['total_calories_in'] is int
            ? summary['total_calories_in'] as int
            : int.tryParse(summary['total_calories_in']?.toString() ?? '0') ?? 0,
        totalCaloriesOut: summary['total_calories_out'] is int
            ? summary['total_calories_out'] as int
            : int.tryParse(summary['total_calories_out']?.toString() ?? '0') ?? 0,
        totalNetCalories: summary['total_net_calories'] is int
            ? summary['total_net_calories'] as int
            : int.tryParse(summary['total_net_calories']?.toString() ?? '0') ?? 0,
        avgDailyNet: summary['avg_daily_net'] is int
            ? summary['avg_daily_net'] as int
            : int.tryParse(summary['avg_daily_net']?.toString() ?? '0') ?? 0,
        calorieGoal: summary['calorie_goal'] is int
            ? summary['calorie_goal'] as int
            : int.tryParse(summary['calorie_goal']?.toString() ?? '2000') ?? 2000,
        daysCount: summary['days_count'] is int
            ? summary['days_count'] as int
            : int.tryParse(summary['days_count']?.toString() ?? '0') ?? 0,
      ),
    );
  }
}

